import 'package:flutter/material.dart';

class ShowPulseAnimation extends StatefulWidget {
  const ShowPulseAnimation({super.key});

  @override
  State<ShowPulseAnimation> createState() => _ShowPulseAnimationState();
}

class _ShowPulseAnimationState extends State<ShowPulseAnimation> {
  bool _forward = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(
          begin: _forward ? 0.5 : 1.5,
          end: _forward ? 1.5 : 0.5,
        ), // Scale from 0.5 to 1.5 and go back at the end
        duration: const Duration(milliseconds: 1500),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withAlpha(100),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          );
        },
        onEnd: () {
          // Restart the animation when it ends
          setState(() => _forward = !_forward);
        },
      ),
    );
  }
}
