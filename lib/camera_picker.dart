import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_picker/src/presentations/views/permission_view.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/core/models/camera_config.dart';
import 'src/presentations/views/barcode_scanner/barcode_scanner_view.dart';
import 'src/presentations/views/image_capture/image_capture_view.dart';
import 'src/presentations/views/video_record/video_record_view.dart';

export 'package:camera/camera.dart' show ResolutionPreset;
export 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    show BarcodeFormat;

export 'src/presentations/painters/camera_overlay_painter.dart';
export 'src/core/models/camera_config.dart';
export 'src/core/models/overlay_size.dart';

enum CameraMode { takePicture, scanBarcode, videoRecord }

class CameraPicker extends StatefulWidget {
  const CameraPicker._({
    required this.action,
    required this.config,
  });
  final CameraMode action;
  final Config config;

  static Future<File?> takePicture(
    BuildContext context, {
    CameraPickerConfig? config,
  }) {
    return Navigator.of(context, rootNavigator: true).push<File?>(
      MaterialPageRoute(
        builder: (context) => CameraPicker._(
          action: CameraMode.takePicture,
          config: config ?? CameraPickerConfig(),
        ),
      ),
    );
  }

  static Future<String?> scanBarcode(
    BuildContext context, {
    CameraScannerConfig? config,
  }) {
    return Navigator.of(context, rootNavigator: true).push<String?>(
      MaterialPageRoute(
        builder: (context) => CameraPicker._(
          action: CameraMode.scanBarcode,
          config: config ?? CameraScannerConfig(),
        ),
      ),
    );
  }

  static Future<File?> videoRecord(
    BuildContext context, {
    CameraVideoConfig? config,
  }) {
    return Navigator.of(context, rootNavigator: true).push<File?>(
      MaterialPageRoute(
        builder: (context) => CameraPicker._(
          action: CameraMode.videoRecord,
          config: config ?? CameraVideoConfig(),
        ),
      ),
    );
  }

  @override
  State<CameraPicker> createState() => _CameraPickerState();
}

class _CameraPickerState extends State<CameraPicker> {
  bool _isGranted = false;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _initCamera());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isGranted
          ? const PermissionView()
          : switch (widget.action) {
              CameraMode.takePicture => ImageCaptureView(
                cameras: _cameras,
                config: widget.config as CameraPickerConfig,
                onTakePicture: (file) {
                  Navigator.pop(context, file);
                },
              ),
              CameraMode.scanBarcode => BarcodeScannerView(
                cameras: _cameras,
                config: widget.config as CameraScannerConfig,
                onBarcodeScanned: (value) {
                  Navigator.pop(context, value);
                },
              ),
              CameraMode.videoRecord => VideoRecordView(
                cameras: _cameras,
                config: widget.config as CameraVideoConfig,
                onRecorded: (file) {
                  Navigator.pop(context, file);
                },
              ),
            },
    );
  }

  Future<void> _initCamera() async {
    await _checkPermissions();
    await _checkAvailableCameras();
  }

  Future<void> _checkPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    _isGranted = statuses.values.every((status) {
      return status == PermissionStatus.granted;
    });
  }

  Future<void> _checkAvailableCameras() async {
    final cameras = await availableCameras();
    _cameras = cameras;
  }
}
