import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InvertedSlantedSmoothCard extends StatefulWidget {
  const InvertedSlantedSmoothCard({
    super.key,
    this.color = const Color(0xFFE94E00),
    this.imageAsset,
    this.backgroundImageAsset,
    this.backgroundImageOpacity = 1.0,
    this.topLeft = 24,
    this.topRight = 24,
    this.bottomLeft = 72,
    this.bottomRight = 72,
    this.topLift = 38, // how much higher the left top corner is
  });

  final Color color;
  final String? imageAsset;
  final String? backgroundImageAsset;
  final double backgroundImageOpacity; // 0.0 to 1.0
  final double topLeft, topRight, bottomLeft, bottomRight;

  // Lifts the top left corner
  final double topLift;

  @override
  State<InvertedSlantedSmoothCard> createState() =>
      _InvertedSlantedSmoothCardState();
}

class _InvertedSlantedSmoothCardState extends State<InvertedSlantedSmoothCard> {
  ui.Image? _image;
  ui.Image? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void didUpdateWidget(InvertedSlantedSmoothCard oldWidget) {
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
      painter: _InvertedSlantedSmoothPainter(
        color: widget.color,
        image: _image,
        backgroundImage: _backgroundImage,
        backgroundImageOpacity: widget.backgroundImageOpacity,
        topLeft: widget.topLeft,
        topRight: widget.topRight,
        bottomLeft: widget.bottomLeft,
        bottomRight: widget.bottomRight,
        topDrop: widget.topLift,
      ),
      child: const SizedBox.expand(), // size from parent
    );
  }
}

class _InvertedSlantedSmoothPainter extends CustomPainter {
  _InvertedSlantedSmoothPainter({
    required this.color,
    this.image,
    this.backgroundImage,
    required this.backgroundImageOpacity,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.topDrop,
  });

  final Color color;
  final ui.Image? image;
  final ui.Image? backgroundImage;
  final double backgroundImageOpacity;
  final double topLeft, topRight, bottomLeft, bottomRight;
  final double topDrop;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

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
    final tx = ui.lerpDouble(w - tr, topDrop, t)!;
    final ty = ui.lerpDouble(0, topLeftY, t)!;
    path.lineTo(tx, ty);

    // Top-left corner with smooth quadratic bezier (lifted corner)
    path.lineTo(topDrop, topLeftY); // point A (lifted position)

    // Smooth curve from point A to point B using quadratic bezier
    path.quadraticBezierTo(0, topLeftY, 0, topLeftY + tl); // point B

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
  bool shouldRepaint(covariant _InvertedSlantedSmoothPainter old) =>
      old.color != color ||
      old.image != image ||
      old.backgroundImage != backgroundImage ||
      old.backgroundImageOpacity != backgroundImageOpacity ||
      old.topLeft != topLeft ||
      old.topRight != topRight ||
      old.bottomLeft != bottomLeft ||
      old.bottomRight != bottomRight ||
      old.topDrop != topDrop;
}
