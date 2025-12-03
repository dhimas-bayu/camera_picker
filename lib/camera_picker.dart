import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_picker/src/presentations/views/error_view.dart';
import 'package:flutter/material.dart';

import 'src/core/models/camera_config.dart';
import 'src/presentations/views/barcode_scanner/barcode_scanner_view.dart';
import 'src/presentations/views/image_capture/image_capture_view.dart';
import 'src/presentations/views/video_record/video_record_view.dart';

export 'package:camera/camera.dart' show ResolutionPreset, availableCameras;
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
  }) async {
    return await Navigator.of(context, rootNavigator: true).push<File?>(
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
  }) async {
    return await Navigator.of(context, rootNavigator: true).push<String?>(
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
  }) async {
    return await Navigator.of(context, rootNavigator: true).push<File?>(
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: availableCameras(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return ErrorCameraView(
              errorMessage: '${asyncSnapshot.error}',
            );
          }

          if (asyncSnapshot.hasData) {
            final cameras = asyncSnapshot.data;
            if (cameras != null && cameras.isNotEmpty) {
              return switch (widget.action) {
                CameraMode.takePicture => ImageCaptureView(
                  cameras: cameras,
                  config: widget.config as CameraPickerConfig,
                  onTakePicture: (file) {
                    Navigator.pop(context, file);
                  },
                ),
                CameraMode.scanBarcode => BarcodeScannerView(
                  cameras: cameras,
                  config: widget.config as CameraScannerConfig,
                  onBarcodeScanned: (value) {
                    Navigator.pop(context, value);
                  },
                ),
                CameraMode.videoRecord => VideoRecordView(
                  cameras: cameras,
                  config: widget.config as CameraVideoConfig,
                  onRecorded: (file) {
                    Navigator.pop(context, file);
                  },
                ),
              };
            }
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
