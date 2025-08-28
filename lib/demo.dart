import 'dart:math' as math;
import 'dart:ui';

import 'package:custom_paint_test/slanted_smooth_card.dart';
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
            Align(
              alignment: Alignment.bottomLeft,
              child: _buildRedSquareContainer2(context),
            ),
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

  Widget _buildRedSquareContainer2(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height * 0.2,
      child: SlantedSmoothCard(
        topLeft: 60,
        topRight: 60,
        bottomLeft: 26,
        bottomRight: 26,
        bottomLift: 28,
        color: Colors.blue,
      ),
    );
  }
}
