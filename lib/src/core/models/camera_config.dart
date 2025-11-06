import 'package:camera/camera.dart';
import 'package:camera_picker/src/core/utils/overlay_size_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class Config {
  final bool showOverlay;
  final OverlayType? overlayType;
  const Config({
    required this.showOverlay,
    this.overlayType,
  });
}

class CameraConfig extends Config {
  final int quality;
  final bool autoCropping;

  const CameraConfig({
    this.quality = 80,
    super.showOverlay = true,
    super.overlayType,
    this.autoCropping = true,
  });
}

class StreamCameraConfig extends Config {
  final bool autoTracking;
  final int targetFps;
  final int? sensorOrientation;
  final CameraLensDirection? lensDirection;
  final DeviceOrientation? deviceOrientation;
  final bool enableLogging;

  const StreamCameraConfig({
    super.showOverlay = true,
    this.autoTracking = true,
    this.targetFps = 10,
    this.lensDirection,
    this.deviceOrientation,
    this.sensorOrientation,
    this.enableLogging = kDebugMode,
  });
}
