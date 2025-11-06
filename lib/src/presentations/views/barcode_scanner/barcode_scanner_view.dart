import 'dart:developer' as developer;

import 'package:camera/camera.dart';
import 'package:camera_picker/camera_picker.dart';
import 'package:camera_picker/src/core/models/barcode_detection_result.dart';
import 'package:camera_picker/src/presentations/views/camera_view.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../../core/models/camera_config.dart';
import '../../../core/models/data_stream_camera.dart';
import '../../../core/utils/image_format_converter.dart';
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
  Size? _size;
  bool _isProcessing = false;
  final _barcodeScanner = BarcodeScanner();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = CameraViewModel.of(context);
    if (_size != _notifier.size) {
      _size = _notifier.size;
    }
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
    if (_size == null) return null;

    debugPrint("CAMERA SIZE : ${_size!.height}:${_size!.width}");
    final center = Offset(_size!.width / 2, _size!.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: _size!.width * .6,
      height: _size!.width * .6,
    );

    return CustomPaint(
      size: _size!,
      painter: OverlayPainter(
        boundingBox: rect,
        radius: const Radius.circular(4.0),
      ),
    );
  }

  Future<void> _processImage(DataStreamCamera? data) async {
    if (_isProcessing) return;

    try {
      _isProcessing = true;
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
      final result = BarcodeDetectionResult(
        result: barcodes,
        metadata: metadata,
        timestamp: DateTime.now(),
      );

      if (barcodes.isNotEmpty) debugPrint("Result : ${result.toString()}");
    } catch (e) {
      developer.log("Error detected barcodes : $e");
    } finally {
      _isProcessing = false;
    }
  }
}
