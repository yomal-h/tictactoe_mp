import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/resources/socket_methods.dart';
import 'package:tictactoe_mp/screens/create_room_screen.dart';
import 'package:tictactoe_mp/screens/difficulty_level_selection_screen.dart';
import 'package:tictactoe_mp/screens/game_screen.dart';
import 'package:tictactoe_mp/screens/info_screen.dart';
import 'package:tictactoe_mp/screens/join_room_screen.dart';
import 'package:tictactoe_mp/screens/main_menu_game_modes_screen.dart';
import 'package:tictactoe_mp/screens/main_menu_screen.dart';

import 'package:tictactoe_mp/screens/settings_screen.dart';
import 'package:tictactoe_mp/utils/colors.dart';
import 'package:tictactoe_mp/views/single_tictactoe_expert.dart';
import 'package:tictactoe_mp/views/single_tictactoe_hard.dart';
import 'package:tictactoe_mp/views/single_tictactoe_medium.dart';
import 'package:tictactoe_mp/views/single_tictactoe_easy.dart';
import 'package:tictactoe_mp/views/tictactoe_board.dart';
import 'package:tictactoe_mp/views/tictactoe_offline_multiplayer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  //may encounter an error in the didChangeAppLifecycleState method because
  //if using the context parameter, which may be null if it's called before the build method.
  //To solve this,
  // a global key to access the provider outside the build method was used.
  late final RoomDataProvider roomProvider;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    //WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);

  //   if (state == AppLifecycleState.resumed) {
  //     roomProvider.playMusic();
  //     // App is resumed from the background
  //   } else if (state == AppLifecycleState.inactive) {
  //     roomProvider.stopAudio();
  //     // App is no longer the active app
  //   } else if (state == AppLifecycleState.paused) {
  //     roomProvider.stopAudio();
  //     // App is in the background
  //   } else if (state == AppLifecycleState.detached) {
  //     roomProvider.stopAudio();
  //     // App state is detached from the host
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        roomProvider = RoomDataProvider();
        return roomProvider;
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(scaffoldBackgroundColor: bgColor, fontFamily: 'Beon'),
        navigatorKey: navigatorKey,
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
          TicTacToeGameExpert.routeName: (context) =>
              const TicTacToeGameExpert(),
          TicTacToeGameOfflineMultiplayer.routeName: (context) =>
              const TicTacToeGameOfflineMultiplayer(),
          JoinRoomScreen.routeName: (context) => const JoinRoomScreen(),
          CreateRoomScreen.routeName: (context) => const CreateRoomScreen(),
          GameScreen.routeName: (context) => const GameScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
          InfoScreen.routeName: (context) => const InfoScreen(),
        },
        initialRoute: MainMenuGameModesScreen.routeName,
      ),
    );
  }
}
