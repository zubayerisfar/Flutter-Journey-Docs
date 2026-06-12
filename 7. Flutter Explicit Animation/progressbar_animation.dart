import 'package:flutter/material.dart';

class CircularProgressBarDemo extends StatefulWidget {
  const CircularProgressBarDemo({super.key});

  @override
  State<CircularProgressBarDemo> createState() =>
      _CircularProgressBarDemoState();
}

class _CircularProgressBarDemoState extends State<CircularProgressBarDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double progress = 0.75; // Static progress value (0.0 to 1.0)
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: progress).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    // Define your static progress here (0.0 to 1.0)
    double progress = 0.75;
    int percentage = (progress * 100).toInt();

    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // 1. The Circular Progress Bar
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: _animation.value, // Sets the current progress
                    strokeWidth: 16, // Thickness of the bar
                    backgroundColor: Colors.grey[300],
                    strokeCap: StrokeCap.round, // Gives the bar rounded edges
                  ),
                ),
                // 2. The Percentage Text
                Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.reset();
          _controller.forward();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
