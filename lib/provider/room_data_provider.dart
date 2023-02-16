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
  Player get player1 => _player1;
  Player get player2 => _player2;

  void updateRoomData(Map<String, dynamic> data) {
    _roomData = data;
    notifyListeners();
  }

  void navigateToMainMenu(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/main-menu');
  }

  void reset() {
    Future.delayed(Duration.zero, () {
      //_roomData = {};
      _displayElement = ['', '', '', '', '', '', '', '', ''];
      setFilledBoxesTo0();
      _player1 = Player(nickname: '', socketID: '', points: 0, playerType: 'X');
      _player2 = Player(nickname: '', socketID: '', points: 0, playerType: 'O');
      print("RESET METHOD");
      print("Filled boxes before reset: $_filledBoxes");

      print("Filled boxes after reset: $_filledBoxes");
      notifyListeners();
      SocketClient.instance.disconnect(); // Disconnect socket
    });
  }

  void resetDisplayElements() {
    _displayElement = List.filled(9, '');
    _filledBoxes = 0;
    notifyListeners();
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
