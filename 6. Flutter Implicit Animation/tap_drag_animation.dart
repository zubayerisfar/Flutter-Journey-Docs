import 'package:flutter/material.dart';

class TapDragAniamtion extends StatefulWidget {
  const TapDragAniamtion({super.key});

  @override
  State<TapDragAniamtion> createState() => _TapDragAniamtionState();
}

class _TapDragAniamtionState extends State<TapDragAniamtion> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [TapToGrow(), DraggableElement()],
    ); // stack them so they can overlap and be dragged around
  }
}

class TapToGrow extends StatefulWidget {
  @override
  State<TapToGrow> createState() => _TapToGrowState();
}

class _TapToGrowState extends State<TapToGrow> {
  bool _isBig = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isBig = !_isBig),
      child: AnimatedScale(
        scale: _isBig ? 1.5 : 1.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutBack, // gives a nice overshoot feel
        child: Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class DraggableElement extends StatefulWidget {
  @override
  State<DraggableElement> createState() => _DraggableElementState();
}

class _DraggableElementState extends State<DraggableElement> {
  double x = 100;
  double y = 100;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x - 50, // offset by half widget size to center on finger
      top: y - 50,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            x += details.delta.dx;
            y += details.delta.dy;
          });
        },
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}
