import 'dart:developer' as developer;

import 'package:camera/camera.dart';
import 'package:camera_picker/camera_picker.dart';
import 'package:camera_picker/src/core/utils/painter_utils.dart';
import 'package:camera_picker/src/presentations/views/camera_view.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../../core/models/camera_config.dart';
import '../../../core/models/data_stream_camera.dart';
import '../../../core/utils/coordinates_translation.dart';
import '../../../core/utils/image_format_converter.dart';
import '../../painters/barcode_overlay_painter.dart';
import '../../viewmodels/camera_size_notifier.dart';
import '../../viewmodels/camera_viewmodel.dart';

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

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  late CameraSizeNotifier _notifier;
  Size? _cameraPreviewSize;
  Rect? _initialRect;
  bool _isProcessing = false;
  final _barcodeScanner = BarcodeScanner();
  final ValueNotifier<Rect?> _barcodeNotifier = ValueNotifier(null);
  Barcode? _prevBarcode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = CameraViewModel.of(context);
    if (_cameraPreviewSize != _notifier.size) {
      _cameraPreviewSize = _notifier.size;
    }
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    _barcodeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      action: CameraAction.scanBarcode,
      cameras: widget.cameras,
      targetStreamFPS: widget.config.targetFps,
      overlay: _overlay(),
      onStreamCamera: _processImage,
    );
  }

  Widget? _overlay() {
    if (_cameraPreviewSize == null) return null;

    debugPrint(
      "CAMERA SIZE : ${_cameraPreviewSize!.height}:${_cameraPreviewSize!.width}",
    );

    // Default: center screen dengan ukuran 60% width
    final center = Offset(
      _cameraPreviewSize!.width / 2,
      _cameraPreviewSize!.height / 2,
    );

    _initialRect = Rect.fromCenter(
      center: center,
      width: _cameraPreviewSize!.width * 0.6,
      height: _cameraPreviewSize!.width * 0.6,
    );

    debugPrint(
      "INITIAL RECT : ${_initialRect?.left}, ${_initialRect?.top}, ${_initialRect?.right}, ${_initialRect?.bottom}",
    );

    return ValueListenableBuilder(
      valueListenable: _barcodeNotifier,
      builder: (context, value, child) {
        return CustomPaint(
          size: _cameraPreviewSize!,
          painter: BarcodeOverlayPainter(
            boundingBox: value ?? _initialRect,
            radius: const Radius.circular(4.0),
          ),
        );
      },
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
          barcode.displayValue == _prevBarcode?.displayValue) {
        return;
      }
      final boundingBox = _barcodeBoundingBox(
        barcode,
        metadata?.size,
        metadata?.rotation,
        data.lensDirection,
        _cameraPreviewSize,
      );

      if (widget.config.autoTracking) {
        _barcodeNotifier.value = boundingBox;
        return;
      }

      if (boundingBox == null || _initialRect == null) return;

      final isInside = isRectInside(boundingBox, _initialRect!);
      if (mounted && isInside) {
        _prevBarcode = barcode;
        widget.onBarcodeScanned?.call(barcode.displayValue);
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
        layoutSize == null ||
        barcodeSize == null ||
        rotation == null ||
        cameraLensDirection == null) {
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

    // final List<Offset> cornerPoints = <Offset>[];
    // for (final point in barcode.cornerPoints) {
    //   final double x = translateX(
    //     point.x.toDouble(),
    //     layoutSize,
    //     barcodeSize,
    //     rotation,
    //     cameraLensDirection,
    //   );
    //   final double y = translateY(
    //     point.y.toDouble(),
    //     layoutSize,
    //     barcodeSize,
    //     rotation,
    //     cameraLensDirection,
    //   );

    //   cornerPoints.add(Offset(x, y));
    // }
    // cornerPoints.add(cornerPoints.first);

    debugPrint("TRANSLATE BARCODE RECT : $left, $top, $right, $bottom");
    return Rect.fromLTRB(left, top, right, bottom);
  }
}
