import 'package:flutter/material.dart';

class ListAnimationDemo extends StatefulWidget {
  const ListAnimationDemo({super.key});

  @override
  State<ListAnimationDemo> createState() => _ListAnimationDemoState();
}

class _ListAnimationDemoState extends State<ListAnimationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _animations;

  int itemCount = 20;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animations = List.generate(20, (index) {
      return Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * (1 / itemCount), 1.0, curve: Curves.easeOut),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return SlideTransition(
            position: _animations[index],
            child: ListTile(title: Text('Item in the list $index')),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.isCompleted) {
            _controller.reverse();
          } else {
            _controller.forward();
          }
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
