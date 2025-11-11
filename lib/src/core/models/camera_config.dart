import 'package:flutter/foundation.dart';

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

class CameraConfig extends Config {
  final bool autoCropping;

  const CameraConfig({
    super.quality = 80,
    super.showOverlay = true,
    super.overlaySize,
    this.autoCropping = true,
  });
}

class StreamCameraConfig extends Config {
  final bool autoTracking;
  final int targetFps;
  final bool enableLogging;

  const StreamCameraConfig({
    super.showOverlay = true,
    this.autoTracking = true,
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
