import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import 'overlay_size.dart';

abstract class Config {
  int get quality;
  ResolutionPreset get resolutionPreset;
  bool get showOverlay;
  OverlaySize? get overlaySize;

}

class CameraPickerConfig extends Config {

  @override
  final int quality;

  @override
  ResolutionPreset get resolutionPreset => ResolutionPreset.high;

  @override
  final bool showOverlay;

  @override
  final OverlaySize? overlaySize;

  final bool autoCropping;

  CameraPickerConfig({
    this.quality = 100,
    this.showOverlay = true,
    this.overlaySize,
    this.autoCropping = false,
  });
}

class CameraScannerConfig extends Config {

  @override
  int get quality => 100;

  @override
  ResolutionPreset get resolutionPreset => ResolutionPreset.high;

  @override
  bool get showOverlay => true;

  @override
  OverlaySize? get overlaySize => null;


  final int targetFps;
  final bool autoTracking;
  final List<BarcodeFormat> barcodeFormat;
  final RegExp? filterText;

  CameraScannerConfig({
    this.targetFps = 10,
    this.barcodeFormat = const [BarcodeFormat.qrCode],
    this.autoTracking = true,
    this.filterText,
  });

}

class CameraVideoConfig extends Config {


  @override
  int get quality => 100;

  @override
  final ResolutionPreset resolutionPreset;

  @override
  bool get showOverlay => false;

  @override
  OverlaySize? get overlaySize => null;

  final int duration;

  CameraVideoConfig({
    this.duration = 10000,
    this.resolutionPreset = ResolutionPreset.high,
  });
}
