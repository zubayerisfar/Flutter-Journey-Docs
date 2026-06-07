import 'package:flutter/material.dart';

class ShowContainerAnimation extends StatefulWidget {
  const ShowContainerAnimation({super.key});

  @override
  State<ShowContainerAnimation> createState() => _ShowContainerAnimationState();
}

class _ShowContainerAnimationState extends State<ShowContainerAnimation> {
  bool showContainer = false;
  Color currentColor = Colors.blue;

  void changeColorofContainer() {
    setState(() {
      currentColor = currentColor == Colors.blue ? Colors.red : Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(   
            onPressed: changeColorofContainer,
            child: const Text('New Container'),
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 100,
            height: 100,
            color: currentColor,
            curve: Curves.slowMiddle,
            child: const Center(
              child: Text(
                'Animated Container',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
