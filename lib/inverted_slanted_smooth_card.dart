import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom widget that creates a card with smooth rounded corners and a slanted top edge.
///
/// The [InvertedSlantedSmoothCard] provides a visually appealing card design with customizable
/// corner radii, colors, images, and border properties. The card features a unique
/// slanted top edge created by lifting the top-left corner, making it the inverse
/// of [SlantedSmoothCard].
///
/// ## Features
/// - Smooth rounded corners with individual radius control
/// - Slanted top edge with customizable lift amount
/// - Support for solid colors, background images, and overlay images
/// - Customizable border with color and width options
/// - Automatic image loading and error handling
/// - Layered rendering system for optimal visual composition
///
/// ## Usage Example
/// ```dart
/// InvertedSlantedSmoothCard(
///   color: Colors.green,
///   topLeft: 20,
///   topRight: 18,
///   bottomLeft: 60,
///   bottomRight: 18,
///   topLift: 18,
///   backgroundImageAsset: 'assets/background.png',
///   backgroundImageOpacity: 0.2,
///   borderColor: Colors.black,
///   borderWidth: 4.0,
///   child: Center(child: Text('Content')),
/// )
/// ```
///
/// ## Shape Description
/// The card shape is created using a custom path with the following structure:
/// - Top edge: Slanted line from lifted top-left to top-right
/// - Right edge: Straight line with rounded corners
/// - Bottom edge: Straight line with rounded corners
/// - Left edge: Straight line with rounded corners
/// - Top-left corner: Lifted by [topLift] amount creating the slant
///
/// ## Rendering Layers
/// The widget renders content in the following order (bottom to top):
/// 1. Solid color background
/// 2. Background image (if provided) with opacity
/// 3. Main overlay image (if provided)
/// 4. Border stroke (if borderWidth > 0)
///
/// All layers are clipped to the custom shape path.
class InvertedSlantedSmoothCard extends StatefulWidget {
  /// Creates an [InvertedSlantedSmoothCard] with customizable appearance and shape.
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
    this.topLift = 38,
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
  /// one-third the card width due to the slanted top edge geometry.
  final double topLeft;

  /// The radius for the top-right corner in logical pixels.
  ///
  /// This value is automatically clamped to prevent the corner from exceeding
  /// half the card width to maintain a valid shape.
  final double topRight;

  /// The radius for the bottom-left corner in logical pixels.
  ///
  /// This value is automatically clamped to prevent the corner from exceeding
  /// half the card width to maintain a valid shape.
  final double bottomLeft;

  /// The radius for the bottom-right corner in logical pixels.
  ///
  /// This value is automatically clamped to prevent the corner from exceeding
  /// half the card width to maintain a valid shape.
  final double bottomRight;

  /// The amount to lift the top-left corner, creating the slanted top edge.
  ///
  /// This value determines how much higher the left side of the top edge
  /// appears compared to the right side, creating the characteristic slant.
  /// Higher values create a more pronounced slant effect.
  final double topLift;

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
        borderColor: widget.borderColor,
        borderWidth: widget.borderWidth,
      ),
      child: Center(child: widget.child),
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
    required this.borderColor,
    required this.borderWidth,
  });

  final Color color;
  final ui.Image? image;
  final ui.Image? backgroundImage;
  final double backgroundImageOpacity;
  final double topLeft, topRight, bottomLeft, bottomRight;
  final double topDrop;
  final Color borderColor;
  final double borderWidth;

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
  bool shouldRepaint(covariant _InvertedSlantedSmoothPainter old) =>
      old.color != color ||
      old.image != image ||
      old.backgroundImage != backgroundImage ||
      old.backgroundImageOpacity != backgroundImageOpacity ||
      old.topLeft != topLeft ||
      old.topRight != topRight ||
      old.bottomLeft != bottomLeft ||
      old.bottomRight != bottomRight ||
      old.topDrop != topDrop ||
      old.borderColor != borderColor ||
      old.borderWidth != borderWidth;
}
