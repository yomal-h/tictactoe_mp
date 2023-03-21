import 'package:flutter/material.dart';
import 'package:tictactoe_mp/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;

  final String text;
  const CustomButton({Key? key, required this.onTap, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        Colors.purpleAccent.withOpacity(0.8),
        Colors.purpleAccent.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return SizedBox(
      width: 250, // Fixed width for all buttons
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              blurRadius: 5,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.blue.withOpacity(0.9),
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape: const StadiumBorder(),
            side: BorderSide(
              width: 1.0,
              color: Colors.blueAccent.withOpacity(0.3),
            ),
            elevation: 20.0,
            shadowColor: Colors.blue,
            minimumSize: const Size(0, 50),
          ),
        ),
      ),
    );
  }
}
