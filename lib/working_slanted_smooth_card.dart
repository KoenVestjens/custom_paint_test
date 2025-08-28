import 'dart:ui';

import 'package:flutter/material.dart';

class WorkingSlantedSmoothCard extends StatelessWidget {
  const WorkingSlantedSmoothCard({
    super.key,
    this.color = const Color(0xFFE94E00),
    this.topLeft = 72,
    this.topRight = 72,
    this.bottomLeft = 24,
    this.bottomRight = 24,
    this.bottomLift = 38, // how much higher the left bottom corner is
  });

  final Color color;
  final double topLeft, topRight, bottomLeft, bottomRight;
  final double bottomLift;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WorkingSlantedSmoothPainter(
        color: color,
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
        bottomLift: bottomLift,
      ),
      child: const SizedBox.expand(), // size from parent
    );
  }
}

class _WorkingSlantedSmoothPainter extends CustomPainter {
  _WorkingSlantedSmoothPainter({
    required this.color,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.bottomLift,
  });

  final Color color;
  final double topLeft, topRight, bottomLeft, bottomRight;
  final double bottomLift;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color;

    // Clamp radii so they don't exceed edge lengths
    final tl = topLeft.clamp(0, w / 2).toDouble();
    final tr = topRight.clamp(0, w / 2).toDouble();
    final bl = bottomLeft.clamp(0, w / 3).toDouble();
    final br = bottomRight.clamp(0, w / 2).toDouble();

    final path = Path();

    // Start on top edge, after top-left corner radius
    path.moveTo(tl + 0, 0);

    // Top edge to before top-right corner
    path.lineTo(w - tr, 0);

    // Smooth top-right corner (quadratic)
    path.quadraticBezierTo(w, 0, w, tr);

    // Right edge down to before bottom-right corner
    path.lineTo(w, h - br);

    // Simple smooth bottom-right corner using quadratic bezier
    final bottomLeftY = h - bottomLift;
    path.quadraticBezierTo(w, h, w - br, h);

    // Bottom edge (slanted) - straight line to before bottom-left corner
    final bottomEdgeLen = (Offset(w - br, h) - Offset(0, bottomLeftY)).distance;
    final t = bl / bottomEdgeLen;
    final bx = lerpDouble(w - br, 0, t)!;
    final by = lerpDouble(h, bottomLeftY, t)!;
    path.lineTo(bx, by);

    // Bottom-left corner with smooth quadratic bezier (same structure as bottom-right)
    final point = h - bottomLift;
    path.lineTo(bottomLift, point); // point A

    // Smooth curve from point A to point B using quadratic bezier
    path.quadraticBezierTo(0, point, 0, point - bottomLift); // point B

    // Left edge up to before top-left corner
    final leftEdgeLen = bottomLeftY; // from y=0 to y=bottomLeftY
    final ly = (tl <= leftEdgeLen) ? tl : leftEdgeLen;
    path.lineTo(0, ly);

    // Smooth top-left corner
    path.quadraticBezierTo(0, 0, tl, 0);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WorkingSlantedSmoothPainter old) =>
      old.color != color ||
      old.topLeft != topLeft ||
      old.topRight != topRight ||
      old.bottomLeft != bottomLeft ||
      old.bottomRight != bottomRight ||
      old.bottomLift != bottomLift;
}
