import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom widget that creates a card with smooth rounded corners and a slanted bottom edge.
///
/// The [SlantedSmoothCard] provides a visually appealing card design with customizable
/// corner radii, colors, images, and border properties. The card features a unique
/// slanted bottom edge created by lifting the bottom-left corner.
///
/// ## Features
/// - Smooth rounded corners with individual radius control
/// - Slanted bottom edge with customizable lift amount
/// - Support for solid colors, background images, and overlay images
/// - Customizable border with color and width options
/// - Automatic image loading and error handling
/// - Layered rendering system for optimal visual composition
///
/// ## Usage Example
/// ```dart
/// SlantedSmoothCard(
///   color: Colors.blue,
///   topLeft: 60,
///   topRight: 60,
///   bottomLeft: 26,
///   bottomRight: 26,
///   bottomLift: 28,
///   backgroundImageAsset: 'assets/background.png',
///   backgroundImageOpacity: 0.15,
///   borderColor: Colors.black,
///   borderWidth: 4.0,
///   child: Center(child: Text('Content')),
/// )
/// ```
///
/// ## Shape Description
/// The card shape is created using a custom path with the following structure:
/// - Top edge: Straight line with rounded corners
/// - Right edge: Straight line with rounded bottom corner
/// - Bottom edge: Slanted line from bottom-right to lifted bottom-left
/// - Left edge: Straight line with rounded top corner
/// - Bottom-left corner: Lifted by [bottomLift] amount creating the slant
///
/// ## Rendering Layers
/// The widget renders content in the following order (bottom to top):
/// 1. Solid color background
/// 2. Background image (if provided) with opacity
/// 3. Main overlay image (if provided)
/// 4. Border stroke (if borderWidth > 0)
///
/// All layers are clipped to the custom shape path.
class SlantedSmoothCard extends StatefulWidget {
  /// Creates a [SlantedSmoothCard] with customizable appearance and shape.
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
    this.bottomLift = 38,
    this.borderColor = Colors.black,
    this.borderWidth = 8.0,
    this.child = const SizedBox.expand(),
  });

  /// The primary fill color of the card.
  ///
  /// This color serves as the base layer and will be visible when no images
  /// are provided or when images have transparency.
  final Color color;

  /// Path to an image asset to be used as an overlay on top of all other layers.
  ///
  /// This image will be rendered on top of the background color and background image.
  /// If the asset fails to load, the card will fall back to showing only the color
  /// and background image layers.
  final String? imageAsset;

  /// Path to an image asset to be used as a background texture.
  ///
  /// This image is rendered between the solid color and the main image overlay.
  /// The image is automatically scaled to fit the card dimensions.
  final String? backgroundImageAsset;

  /// The opacity level for the background image.
  ///
  /// Must be between 0.0 (completely transparent) and 1.0 (completely opaque).
  /// This allows the background color to show through the background image.
  final double backgroundImageOpacity;

  /// The radius for the top-left corner in logical pixels.
  ///
  /// This value is automatically clamped to prevent the corner from exceeding
  /// half the card width to maintain a valid shape.
  final double topLeft;

  /// The radius for the top-right corner in logical pixels.
  ///
  /// This value is automatically clamped to prevent the corner from exceeding
  /// half the card width to maintain a valid shape.
  final double topRight;

  /// The radius for the bottom-left corner in logical pixels.
  ///
  /// This value is automatically clamped to prevent the corner from exceeding
  /// one-third the card width due to the slanted bottom edge geometry.
  final double bottomLeft;

  /// The radius for the bottom-right corner in logical pixels.
  ///
  /// This value is automatically clamped to prevent the corner from exceeding
  /// half the card width to maintain a valid shape.
  final double bottomRight;

  /// The amount to lift the bottom-left corner, creating the slanted bottom edge.
  ///
  /// This value determines how much higher the left side of the bottom edge
  /// appears compared to the right side, creating the characteristic slant.
  /// Higher values create a more pronounced slant effect.
  final double bottomLift;

  /// The color of the border stroke.
  ///
  /// The border is drawn inside the card shape and follows all curves and edges.
  final Color borderColor;

  /// The width of the border stroke in logical pixels.
  ///
  /// Set to 0 to disable the border. The border is drawn inside the card shape,
  /// so it will not extend beyond the card's boundaries.
  final double borderWidth;

  /// The child widget to be displayed inside the card.
  ///
  /// This widget will be centered within the card and clipped to the card's shape.
  /// Defaults to [SizedBox.expand] which fills the available space.
  final Widget child;

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
        borderColor: widget.borderColor,
        borderWidth: widget.borderWidth,
      ),
      child: Center(child: widget.child),
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
    required this.borderColor,
    required this.borderWidth,
  });

  final Color color;
  final ui.Image? image;
  final ui.Image? backgroundImage;
  final double backgroundImageOpacity;
  final double topLeft, topRight, bottomLeft, bottomRight;
  final double bottomLift;
  final Color borderColor;
  final double borderWidth;

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
      backgroundPaint.color = backgroundPaint.color.withValues(
        alpha: backgroundImageOpacity,
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

    // Layer 4: Draw border inside the shape (if border width > 0)
    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, borderPaint);
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
      old.bottomLift != bottomLift ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth;
}
