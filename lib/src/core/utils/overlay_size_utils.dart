import 'dart:ui';

import '../models/overlay_size.dart';

/// Repository untuk semua ukuran dokumen standar
class OverlaySizeUtils {
  /// Mendapatkan overlay size yang siap digunakan
  static Size getOverlaySize(
    OverlaySize size,
    Size screenSize, {
    double scaleFactor = 0.8,
  }) {
    return size.toOverlaySize(screenSize, scaleFactor: scaleFactor);
  }
}
