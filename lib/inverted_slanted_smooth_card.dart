import 'dart:ui';

import 'package:flutter/material.dart';

class InvertedSlantedSmoothCard extends StatelessWidget {
  const InvertedSlantedSmoothCard({
    super.key,
    this.color = const Color(0xFFE94E00),
    this.topLeft = 24,
    this.topRight = 24,
    this.bottomLeft = 72,
    this.bottomRight = 72,
    this.topLift = 38, // how much higher the left top corner is
  });

  final Color color;
  final double topLeft, topRight, bottomLeft, bottomRight;

  // Lifts the top left corner
  final double topLift;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InvertedSlantedSmoothPainter(
        color: color,
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
        topDrop: topLift,
      ),
      child: const SizedBox.expand(), // size from parent
    );
  }
}

class _InvertedSlantedSmoothPainter extends CustomPainter {
  _InvertedSlantedSmoothPainter({
    required this.color,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.topDrop,
  });

  final Color color;
  final double topLeft, topRight, bottomLeft, bottomRight;
  final double topDrop;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color;

    // Clamp radii so they don't exceed edge lengths
    final tl = topLeft.clamp(0, w / 3).toDouble();
    final tr = topRight.clamp(0, w / 2).toDouble();
    final bl = bottomLeft.clamp(0, w / 2).toDouble();
    final br = bottomRight.clamp(0, w / 2).toDouble();

    final path = Path();

    // Start on left edge, after the special top-left lifted corner
    final topLeftY = -topDrop;
    path.moveTo(0, topLeftY + tl);

    // Left edge down to before bottom-left corner
    path.lineTo(0, h - bl);

    // Smooth bottom-left corner (quadratic)
    path.quadraticBezierTo(0, h, bl, h);

    // Bottom edge to before bottom-right corner
    path.lineTo(w - br, h);

    // Smooth bottom-right corner using quadratic bezier
    path.quadraticBezierTo(w, h, w, h - br);

    // Right edge up to before top-right corner
    path.lineTo(w, tr);

    // Simple smooth top-right corner
    path.quadraticBezierTo(w, 0, w - tr, 0);

    // Top edge (slanted) - straight line to before top-left corner
    final topEdgeLen = (Offset(w - tr, 0) - Offset(topDrop, topLeftY)).distance;
    final t = tl / topEdgeLen;
    final tx = lerpDouble(w - tr, topDrop, t)!;
    final ty = lerpDouble(0, topLeftY, t)!;
    path.lineTo(tx, ty);

    // Top-left corner with smooth quadratic bezier (lifted corner)
    path.lineTo(topDrop, topLeftY); // point A (lifted position)

    // Smooth curve from point A to point B using quadratic bezier
    path.quadraticBezierTo(0, topLeftY, 0, topLeftY + tl); // point B

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _InvertedSlantedSmoothPainter old) =>
      old.color != color ||
      old.topLeft != topLeft ||
      old.topRight != topRight ||
      old.bottomLeft != bottomLeft ||
      old.bottomRight != bottomRight ||
      old.topDrop != topDrop;
}
