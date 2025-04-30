import 'package:flutter/material.dart';
import 'package:graduation_project/constants.dart';

class SlidingText extends StatelessWidget {
  const SlidingText({
    super.key,
    required this.slidingAnimation,
  });

  final Animation<Offset> slidingAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: slidingAnimation,
        builder: (context, _) {
          return SlideTransition(
            position: slidingAnimation,
            child: Column(
              children: [
                Text(
                  'Sports',
                  style: TextStyle(
                      fontSize: 35, color: kPrimaryColor, fontFamily: 'Karla'),
                ),
                Text(
                  'Booking',
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                      fontFamily: 'Karla'),
                )
              ],
            ),
          );
        });
  }
}
