import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/screens/create_room_screen.dart';
import 'package:tictactoe_mp/screens/difficulty_level_selection_screen.dart';
import 'package:tictactoe_mp/screens/game_screen.dart';
import 'package:tictactoe_mp/screens/join_room_screen.dart';
import 'package:tictactoe_mp/screens/main_menu_game_modes_screen.dart';
import 'package:tictactoe_mp/screens/main_menu_screen.dart';
import 'package:tictactoe_mp/utils/colors.dart';
import 'package:tictactoe_mp/views/single_tictactoe_hard.dart';
import 'package:tictactoe_mp/views/single_tictactoe_medium.dart';
import 'package:tictactoe_mp/views/single_tictactoe_unbeatable.dart';
import 'package:tictactoe_mp/views/single_tictactoe_easy.dart';
import 'package:tictactoe_mp/views/test.dart';
import 'package:tictactoe_mp/views/tictactoe_offline_multiplayer.dart';

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
        theme: ThemeData(scaffoldBackgroundColor: bgColor, fontFamily: 'Beon'),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 0.9),
            child: child!,
          );
        },
        routes: {
          MainMenuScreen.routeName: (context) => const MainMenuScreen(),
          MainMenuGameModesScreen.routeName: (context) =>
              const MainMenuGameModesScreen(),
          DifficultyLevelSelectionScreen.routeName: (context) =>
              const DifficultyLevelSelectionScreen(),
          TicTacToeGameEasy.routeName: (context) => const TicTacToeGameEasy(),
          TicTacToeGameMedium.routeName: (context) =>
              const TicTacToeGameMedium(),
          TicTacToeGameHard.routeName: (context) => const TicTacToeGameHard(),
          TicTacToeGameUnbeatable.routeName: (context) =>
              const TicTacToeGameUnbeatable(),
          TicTacToeGameOfflineMultiplayer.routeName: (context) =>
              const TicTacToeGameOfflineMultiplayer(),
          TicTacToeGameOfflineMultiplayerTest.routeName: (context) =>
              const TicTacToeGameOfflineMultiplayerTest(),
          JoinRoomScreen.routeName: (context) => const JoinRoomScreen(),
          CreateRoomScreen.routeName: (context) => const CreateRoomScreen(),
          GameScreen.routeName: (context) => const GameScreen(),
        },
        initialRoute: TicTacToeGameOfflineMultiplayerTest.routeName,
      ),
    );
  }
}
