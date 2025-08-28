import 'package:custom_paint_test/inverted_slanted_smooth_card.dart';
import 'package:custom_paint_test/slanted_smooth_card.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo()));

final bottomRightSquareTopLift = 8.0;
final bottomLeftSquareTopLift = 18.0;

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
        color: Color.fromRGBO(255, 96, 41, 1),
        backgroundImageAsset: 'assets/red_background.png',
        backgroundImageOpacity: 0.15,
        // imageAsset: 'assets/red_pixel.png',
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
        SizedBox(
          width: width,
          height: height,
          child: InvertedSlantedSmoothCard(
            topLeft: 20,
            topRight: 18,
            bottomLeft: 60,
            bottomRight: 18,
            topLift: bottomLeftSquareTopLift,
            color: Color.fromRGBO(255, 226, 0, 1),
            backgroundImageAsset: 'assets/yellow_background.png',
            backgroundImageOpacity: 0.2,
            // imageAsset: 'assets/yellow_pixel.png',
            child: Text(
              '+ Players',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'BlamBot',
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: Colors.black,
              ),
            ),
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
            topLeft: 12,
            topRight: 20,
            bottomLeft: 18,
            bottomRight: 60,
            topLift: bottomRightSquareTopLift,
            color: Color.fromRGBO(0, 194, 94, 1),
            backgroundImageAsset: 'assets/green_background.png',
            backgroundImageOpacity: 0.2,
            // imageAsset: 'assets/green_pixel.png',
            child: Text(
              'GO!',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'BlamBot',
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
