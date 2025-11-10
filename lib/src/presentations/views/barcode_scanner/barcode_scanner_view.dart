import 'dart:developer' as developer;

import 'package:camera/camera.dart';
import 'package:camera_picker/camera_picker.dart';
import 'package:camera_picker/src/core/utils/painter_utils.dart';
import 'package:camera_picker/src/presentations/views/camera_view.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../../core/models/camera_config.dart';
import '../../../core/models/data_stream_camera.dart';
import '../../../core/utils/coordinates_translation.dart';
import '../../../core/utils/image_format_converter.dart';

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({
    super.key,
    required this.cameras,
    required this.config,
    this.onBarcodeScanned,
  });

  final List<CameraDescription> cameras;
  final StreamCameraConfig config;
  final ValueChanged<String?>? onBarcodeScanned;

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView>
    with SingleTickerProviderStateMixin {
  final _barcodeScanner = BarcodeScanner();
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _barcodeValue;
  Size? _layoutSize;
  Rect? _initialRect;
  Rect? _boundingBox;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Durations.medium2,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller
      ..addStatusListener(_animationListener)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  void _animationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.reset();

      if (_barcodeValue != null) {
        widget.onBarcodeScanned?.call(_barcodeValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      mode: CameraMode.scanBarcode,
      cameras: widget.cameras,
      targetStreamFPS: widget.config.targetFps,
      onPreviewBuilder: _buildOverlay,
      onStreamCamera: _processImage,
    );
  }

  Widget _buildOverlay(BuildContext context, Size size) {
    // Default: center screen dengan ukuran 60% width
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    _initialRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.6,
      height: size.width * 0.6,
    );

    _layoutSize = size;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          Rect? overlay = _initialRect;
          if (_boundingBox != null) {
            overlay = Rect.lerp(
              _initialRect,
              _boundingBox,
              _animation.value,
            );
          }

          return CustomPaint(
            size: size,
            painter: CameraOverlayPainter(
              boundingBox: overlay,
              radius: const Radius.circular(4.0),
            ),
          );
        },
      ),
    );
  }

  Future<void> _processImage(DataStreamCamera? data) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      if (data == null || data.image == null) return;
      final inputImage = await ImageFormatConverter.convertToInputImage(
        data.image!,
        lensDirection: data.lensDirection,
        deviceOrientation: data.deviceOrientation,
        sensorOrientation: data.sensorOrientation,
      );

      if (inputImage == null) return;
      final barcodes = await _barcodeScanner.processImage(inputImage);
      final metadata = inputImage.metadata;
      final barcode = barcodes.firstOrNull;

      if (barcode == null) return;
      if (!widget.config.autoTracking &&
          barcode.displayValue == _barcodeValue) {
        return;
      }

      _boundingBox = _barcodeBoundingBox(
        barcode,
        metadata?.size,
        metadata?.rotation,
        data.lensDirection,
        _layoutSize,
      );

      if (_boundingBox == null || _initialRect == null) return;
      if (widget.config.autoTracking) {
        _barcodeValue = barcode.displayValue;
        _controller.forward();
      } else {
        final isInside = isRectInside(_boundingBox!, _initialRect!);
        if (mounted && isInside) {
          _barcodeValue = barcode.displayValue;
          widget.onBarcodeScanned?.call(_barcodeValue);
        }
      }
    } catch (e) {
      developer.log("Error detected barcodes : $e");
    } finally {
      _isProcessing = false;
    }
  }

  Rect? _barcodeBoundingBox(
    Barcode? barcode,
    Size? barcodeSize,
    InputImageRotation? rotation,
    CameraLensDirection? cameraLensDirection,
    Size? layoutSize,
  ) {
    if (barcode == null ||
        barcodeSize == null ||
        rotation == null ||
        cameraLensDirection == null ||
        layoutSize == null) {
      return null;
    }

    final left = translateX(
      barcode.boundingBox.left,
      layoutSize,
      barcodeSize,
      rotation,
      cameraLensDirection,
    );
    final top = translateY(
      barcode.boundingBox.top,
      layoutSize,
      barcodeSize,
      rotation,
      cameraLensDirection,
    );
    final right = translateX(
      barcode.boundingBox.right,
      layoutSize,
      barcodeSize,
      rotation,
      cameraLensDirection,
    );
    final bottom = translateY(
      barcode.boundingBox.bottom,
      layoutSize,
      barcodeSize,
      rotation,
      cameraLensDirection,
    );
    return Rect.fromLTRB(left, top, right, bottom);
  }
}
