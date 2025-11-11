import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'overlay_size.dart';

@immutable
class Config {
  final int quality;
  final bool showOverlay;
  final OverlaySize? overlaySize;
  const Config({
    this.quality = 100,
    this.showOverlay = true,
    this.overlaySize,
  });
}

class CameraPickerConfig extends Config {
  final bool autoCropping;

  const CameraPickerConfig({
    super.quality,
    super.showOverlay,
    super.overlaySize,
    this.autoCropping = false,
  });
}

class CameraScannerConfig extends Config {
  final int targetFps;
  final bool autoTracking;
  final List<BarcodeFormat> barcodeFormat;

  const CameraScannerConfig({
    this.targetFps = 10,
    this.barcodeFormat = const [BarcodeFormat.qrCode],
    this.autoTracking = true,
  });
}

class CameraVideoConfig extends Config {
  final int duration;

  const CameraVideoConfig({
    this.duration = 10000,
  });
}
