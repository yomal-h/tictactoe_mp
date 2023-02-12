import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/resources/socket_methods.dart';
import 'package:tictactoe_mp/views/scoreboard.dart';
import 'package:tictactoe_mp/views/tictactoe_board.dart';
import 'package:tictactoe_mp/views/waiting_lobby.dart';

class GameScreen extends StatefulWidget {
  static String routeName = '/game';
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final SocketMethods _socketMethods = SocketMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _socketMethods.updateRoomListener(context);
    _socketMethods.updatePlayersStateListener(context);
    _socketMethods.pointIncreaseListener(context);
    _socketMethods.endGameListener(context);
  }

  @override
  Widget build(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);
    //print(Provider.of<RoomDataProvider>(context).player1.nickname);
    //print(Provider.of<RoomDataProvider>(context).player2.nickname);

    return Scaffold(
        body: roomDataProvider.roomData.containsKey('isJoin')
            ? roomDataProvider.roomData['isJoin']
                ? const WaitingLobby()
                : SafeArea(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const Scoreboard(),
                      const TicTacToeBoard(),
                      Text(
                          '${roomDataProvider.roomData['turn']['nickname']}\'s turn'),
                    ],
                  ))
            : Container());
  }
}
