import 'package:flutter/material.dart';
import 'package:image/image.dart' as ui;

class Watermark {
  final String text;
  final ui.BitmapFont? font;
  final Color color;
  final double dstX;
  final double dstY;

  Watermark({
    required this.text,
    this.font,
    this.color = Colors.white,
    required this.dstX,
    required this.dstY,
  });
}
