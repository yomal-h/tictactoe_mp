import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/resources/game_methods.dart';
import 'package:tictactoe_mp/resources/socket_client.dart';
import 'package:tictactoe_mp/screens/game_screen.dart';
import 'package:tictactoe_mp/screens/main_menu_screen.dart';
import 'package:tictactoe_mp/utils/utils.dart';
import 'package:tictactoe_mp/views/tictactoe_board.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;
  Socket? socket;
  bool isUpdatingRound = false;

  // EMITS
  void createRoom(String nickname) {
    if (nickname.isNotEmpty) {
      _socketClient.emit('createRoom', {
        'nickname': nickname,
      });
    }
    SocketClient.instance.connect();
  }

  void joinRoom(String nickname, String roomId) {
    if (nickname.isNotEmpty && roomId.isNotEmpty) {
      _socketClient.emit('joinRoom', {
        'nickname': nickname,
        'roomId': roomId,
      });
    }

    SocketClient.instance.connect();
  }

//index is the element that user clicks on the board
  void tapGrid(
      int index, String roomId, List<String> displayElements, int filledBoxes) {
    if (displayElements[index] == '') {
      _socketClient.emit('tap', {
        'index': index,
        'roomId': roomId,
      });

      filledBoxes++;
      // Print the number of filled boxes after each tap
      print('Filled boxes after each tap: $filledBoxes');
    }

    print(index);
    print(roomId);
  }

  // LISTENERS
  void createRoomSuccessListener(BuildContext context) {
    _socketClient.on('createRoomSuccess', (room) {
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(room);

      Navigator.pushNamed(context, GameScreen.routeName);
    });
  }

  void joinRoomSuccessListener(BuildContext context) {
    _socketClient.on('joinRoomSuccess', (room) {
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(room);
      Navigator.pushNamed(context, GameScreen.routeName);
    });
  }

  void errorOccuredListener(BuildContext context) {
    _socketClient.on('errorOccurred', (data) {
      showSnackBar(context, data);
    });
  }

  void updatePlayersStateListener(BuildContext context) {
    _socketClient.on('updatePlayers', (playerData) {
      Provider.of<RoomDataProvider>(context, listen: false).updatePlayer1(
        playerData[0],
      );
      Provider.of<RoomDataProvider>(context, listen: false).updatePlayer2(
        playerData[1],
      );
    });
  }

  void updateRoomListener(BuildContext context) {
    _socketClient.on('updateRoom', (data) {
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateRoomData(data);
      print(data);
    });
  }

  void pointIncreaseListener(
    BuildContext context,
  ) {
    _socketClient.on('pointIncrease', (playerData) {
      var roomDataProvider =
          Provider.of<RoomDataProvider>(context, listen: false);

      if (playerData['socketID'] == roomDataProvider.player1.socketID) {
        roomDataProvider.updatePlayer1(playerData);
      } else {
        roomDataProvider.updatePlayer2(playerData);
      }
    });
  }

  void increaseCurrentRoundListener(
    BuildContext context,
  ) {
    _socketClient.on('roundIncrease', (data) {
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateCurrentRound(data['currentRound']);
    });
  }

  void increaseCurrentRound(String roomId) {
    //gets room id with 'roomId'
    //backend code increases the round after

    _socketClient.emit('roundIncrease', {'roomId': roomId});
  }

  // void endGameListener(BuildContext context) {

  //   _socketClient.on('endGame', (playerData) {
  //     //final gameState = Provider.of<RoomDataProvider>(context, listen: false);
  //     //_socketClient.emit('reset', {'id': 'roomId'});
  //     //gameState.reset();
  //     Navigator.pop(context);
  //     // Navigator.pushReplacement(
  //     //   context,
  //     //   MaterialPageRoute(
  //     //     builder: (context) => const MainMenuScreen(),
  //     //   ),
  //     // );
  //     // Navigator.pushNamed(context, MainMenuScreen.routeName);//working

  //     showEndGameDialog(context, '${playerData['nickname']}');
  //     //Navigator.popUntil(context, ModalRoute.withName('/main_menu'));
  //     //Navigator.popUntil(context, (route) => false);
  //   });
  // }
}
