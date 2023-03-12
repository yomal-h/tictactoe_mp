import 'package:flutter/material.dart';

import 'dart:math';

class FlickeringText extends StatefulWidget {
  const FlickeringText({Key? key}) : super(key: key);

  @override
  _FlickeringTextState createState() => _FlickeringTextState();
}

class _FlickeringTextState extends State<FlickeringText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _opacityAnimation =
        Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
    _colorAnimation =
        ColorTween(begin: Colors.blue, end: Colors.pink).animate(_controller);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.duration =
            Duration(milliseconds: Random().nextInt(2000) + 20);
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.duration =
            Duration(milliseconds: Random().nextInt(1500) + 20);
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Beon',
              color: _colorAnimation.value,
              shadows: [
                Shadow(
                  blurRadius: 8.0,
                  color: _colorAnimation.value!.withOpacity(0.5),
                  offset: Offset(0, 0),
                ),
              ],
            ),
            children: [
              TextSpan(text: 'Tic Tac Toe '),
              TextSpan(
                text: 'Xperience',
                style: TextStyle(
                  fontSize: 36,
                  color: _colorAnimation.value!
                      .withOpacity(_opacityAnimation.value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
