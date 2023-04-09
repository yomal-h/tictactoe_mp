// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tictactoe_mp/responsive/responsive.dart';
import 'package:tictactoe_mp/screens/create_room_screen.dart';
import 'package:tictactoe_mp/screens/join_room_screen.dart';
import 'package:tictactoe_mp/utils/colors.dart';
import 'package:tictactoe_mp/widgets/custom_button.dart';

class MainMenuScreen extends StatelessWidget {
  static String routeName = '/main_menu';
  const MainMenuScreen({Key? key}) : super(key: key);

  void createRoom(BuildContext context) {
    Navigator.pushNamed(context, CreateRoomScreen.routeName);
  }

  void joinRoom(BuildContext context) {
    Navigator.pushNamed(context, JoinRoomScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onHorizontalDragUpdate: (_) {},
        child: Scaffold(
          backgroundColor: bgColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 55),
                _buildButton(
                  context,
                  'Host Match',
                  () => createRoom(context),
                ),
                const SizedBox(height: 28),
                _buildButton(
                  context,
                  'Join Match',
                  () => joinRoom(context),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
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
      width: 250, // Fixed width for all buttons
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



//  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Responsive(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CustomButton(
//             onTap: () => createRoom(context),
//             text: 'Create Room',
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           CustomButton(
//             onTap: () => joinRoom(context),
//             text: 'Join Room',
//           ),
//         ],
//       ),
//     ));
//   }
