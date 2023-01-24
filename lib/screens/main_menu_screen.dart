// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tictactoe_mp/responsive/responsive.dart';
import 'package:tictactoe_mp/screens/create_room_screen.dart';
import 'package:tictactoe_mp/screens/join_room_screen.dart';
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
    return Scaffold(
        body: Responsive(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButton(
            onTap: () => createRoom(context),
            text: 'Create Room',
          ),
          const SizedBox(
            height: 20,
          ),
          CustomButton(
            onTap: () => joinRoom(context),
            text: 'Join Room',
          ),
        ],
      ),
    ));
  }
}
