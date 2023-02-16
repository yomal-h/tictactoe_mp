import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/resources/game_methods.dart';
import 'package:tictactoe_mp/resources/socket_client.dart';
import 'package:tictactoe_mp/resources/socket_methods.dart';

class TicTacToeBoard extends StatefulWidget {
  const TicTacToeBoard({Key? key}) : super(key: key);

  @override
  State<TicTacToeBoard> createState() => _TicTacToeBoardState();
}

class _TicTacToeBoardState extends State<TicTacToeBoard> {
  final SocketMethods _socketMethods = SocketMethods();
  final GlobalKey _key = GlobalKey();
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  void tappedListener(BuildContext context) {
    _socketClient.on('tapped', (data) {
      BuildContext? newContext = _key.currentContext;
      if (newContext == null) {
        return;
      }
      RoomDataProvider roomDataProvider =
          Provider.of<RoomDataProvider>(newContext, listen: false);

      roomDataProvider.updateDisplayElements(
        data['index'],
        data['choice'],
      );
      roomDataProvider.updateRoomData(data['room']);
      //check winner
      GameMethods().checkWinner(newContext, _socketClient);
    });
  }

  @override
  void initState() {
    super.initState();
    //_socketMethods.tappedListener(context);
    tappedListener(context);
  }

  @override
  void dispose() {
    _socketClient.off('tapped');

    // TODO: implement dispose
    super.dispose();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _socketMethods.updateRoomListener(context);
  //   _socketMethods.updatePlayersStateListener(context);
  //   _socketMethods.pointIncreaseListener(context);
  //   _socketMethods.endGameListener(context);
  // }

  void tapped(int index, RoomDataProvider roomDataProvider) {
    _socketMethods.tapGrid(index, roomDataProvider.roomData['_id'],
        roomDataProvider.displayElements, roomDataProvider.filledBoxes);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);

    return ConstrainedBox(
      key: _key,
      constraints: BoxConstraints(
        maxHeight: size.height * 0.7,
        maxWidth: 500,
      ),
      //to make relevent turn when checking boxxess using devices
      child: AbsorbPointer(
        absorbing: roomDataProvider.roomData['turn']['socketID'] !=
            _socketMethods.socketClient.id,
        child: GridView.builder(
          itemCount: 9,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => tapped(index, roomDataProvider),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white24,
                  ),
                ),
                child: Center(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      roomDataProvider.displayElements[index],
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 100,
                          shadows: [
                            Shadow(
                              blurRadius: 40,
                              color:
                                  roomDataProvider.displayElements[index] == 'O'
                                      ? Colors.red
                                      : Colors.blue,
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
