import 'dart:math' as math;

import 'package:flutter/material.dart';

class RecordProgressPainter extends CustomPainter {
  final double animationValue;
  final Color backgroundColor, indicatorColor;

  RecordProgressPainter({
    super.repaint,
    required this.animationValue,
    this.backgroundColor = Colors.white,
    this.indicatorColor = Colors.red,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = indicatorColor;
    double progress = (1.0 - animationValue) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant RecordProgressPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        backgroundColor != oldDelegate.backgroundColor ||
        indicatorColor != oldDelegate.indicatorColor;
  }
}
