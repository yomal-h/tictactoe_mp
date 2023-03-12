import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

import 'package:tictactoe_mp/utils/colors.dart';
import 'package:tictactoe_mp/widgets/custom_flickering_menu_text.dart';

class MainMenuGameModesScreen extends StatelessWidget {
  static const routeName = '/main_menu_game_modes_screen';
  const MainMenuGameModesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlickeringText(),
            const SizedBox(height: 48),
            _buildButton(
              context,
              'SinglePlayer',
              Icons.person,
              () => Navigator.pushNamed(context, '/single-player'),
            ),
            const SizedBox(height: 24),
            _buildButton(
              context,
              'Multiplayer Offline',
              Icons.people,
              () => Navigator.pushNamed(context, '/multiplayer-offline'),
            ),
            const SizedBox(height: 24),
            _buildButton(
              context,
              'Multiplayer Online',
              FontAwesome5.globe,
              () => Navigator.pushNamed(context, '/multiplayer-online'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Entypo.info_circled,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon,
      VoidCallback onPressed) {
    final buttonStyle = ElevatedButton.styleFrom(
      primary: Colors.white.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: const StadiumBorder(),
    );

    return SizedBox(
      width: 300, // Fixed width for all buttons
      child: ElevatedButton.icon(
        style: buttonStyle,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text,
            style: const TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}
