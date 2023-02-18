// ignore_for_file: prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:tictactoe_mp/models/player.dart';
import 'package:tictactoe_mp/resources/socket_client.dart';

class RoomDataProvider extends ChangeNotifier {
  Map<String, dynamic> _roomData = {};
  List<String> _displayElement = ['', '', '', '', '', '', '', '', ''];
  int _filledBoxes = 0;
  Player _player1 =
      Player(nickname: '', socketID: '', points: 0, playerType: 'X');

  Player _player2 =
      Player(nickname: '', socketID: '', points: 0, playerType: 'O');

  Map<String, dynamic> get roomData => _roomData;
  List<String> get displayElements => _displayElement;
  int get filledBoxes => _filledBoxes;
  List<int> get winningLine => getWinningLine();
  Player get player1 => _player1;
  Player get player2 => _player2;

  // Returns the indices of the boxes that form the winning line based on the current displayElements.
  List<int> getWinningLine() {
    // Check for horizontal lines
    for (var i = 0; i < 9; i += 3) {
      if (_displayElement[i].isNotEmpty &&
          _displayElement[i] == _displayElement[i + 1] &&
          _displayElement[i + 1] == _displayElement[i + 2]) {
        return [i, i + 1, i + 2];
      }
    }

    // Check for vertical lines
    for (var i = 0; i < 3; i++) {
      if (_displayElement[i].isNotEmpty &&
          _displayElement[i] == _displayElement[i + 3] &&
          _displayElement[i + 3] == _displayElement[i + 6]) {
        return [i, i + 3, i + 6];
      }
    }

    // Check for diagonal lines
    if (_displayElement[0].isNotEmpty &&
        _displayElement[0] == _displayElement[4] &&
        _displayElement[4] == _displayElement[8]) {
      return [0, 4, 8];
    }
    if (_displayElement[2].isNotEmpty &&
        _displayElement[2] == _displayElement[4] &&
        _displayElement[4] == _displayElement[6]) {
      return [2, 4, 6];
    }

    // No winning line found
    return [];
  }

  void updateRoomData(Map<String, dynamic> data) {
    _roomData = data;
    notifyListeners();
  }

  void reset() {
    Future.delayed(Duration.zero, () {
      //_roomData = {};
      _displayElement = ['', '', '', '', '', '', '', '', ''];
      setFilledBoxesTo0();
      _player1 = Player(nickname: '', socketID: '', points: 0, playerType: 'X');
      _player2 = Player(nickname: '', socketID: '', points: 0, playerType: 'O');
      print("RESET METHOD");
      // print("Filled boxes before reset: $_filledBoxes");

      notifyListeners();
      SocketClient.instance.disconnect(); // Disconnect socket
    });
  }

  void updatePlayer1(Map<String, dynamic> player1Data) {
    _player1 = Player.fromMap(player1Data);
    notifyListeners();
  }

  void updatePlayer2(Map<String, dynamic> player2Data) {
    _player2 = Player.fromMap(player2Data);
    notifyListeners();
  }

  void updateDisplayElements(int index, String choice) {
    _displayElement[index] = choice;
    _filledBoxes += 1; //checks how many boxes filled
    notifyListeners();
  }

  void setFilledBoxesTo0() {
    _filledBoxes = 0;
    print("Set filledboxes to ZERO");
  }
}
