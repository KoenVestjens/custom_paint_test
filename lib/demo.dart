import 'dart:math' as math;
import 'dart:ui';

import 'package:custom_paint_test/inverted_slanted_smooth_card.dart';
import 'package:custom_paint_test/slanted_smooth_card.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

final bottomRightSquareTopLift = 8.0;
final bottomLeftSquareTopLift = 16.0;

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen width: 402px
    // Screen height: 874px
    // Red container left height: 706
    // Red container right height: 734px

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate the width and height of the right square
    final bottomRightSquareWidth = 115.0;
    final bottomRightSquareHeight = 115.0;

    // Calculate the width and height of the bottom left square based
    // on the space that is left over
    // We need to take into account:
    // - Screen width
    // - 10px padding left, in between and right
    // - The width of bottom right square
    final bottomLeftSquareWidth = screenWidth - bottomRightSquareWidth - 3 * 10;
    final bottomLeftSquareHeight =
        bottomRightSquareHeight + bottomRightSquareTopLift + 2;

    // Calculate the width and height of the top square
    final topSquareWidth = screenWidth;
    final topSquareHeight = screenHeight - bottomLeftSquareHeight - 24;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        padding: EdgeInsets.all(10),
        child: Stack(
          children: [
            _buildRedSquareContainer(context, topSquareWidth, topSquareHeight),
            Align(
              alignment: Alignment.bottomLeft,
              child: _buildBottomLeftContainer(
                context,
                bottomLeftSquareWidth,
                bottomLeftSquareHeight,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _buildBottomRightContainer(
                context,
                bottomRightSquareWidth,
                bottomRightSquareHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedSquareContainer(
    BuildContext context,
    double width,
    double height,
  ) {
    return SizedBox(
      width: width,
      height: height,
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

  Widget _buildBottomLeftContainer(
    BuildContext context,
    double width,
    double height,
  ) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Container(width: width, height: height, color: Colors.purple),
        SizedBox(
          width: width,
          height: height,
          child: InvertedSlantedSmoothCard(
            topLeft: 0,
            topRight: 0,
            bottomLeft: 60,
            bottomRight: 0,
            topLift: bottomLeftSquareTopLift,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomRightContainer(
    BuildContext context,
    double width,
    double height,
  ) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          width: width,
          height: height,
          child: InvertedSlantedSmoothCard(
            topLeft: 0,
            topRight: 0,
            bottomLeft: 0,
            bottomRight: 60,
            topLift: bottomRightSquareTopLift,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
