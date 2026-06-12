import 'package:flutter/material.dart';

class LoginScreenAnimation extends StatefulWidget {
  const LoginScreenAnimation({super.key});

  @override
  State<LoginScreenAnimation> createState() => _LoginScreenAnimationState();
}

class _LoginScreenAnimationState extends State<LoginScreenAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);

    _slideAnimation = Tween<Offset>(
      begin: Offset(-1, -1),
      end: Offset.zero,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _opacityAnimation,
              child: FlutterLogo(size: 100),
            ),
            Text('Login'),

            SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  TextField(decoration: InputDecoration(hintText: 'Email')),
                  TextField(
                    decoration: InputDecoration(hintText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  FilledButton(onPressed: () {}, child: Text('Login')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
