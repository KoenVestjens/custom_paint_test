import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlantedSmoothCard extends StatefulWidget {
  const SlantedSmoothCard({
    super.key,
    this.color = const Color(0xFFE94E00),
    this.imageAsset,
    this.backgroundImageAsset,
    this.backgroundImageOpacity = 1.0,
    this.topLeft = 72,
    this.topRight = 72,
    this.bottomLeft = 24,
    this.bottomRight = 24,
    this.bottomLift = 38, // how much higher the left bottom corner is
  });

  final Color color;
  final String? imageAsset;
  final String? backgroundImageAsset;
  final double backgroundImageOpacity; // 0.0 to 1.0
  final double topLeft, topRight, bottomLeft, bottomRight;

  // Lifts the bottom right corner
  final double bottomLift;

  @override
  State<SlantedSmoothCard> createState() => _SlantedSmoothCardState();
}

class _SlantedSmoothCardState extends State<SlantedSmoothCard> {
  ui.Image? _image;
  ui.Image? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void didUpdateWidget(SlantedSmoothCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageAsset != widget.imageAsset ||
        oldWidget.backgroundImageAsset != widget.backgroundImageAsset) {
      _loadImages();
    }
  }

  Future<void> _loadImages() async {
    await Future.wait([_loadImage(), _loadBackgroundImage()]);
  }

  Future<void> _loadImage() async {
    if (widget.imageAsset == null) {
      setState(() {
        _image = null;
      });
      return;
    }

    try {
      final data = await rootBundle.load(widget.imageAsset!);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      setState(() {
        _image = frame.image;
      });
    } catch (e) {
      // If image loading fails, fall back to color
      setState(() {
        _image = null;
      });
    }
  }

  Future<void> _loadBackgroundImage() async {
    if (widget.backgroundImageAsset == null) {
      setState(() {
        _backgroundImage = null;
      });
      return;
    }

    try {
      final data = await rootBundle.load(widget.backgroundImageAsset!);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      setState(() {
        _backgroundImage = frame.image;
      });
    } catch (e) {
      // If background image loading fails, continue without it
      setState(() {
        _backgroundImage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SlantedSmoothPainter(
        color: widget.color,
        image: _image,
        backgroundImage: _backgroundImage,
        backgroundImageOpacity: widget.backgroundImageOpacity,
        topLeft: widget.topLeft,
        topRight: widget.topRight,
        bottomLeft: widget.bottomLeft,
        bottomRight: widget.bottomRight,
        bottomLift: widget.bottomLift,
      ),
      child: const SizedBox.expand(), // size from parent
    );
  }
}

class _SlantedSmoothPainter extends CustomPainter {
  _SlantedSmoothPainter({
    required this.color,
    this.image,
    this.backgroundImage,
    required this.backgroundImageOpacity,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.bottomLift,
  });

  final Color color;
  final ui.Image? image;
  final ui.Image? backgroundImage;
  final double backgroundImageOpacity;
  final double topLeft, topRight, bottomLeft, bottomRight;
  final double bottomLift;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

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
    final bx = ui.lerpDouble(w - br, 0, t)!;
    final by = ui.lerpDouble(h, bottomLeftY, t)!;
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

    // Save the canvas state for clipping
    canvas.save();
    canvas.clipPath(path);

    // Layer 1: Draw solid color background
    final colorPaint = Paint()..color = color;
    canvas.drawPath(path, colorPaint);

    // Layer 2: Draw background image on top of color (if available)
    if (backgroundImage != null) {
      final backgroundPaint = Paint();

      // Calculate scale to fit the container
      final imageWidth = backgroundImage!.width.toDouble();
      final imageHeight = backgroundImage!.height.toDouble();
      final scaleX = w / imageWidth;
      final scaleY = h / imageHeight;

      // Create transformation matrix to scale the image to fit
      final matrix = Matrix4.identity()..scale(scaleX, scaleY);

      final shader = ui.ImageShader(
        backgroundImage!,
        ui.TileMode.clamp,
        ui.TileMode.clamp,
        matrix.storage,
      );
      backgroundPaint.shader = shader;

      // Apply opacity directly to the backgroundPaint
      backgroundPaint.color = backgroundPaint.color.withOpacity(
        backgroundImageOpacity,
      );

      canvas.drawPath(path, backgroundPaint);
    }

    // Layer 3: Draw main image on top (if available)
    if (image != null) {
      final imagePaint = Paint();
      final shader = ui.ImageShader(
        image!,
        ui.TileMode.clamp,
        ui.TileMode.clamp,
        Matrix4.identity().storage,
      );
      imagePaint.shader = shader;
      canvas.drawPath(path, imagePaint);
    }

    // Restore the canvas state
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SlantedSmoothPainter old) =>
      old.color != color ||
      old.image != image ||
      old.backgroundImage != backgroundImage ||
      old.backgroundImageOpacity != backgroundImageOpacity ||
      old.topLeft != topLeft ||
      old.topRight != topRight ||
      old.bottomLeft != bottomLeft ||
      old.bottomLift != bottomLift;
}
