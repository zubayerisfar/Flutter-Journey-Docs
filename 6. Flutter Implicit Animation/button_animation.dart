import "package:flutter/material.dart";

class ButtonAnimation extends StatefulWidget {
  const ButtonAnimation({super.key});

  @override
  State<ButtonAnimation> createState() => _ButtonAnimationState();
}

class _ButtonAnimationState extends State<ButtonAnimation> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isClicked ? 300 : 100,
          height: isClicked ? 200 : 100,
          curve: Curves.fastOutSlowIn,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isClicked ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isClicked ? 50 : 10),
              ),
            ),
            onPressed: () {
              setState(() {
                isClicked = !isClicked;
              });
            },
            child: Center(
              child: Text(
                isClicked ? 'THE BUTTON HAS BEEN JUST CLICKED!' : 'Click',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
