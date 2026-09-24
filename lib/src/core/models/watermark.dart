import 'package:flutter/material.dart';
import 'package:image/image.dart' as ui;

enum WatermarkPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class Watermark {
  final String text;
  final ui.BitmapFont? font;
  final Color color;
  final double dstX;
  final double dstY;
  final WatermarkPosition position;
  final bool showTimestamp;

  Watermark({
    required this.text,
    this.font,
    this.color = Colors.white,
    this.dstX = 40.0,
    this.dstY = 40.0,
    this.position = WatermarkPosition.bottomRight,
    this.showTimestamp = false,
  });
}
