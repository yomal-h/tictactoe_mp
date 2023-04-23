import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

import 'package:tictactoe_mp/utils/colors.dart';
import 'package:tictactoe_mp/widgets/custom_flickering_menu_text.dart';

class DifficultyLevelSelectionScreen extends StatelessWidget {
  static const routeName = '/difficulty_level_selection_screen';
  const DifficultyLevelSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              'Select Difficulty',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.blueAccent.withOpacity(0.9),
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 55),
            _buildButton(
              context,
              'Easy',
              () => Navigator.pushNamed(context, '/tictactoe_easy'),
            ),
            const SizedBox(height: 28),
            _buildButton(
              context,
              'Medium',
              () => Navigator.pushNamed(context, '/tictactoe_medium'),
            ),
            const SizedBox(height: 28),
            _buildButton(
              context,
              'Hard',
              () => Navigator.pushNamed(context, '/tictactoe_hard'),
            ),
            const SizedBox(height: 28),
            _buildButton(
              context,
              'Expert',
              () => Navigator.pushNamed(context, '/tictactoe_expert'),
              true, // Make this button different
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed,
      [bool isDifferent = false]) {
    final buttonStyle = ElevatedButton.styleFrom(
        primary: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: const StadiumBorder(),
        side: BorderSide(
          width: 1.0,
          color: Colors.purpleAccent.withOpacity(0.3),
        ),
        elevation: 20.0,
        shadowColor: isDifferent
            ? Colors.pink.withOpacity(0.9)
            : Color.fromARGB(255, 21, 125, 211));

    final gradient = isDifferent
        ? LinearGradient(
            colors: [
              Colors.pink.withOpacity(0.5),
              Colors.pink.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              boardBorderColor.withOpacity(0.5),
              PrimaryColor.withOpacity(0.3),
              boardBorderColor.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return SizedBox(
      width: 200, // Fixed width for all buttons
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: gradient,
        ),
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.blueAccent.withOpacity(0.9),
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
