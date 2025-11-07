import 'package:flutter/material.dart';

enum CornerType { topLeft, topRight, bottomRight, bottomLeft }

class CameraOverlayPainter extends CustomPainter {
  final Rect? boundingBox;
  final Radius radius;
  final Animation<double>? animation;
  final bool hasIndicator;

  CameraOverlayPainter({
    super.repaint,
    this.boundingBox,
    this.radius = Radius.zero,
    this.animation,
    this.hasIndicator = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (boundingBox == null) return;

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black54;

    final overlayRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPath = Path()..addRect(overlayRect);

    final hole = RRect.fromRectAndRadius(boundingBox!, radius);
    final holePath = Path()..addRRect(hole);

    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    canvas.drawPath(finalPath, paint);
    if (hasIndicator) {
      final color = Color.lerp(
        Colors.white,
        Colors.lightGreenAccent,
        animation?.value ?? 0.0,
      );

      final cornerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = color ?? Colors.white
        ..strokeCap = StrokeCap.round;

      _drawViewfinderCorners(canvas, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CameraOverlayPainter oldDelegate) {
    return oldDelegate.boundingBox != boundingBox ||
        oldDelegate.radius != radius ||
        oldDelegate.animation != animation;
  }

  void _drawViewfinderCorners(
    Canvas canvas,
    Paint paint, {
    double cornerRadius = 0.0,
    double padding = 8.0,
    double cornerLength = 24.0,
  }) {
    final paddedRect = Rect.fromLTRB(
      boundingBox!.left - padding,
      boundingBox!.top - padding,
      boundingBox!.right + padding,
      boundingBox!.bottom + padding,
    );

    // Top-left corner
    _drawRoundedCorner(
      canvas,
      paint,
      paddedRect,
      cornerRadius,
      cornerLength,
      CornerType.topLeft,
    );

    // Top-right corner
    _drawRoundedCorner(
      canvas,
      paint,
      paddedRect,
      cornerRadius,
      cornerLength,
      CornerType.topRight,
    );

    // Bottom-right corner
    _drawRoundedCorner(
      canvas,
      paint,
      paddedRect,
      cornerRadius,
      cornerLength,
      CornerType.bottomRight,
    );

    // Bottom-left corner
    _drawRoundedCorner(
      canvas,
      paint,
      paddedRect,
      cornerRadius,
      cornerLength,
      CornerType.bottomLeft,
    );
  }

  void _drawRoundedCorner(
    Canvas canvas,
    Paint paint,
    Rect boundingRect,
    double radius,
    double cornerLength,
    CornerType type,
  ) {
    final radiusX = this.radius.x * 2;
    final radiusY = this.radius.y * 2;

    switch (type) {
      case CornerType.topLeft:
        final topLeftPath = Path()
          ..moveTo(boundingRect.left + cornerLength, boundingRect.top)
          ..lineTo(boundingRect.left + radius + radiusY, boundingRect.top)
          ..quadraticBezierTo(
            boundingRect.left,
            boundingRect.top,
            boundingRect.left,
            boundingRect.top + radius + radiusX,
          )
          ..lineTo(boundingRect.left, boundingRect.top + cornerLength);
        canvas.drawPath(topLeftPath, paint);
        break;

      case CornerType.topRight:
        final topRightPath = Path()
          ..moveTo(boundingRect.right - cornerLength, boundingRect.top)
          ..lineTo(
            boundingRect.right - radius - radiusY,
            boundingRect.top,
          )
          ..quadraticBezierTo(
            boundingRect.right,
            boundingRect.top,
            boundingRect.right,
            boundingRect.top + radius + radiusX,
          )
          ..lineTo(boundingRect.right, boundingRect.top + cornerLength);
        canvas.drawPath(topRightPath, paint);
        break;

      case CornerType.bottomRight:
        final bottomRightPath = Path()
          ..moveTo(boundingRect.right, boundingRect.bottom - cornerLength)
          ..lineTo(
            boundingRect.right,
            boundingRect.bottom - radius - radiusY,
          )
          ..quadraticBezierTo(
            boundingRect.right,
            boundingRect.bottom,
            boundingRect.right - radius - radiusX,
            boundingRect.bottom,
          )
          ..lineTo(boundingRect.right - cornerLength, boundingRect.bottom);
        canvas.drawPath(bottomRightPath, paint);
        break;

      case CornerType.bottomLeft:
        final bottomLeftPath = Path()
          ..moveTo(boundingRect.left, boundingRect.bottom - cornerLength)
          ..lineTo(
            boundingRect.left,
            boundingRect.bottom - radius - radiusY,
          )
          ..quadraticBezierTo(
            boundingRect.left,
            boundingRect.bottom,
            boundingRect.left + radius + radiusX,
            boundingRect.bottom,
          )
          ..lineTo(boundingRect.left + cornerLength, boundingRect.bottom);
        canvas.drawPath(bottomLeftPath, paint);

        break;
    }
  }
}
