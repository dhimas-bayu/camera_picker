import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/core/models/camera_config.dart';
import 'src/presentations/views/barcode_scanner/barcode_scanner_view.dart';
import 'src/presentations/views/image_capture/image_capture_view.dart';
import 'src/presentations/views/video_record/video_record_view.dart';

export 'src/presentations/painters/camera_overlay_painter.dart';

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
    CameraConfig? config,
  }) async {
    return await Navigator.of(context, rootNavigator: true).push<File?>(
      MaterialPageRoute(
        builder: (context) => CameraPicker._(
          action: CameraMode.takePicture,
          config: config ?? const CameraConfig(),
        ),
      ),
    );
  }

  static Future<String?> scanBarcode(
    BuildContext context, {
    StreamCameraConfig? config,
  }) async {
    return await Navigator.of(context, rootNavigator: true).push<String?>(
      MaterialPageRoute(
        builder: (context) => CameraPicker._(
          action: CameraMode.scanBarcode,
          config: config ?? const StreamCameraConfig(),
        ),
      ),
    );
  }

  static Future<File?> videoRecord(
    BuildContext context, {
    VideoConfig? config,
  }) async {
    return await Navigator.of(context, rootNavigator: true).push<File?>(
      MaterialPageRoute(
        builder: (context) => CameraPicker._(
          action: CameraMode.videoRecord,
          config: config ?? const VideoConfig(),
        ),
      ),
    );
  }

  @override
  State<CameraPicker> createState() => _CameraPickerState();
}

class _CameraPickerState extends State<CameraPicker> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: availableCameras(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }

          switch (widget.action) {
            case CameraMode.takePicture:
              return ImageCaptureView(
                cameras: asyncSnapshot.requireData,
                config: widget.config as CameraConfig,
                onTakePicture: (file) {
                  Navigator.pop(context, file);
                },
              );
            case CameraMode.scanBarcode:
              return BarcodeScannerView(
                cameras: asyncSnapshot.requireData,
                config: widget.config as StreamCameraConfig,
                onBarcodeScanned: (value) {
                  Navigator.pop(context, value);
                },
              );
            case CameraMode.videoRecord:
              return VideoRecordView(
                cameras: asyncSnapshot.requireData,
                config: widget.config as VideoConfig,
                onRecorded: (file) {
                  Navigator.pop(context, file);
                },
              );
          }
        },
      ),
    );
  }
}
