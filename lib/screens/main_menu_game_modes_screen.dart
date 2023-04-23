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
            const SizedBox(height: 50),
            FlickeringText(),
            const SizedBox(height: 55),
            _buildButton(
              context,
              'SinglePlayer',
              Icons.person,
              () => Navigator.pushNamedAndRemoveUntil(context,
                  '/difficulty_level_selection_screen', (route) => false),
            ),
            const SizedBox(height: 26),
            _buildButton(
              context,
              'Multiplayer (Offline)',
              Icons.people,
              () => Navigator.pushNamedAndRemoveUntil(
                  context, '/tictactoe_offline_multiplayer', (route) => false),
            ),
            const SizedBox(height: 26),
            _buildButton(
              context,
              'Multiplayer (Online)',
              FontAwesome5.globe,
              () => Navigator.pushNamedAndRemoveUntil(
                  context, '/main_menu', (route) => false),

              true, // Make this button different
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.purple,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        width: 2,
                        color: Colors.purple.withOpacity(0.5),
                      ),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/settings', (route) => false),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.purple,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        width: 2,
                        color: Colors.purple.withOpacity(0.5),
                      ),
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

  Widget _buildButton(
      BuildContext context, String text, IconData icon, VoidCallback onPressed,
      [bool isDifferent = false]) {
    final buttonStyle = ElevatedButton.styleFrom(
        primary: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: const StadiumBorder(),
        side:
            BorderSide(width: 2.0, color: Colors.purpleAccent.withOpacity(0.5)),
        elevation: 20.0,
        shadowColor: isDifferent
            ? Colors.pink.withOpacity(0.9)
            : Color.fromARGB(255, 21, 125, 211));
    //shadowColor: Color.fromARGB(255, 0, 52, 143));
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
      width: 300, // Fixed width for all buttons
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: gradient,
        ),
        child: ElevatedButton.icon(
          style: buttonStyle,
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(
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
//  Widget _buildButton(BuildContext context, String text, IconData icon,
//       VoidCallback onPressed) {
//     final buttonStyle = ElevatedButton.styleFrom(
//       primary: Colors.purpleAccent.withOpacity(0.2),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       shape: const StadiumBorder(),
//       side: BorderSide(
//         color: Colors.red.withOpacity(0.9),
//         width: 2.0,
//         style: BorderStyle.solid,
//       ),
//       elevation: 10.0,
//     );

//     return SizedBox(
//       width: 300, // Fixed width for all buttons
//       child: ElevatedButton.icon(
//         style: buttonStyle,
//         onPressed: onPressed,
//         icon: Icon(icon, color: Colors.white),
//         label: Text(
//           text,
//           style: const TextStyle(
//             fontSize: 24,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }