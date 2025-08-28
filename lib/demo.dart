import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

// Screen width: 402px
// Screen height: 874px
// Red container left height: 706
// Red container right height: 734px
class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    // Device height = 874px
    // Padding = 10px

    // Red square height = 734 and 706

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        child: Stack(
          children: [
            _buildRedSquareContainer(context),
            // Positioned(
            //   bottom: 0,
            //   right: 0,
            //   child: Container(
            //     width: MediaQuery.of(context).size.width * 0.3010471204,
            //     height: MediaQuery.of(context).size.height * 0.1381733021,
            //     color: Colors.blue,
            //   ),
            // ),
            // Positioned(
            //   left: 0,
            //   bottom: 0,
            //   child: Container(
            //     width: MediaQuery.of(context).size.width * 0.6727748691,
            //     height: MediaQuery.of(context).size.height * 0.1615925059,
            //     color: Colors.yellow,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedSquareContainer(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.8594847775,
      child: SlantedSmoothCard(
        topLeft: 60,
        topRight: 60,
        bottomLeft: 26,
        bottomRight: 26,
        bottomLift: 28,
        color: Color(0xFFE94E00),
      ),
    );
  }
}

class SlantedSmoothCard extends StatelessWidget {
  const SlantedSmoothCard({
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
      painter: _SlantedSmoothPainter(
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

class _SlantedSmoothPainter extends CustomPainter {
  _SlantedSmoothPainter({
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

    // Bottom edge runs from (0, h - bottomLift) -> (w, h)
    final blCorner = Offset(0, h - bottomLift);
    final brCorner = Offset(w, h);
    final tlCorner = const Offset(0, 0);
    final trCorner = Offset(w, 0);

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

    // Bottom-left corner with proper quadratic bezier
    path.lineTo(0, bottomLeftY);

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
  bool shouldRepaint(covariant _SlantedSmoothPainter old) =>
      old.color != color ||
      old.topLeft != topLeft ||
      old.topRight != topRight ||
      old.bottomLeft != bottomLeft ||
      old.bottomRight != bottomRight ||
      old.bottomLift != bottomLift;
}
