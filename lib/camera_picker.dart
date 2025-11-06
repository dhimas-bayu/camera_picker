import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'src/core/models/camera_config.dart';
import 'src/presentations/viewmodels/camera_size_notifier.dart';
import 'src/presentations/viewmodels/camera_viewmodel.dart';
import 'src/presentations/views/barcode_scanner/barcode_scanner_view.dart';
import 'src/presentations/views/image_capture/image_capture_view.dart';

export 'src/presentations/painters/overlay_painter.dart';

enum CameraAction { takePicture, scanBarcode }

class CameraPicker extends StatefulWidget {
  const CameraPicker._({required this.action, required this.config});
  final CameraAction action;
  final Config config;

  static Future<File?> takePicture(
    BuildContext context, {
    CameraConfig? config,
  }) async {
    File? imageFile;
    if (context.mounted) {
      imageFile = await Navigator.of(context).push<File?>(
        MaterialPageRoute(
          builder: (context) => CameraPicker._(
            action: CameraAction.takePicture,
            config: config ?? const CameraConfig(),
          ),
        ),
      );
    }
    return imageFile;
  }

  static Future<String?> scanBarcode(
    BuildContext context, {
    StreamCameraConfig? config,
  }) async {
    String? barcodeResult;
    if (context.mounted) {
      barcodeResult = await Navigator.of(context).push<String?>(
        MaterialPageRoute(
          builder: (context) => CameraPicker._(
            action: CameraAction.scanBarcode,
            config: config ?? const StreamCameraConfig(),
          ),
        ),
      );
    }
    return barcodeResult;
  }

  @override
  State<CameraPicker> createState() => _CameraPickerState();
}

class _CameraPickerState extends State<CameraPicker> {
  final CameraSizeNotifier _notifier = CameraSizeNotifier();

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, child) {
        return CameraViewModel(
          notifier: _notifier,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: FutureBuilder(
              future: availableCameras(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(year2023: false),
                  );
                }

                switch (widget.action) {
                  case CameraAction.takePicture:
                    return ImageCaptureView(
                      cameras: asyncSnapshot.requireData,
                      config: widget.config as CameraConfig,
                      onTakePicture: (file) {
                        Navigator.pop(context, file);
                      },
                    );
                  case CameraAction.scanBarcode:
                    return BarcodeScannerView(
                      cameras: asyncSnapshot.requireData,
                      config: widget.config as StreamCameraConfig,
                      onBarcodeScanned: (value) {
                        Navigator.pop(context, value);
                      },
                    );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
