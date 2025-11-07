import 'package:flutter/material.dart';

import '../../../camera_picker.dart';

class BarcodeOverlayPainter extends CustomPainter {
  final Rect? boundingBox;
  final Radius radius;
  final Animation<double>? animation;
  final bool hasIndicator;

  BarcodeOverlayPainter({
    super.repaint,
    this.boundingBox,
    this.radius = Radius.zero,
    this.animation,
    this.hasIndicator = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (boundingBox == null) return;
    final overlayRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw background overlay dengan hole
    _drawOverlayWithHole(canvas, overlayRect, boundingBox!);

    // Draw animated viewfinder corners
    if (hasIndicator) {
      _drawAnimatedViewfinder(canvas, boundingBox!);
    }
  }

  @override
  bool shouldRepaint(covariant BarcodeOverlayPainter oldDelegate) {
    return oldDelegate.boundingBox != boundingBox ||
        oldDelegate.radius != radius ||
        oldDelegate.animation != animation;
  }

  void _drawOverlayWithHole(Canvas canvas, Rect overlayRect, Rect boundingBox) {
    final backgroundPath = Path()..addRect(overlayRect);

    // Create hole dengan rounded corners
    final hole = RRect.fromRectAndRadius(boundingBox, radius);
    final holePath = Path()..addRRect(hole);

    // Combine: overlay - hole
    final finalPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black54;

    canvas.drawPath(finalPath, paint);
  }

  void _drawAnimatedViewfinder(Canvas canvas, Rect boundingBox) {
    // Animated color dari white ke green
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

    // ============================================
    // SAVE/RESTORE untuk isolasi efek animasi
    // ============================================
    canvas.save();

    // Animated scale effect (pulse)
    final progress = animation?.value ?? 0.0;
    final scale = 1.0 + (progress * 0.05); // Pulse 5%

    // Translate ke center bounding box
    final center = boundingBox.center;
    canvas.translate(center.dx, center.dy);

    // Scale dari center
    canvas.scale(scale);

    // Translate balik agar rotasi/scale dari center boundingBox
    canvas.translate(-center.dx, -center.dy);

    // Draw corners dengan padding
    _drawViewfinderCorners(
      canvas,
      cornerPaint,
      boundingBox: boundingBox,
      cornerRadius: radius.x,
      padding: 8.0,
      cornerLength: 24.0 + (progress * 8.0), // Animated corner length
    );

    canvas.restore();
  }

  void _drawViewfinderCorners(
    Canvas canvas,
    Paint paint, {
    required Rect boundingBox,
    double cornerRadius = 0.0,
    double padding = 8.0,
    double cornerLength = 24.0,
  }) {
    final paddedRect = Rect.fromLTRB(
      boundingBox.left - padding,
      boundingBox.top - padding,
      boundingBox.right + padding,
      boundingBox.bottom + padding,
    );

    // Draw setiap corner dengan save/restore individual
    // untuk isolasi transformasi per corner

    // Top-left corner
    canvas.save();
    _drawRoundedCorner(
      canvas,
      paint,
      paddedRect,
      cornerRadius,
      cornerLength,
      CornerType.topLeft,
    );
    canvas.restore();

    // Top-right corner
    canvas.save();
    _drawRoundedCorner(
      canvas,
      paint,
      paddedRect,
      cornerRadius,
      cornerLength,
      CornerType.topRight,
    );
    canvas.restore();

    // Bottom-right corner
    canvas.save();
    _drawRoundedCorner(
      canvas,
      paint,
      paddedRect,
      cornerRadius,
      cornerLength,
      CornerType.bottomRight,
    );
    canvas.restore();

    // Bottom-left corner
    canvas.save();
    _drawRoundedCorner(
      canvas,
      paint,
      paddedRect,
      cornerRadius,
      cornerLength,
      CornerType.bottomLeft,
    );
    canvas.restore();
  }

  void _drawRoundedCorner(
    Canvas canvas,
    Paint paint,
    Rect boundingRect,
    double cornerRadius,
    double cornerLength,
    CornerType type,
  ) {
    final radiusX = radius.x * 2;
    final radiusY = radius.y * 2;

    switch (type) {
      case CornerType.topLeft:
        final topLeftPath = Path()
          ..moveTo(boundingRect.left + cornerLength, boundingRect.top)
          ..lineTo(boundingRect.left + cornerRadius + radiusY, boundingRect.top)
          ..quadraticBezierTo(
            boundingRect.left,
            boundingRect.top,
            boundingRect.left,
            boundingRect.top + cornerRadius + radiusX,
          )
          ..lineTo(boundingRect.left, boundingRect.top + cornerLength);
        canvas.drawPath(topLeftPath, paint);
        break;

      case CornerType.topRight:
        final topRightPath = Path()
          ..moveTo(boundingRect.right - cornerLength, boundingRect.top)
          ..lineTo(
            boundingRect.right - cornerRadius - radiusY,
            boundingRect.top,
          )
          ..quadraticBezierTo(
            boundingRect.right,
            boundingRect.top,
            boundingRect.right,
            boundingRect.top + cornerRadius + radiusX,
          )
          ..lineTo(boundingRect.right, boundingRect.top + cornerLength);
        canvas.drawPath(topRightPath, paint);
        break;

      case CornerType.bottomRight:
        final bottomRightPath = Path()
          ..moveTo(boundingRect.right, boundingRect.bottom - cornerLength)
          ..lineTo(
            boundingRect.right,
            boundingRect.bottom - cornerRadius - radiusY,
          )
          ..quadraticBezierTo(
            boundingRect.right,
            boundingRect.bottom,
            boundingRect.right - cornerRadius - radiusX,
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
            boundingRect.bottom - cornerRadius - radiusY,
          )
          ..quadraticBezierTo(
            boundingRect.left,
            boundingRect.bottom,
            boundingRect.left + cornerRadius + radiusX,
            boundingRect.bottom,
          )
          ..lineTo(boundingRect.left + cornerLength, boundingRect.bottom);
        canvas.drawPath(bottomLeftPath, paint);
        break;
    }
  }
}
