import 'package:flutter/material.dart';

class PulsatingAnimationExplicit extends StatefulWidget {
  const PulsatingAnimationExplicit({super.key});

  @override
  State<PulsatingAnimationExplicit> createState() =>
      _PulsatingAnimationExplicitState();
}

class _PulsatingAnimationExplicitState extends State<PulsatingAnimationExplicit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.5).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
