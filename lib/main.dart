import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/screens/create_room_screen.dart';
import 'package:tictactoe_mp/screens/game_screen.dart';
import 'package:tictactoe_mp/screens/join_room_screen.dart';
import 'package:tictactoe_mp/screens/main_menu_screen.dart';
import 'package:tictactoe_mp/utils/colors.dart';
import 'package:tictactoe_mp/views/single_tictactoe_unbeatable.dart';
import 'package:tictactoe_mp/views/single_tictactoe_easy.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RoomDataProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: bgColor),
        routes: {
          MainMenuScreen.routeName: (context) => const MainMenuScreen(),
          TicTacToeGameEasy.routeName: (context) => const TicTacToeGameEasy(),
          TicTacToeGame.routeName: (context) => const TicTacToeGame(),
          JoinRoomScreen.routeName: (context) => const JoinRoomScreen(),
          CreateRoomScreen.routeName: (context) => const CreateRoomScreen(),
          GameScreen.routeName: (context) => const GameScreen(),
        },
        initialRoute: TicTacToeGameEasy.routeName,
      ),
    );
  }
}
