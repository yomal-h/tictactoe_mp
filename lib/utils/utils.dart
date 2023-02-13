import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/resources/game_methods.dart';
import 'package:tictactoe_mp/screens/main_menu_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

void showGameDialog(BuildContext context, String text) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                GameMethods().clearBoard(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Play Again',
              ),
            ),
          ],
        );
      });
}

void showEndGameDialog(BuildContext context, String text) {
  final gameState = Provider.of<RoomDataProvider>(context, listen: false);
  void navigateToMainMenu(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/main_menu');
  }

  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                //GameMethods().clearBoard(context);
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const MainMenuScreen(),
                //   ),
                // );
                navigateToMainMenu(context);
                // Navigator.pushNamed(
                //   context,
                //   MainMenuScreen.routeName,
                // );
                gameState.reset();

                //Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Main Menu',
              ),
            ),
          ],
        );
      });
}
