import '../utils/overlay_size_utils.dart';
import 'package:flutter/foundation.dart';

@immutable
class Config {
  final int quality;
  final bool showOverlay;
  final OverlayType? overlayType;
  const Config({
    this.quality = 100,
    this.showOverlay = true,
    this.overlayType,
  });
}

class CameraConfig extends Config {
  final bool autoCropping;

  const CameraConfig({
    super.quality = 80,
    super.showOverlay = true,
    super.overlayType,
    this.autoCropping = true,
  });
}

class StreamCameraConfig extends Config {
  final bool autoTracking;
  final int targetFps;
  final bool enableLogging;

  const StreamCameraConfig({
    super.showOverlay = true,
    this.autoTracking = false,
    this.targetFps = 10,
    this.enableLogging = kDebugMode,
  });
}

class VideoConfig extends Config {
  final int duration;

  const VideoConfig({
    super.quality = 80,
    this.duration = 10000,
  });
}
