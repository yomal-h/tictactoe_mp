import 'dart:ui';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io' show Platform;

import 'package:tictactoe_mp/utils/colors.dart';

class TicTacToeGameOfflineMultiplayerTest extends StatefulWidget {
  static String routeName = '/tictactoe_offline_multiplayer1';

  const TicTacToeGameOfflineMultiplayerTest({Key? key}) : super(key: key);

  @override
  __TicTacToeGameOfflineMultiplayerStateTest createState() =>
      __TicTacToeGameOfflineMultiplayerStateTest();
}

class __TicTacToeGameOfflineMultiplayerStateTest
    extends State<TicTacToeGameOfflineMultiplayerTest>
    with TickerProviderStateMixin {
  final List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  int _playerScore = 0;
  int _computerScore = 0;
  int _round = 1;
  bool _gameOver = false;
  final bool _isComputerThinking = false;
  List<int> _winningLine = [];
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.3).animate(_rotateController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 90.0), //55 for android and //90 for ios
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: boardBorderColor.withOpacity(0.6),
                    spreadRadius: 4,
                    blurRadius: 7,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Round $_round',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 40, color: boardBorderColor)
                      ]),
                ),
              ),
            ),
          ),
          SizedBox(height: 50.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    Text(
                      'Player 1',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 40, color: boardBorderColor)
                          ]),
                    ),
                    Text(
                      '$_playerScore',
                      style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 40, color: boardBorderColor)
                          ]),
                    ),
                  ],
                ),
              ),
              Text(
                '   :   ',
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 40, color: Colors.purpleAccent)
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    Text(
                      'Player 2',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 40, color: Colors.purpleAccent)
                          ]),
                    ),
                    Text(
                      '$_computerScore',
                      style: const TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 40, color: boardBorderColor)
                          ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.0),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: EdgeInsets.all(
                    Platform.isIOS ? 5 : 10), //10 for android and 5 for ios
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  double fontSize1 = constraints.maxWidth / 4.5;

                  return Stack(
                    children: [
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        shrinkWrap: true,
                        itemCount: _board.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              if (_gameOver || _board[index] != '') {
                                return;
                              }
                              setState(() {
                                _board[index] = _currentPlayer;
                                if (_checkForWinner(_board, 'X')) {
                                  _playerScore++;
                                  _controller.repeat(reverse: true);
                                  _rotateController.repeat(reverse: true);
                                  _startNewRound();
                                } else if (_checkForWinner(_board, 'O')) {
                                  _computerScore++;
                                  _controller.repeat(reverse: true);
                                  _rotateController.repeat(reverse: true);
                                  _startNewRound();
                                } else if (_board
                                    .every((element) => element != '')) {
                                  _startNewRound();
                                } else {
                                  _currentPlayer =
                                      _currentPlayer == 'X' ? 'O' : 'X';
                                }
                              });
                            },
                            child: Transform.translate(
                              offset: Offset(
                                0.0,
                                _winningLine.contains(index)
                                    ? -_shakeAnimation.value
                                    : 0.0,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _winningLine.contains(index)
                                        ? Colors.purple
                                        : boardBorderColor.withOpacity(0.3),
                                    width: _winningLine.contains(index)
                                        ? 5.0
                                        : 1.0, // Default border width is 1.0
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: PrimaryColor.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 10,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    child: Transform.scale(
                                      scale: _winningLine.contains(index)
                                          ? _scaleAnimation.value
                                          : 1.0,
                                      child: Text(
                                        _board[index],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: fontSize1,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 40,
                                                color: _board[index] == 'O'
                                                    ? Colors.greenAccent
                                                    : Colors.pink,
                                              ),
                                            ]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          _gameOver
              ? ElevatedButton(
                  child: Text('New Game'),
                  onPressed: _startNewGame,
                )
              : SizedBox.shrink(),
          _isComputerThinking
              ? Text(
                  'Computer is thinking...',
                  style: TextStyle(fontSize: 20.0),
                )
              : SizedBox.shrink(),
          _gameOver
              ? SizedBox.shrink()
              : Text(
                  'Current player: $_currentPlayer',
                  style: TextStyle(fontSize: 23.0, shadows: [
                    Shadow(blurRadius: 40, color: boardBorderColor)
                  ]),
                ),
          SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  onPressed: _startNewGame,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: InkWell(
                      splashColor: boardBorderColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      onTap: _startNewGame,
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('Main Menu'),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    textStyle: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  onPressed: _startNewGame,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: InkWell(
                      splashColor: boardBorderColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      onTap: _startNewGame,
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('Reset'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: Platform.isIOS ? 40 : 2, //2 for android
          ),
        ],
      ),
    );
  }

  bool _checkForWinner(List<String> board, String symbol) {
    // Check rows
    for (int i = 0; i < 9; i += 3) {
      if (board[i] == symbol &&
          board[i + 1] == symbol &&
          board[i + 2] == symbol) {
        _winningLine = [i, i + 1, i + 2];

        return true;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[i] == symbol &&
          board[i + 3] == symbol &&
          board[i + 6] == symbol) {
        _winningLine = [i, i + 3, i + 6];
        return true;
      }
    }

    // Check diagonals
    if (board[0] == symbol && board[4] == symbol && board[8] == symbol) {
      _winningLine = [0, 4, 8];
      return true;
    }
    if (board[2] == symbol && board[4] == symbol && board[6] == symbol) {
      _winningLine = [2, 4, 6];
      return true;
    }

    return false;
  }

  void _startNewRound() {
    String winner = _checkForWinner(_board, 'X')
        ? 'Player 1'
        : _checkForWinner(_board, 'O')
            ? 'Player 2'
            : 'Tie';

    if (_round > 2) {
      // Game is over

      _showWinner();
    } else {
      // Round is over
      String dialogTitle = 'Round $_round Result';
      String dialogContent = '';

      if (winner == 'Tie') {
        dialogContent = 'The round was a tie!';
      } else {
        dialogContent = '$winner won the round!';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(dialogTitle),
            content: Text(dialogContent),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  _winningLine.clear();
                  Navigator.of(context).pop();
                  setState(() {
                    _board.fillRange(0, 9, '');
                    //_currentPlayer = 'X';
                    _round++;
                    _gameOver = false;
                    if (winner == 'Player 1') {
                      // _playerScore++;
                      _controller.stop();
                      _controller.reset();
                      _rotateController.stop();
                      _rotateController.reset();
                      _currentPlayer = 'O';
                    } else if (winner == 'Player 2') {
                      // _computerScore++;
                      _controller.stop();
                      _controller.reset();
                      _rotateController.stop();
                      _rotateController.reset();
                      _currentPlayer = 'X';
                    }
                  });
                },
              ),
            ],
          );
        },
      );
    }

    _gameOver = true;
  }

  void _startNewGame() {
    setState(() {
      _board.fillRange(0, 9, '');
      _playerScore = 0;
      _computerScore = 0;
      _round = 1;
      _gameOver = false;
      _currentPlayer = 'X';
      _winningLine.clear();
      _controller.stop();
      _controller.reset();
      _rotateController.stop();
      _rotateController.reset();
    });
  }

  void _showWinner() {
    String winner = '';
    if (_playerScore > _computerScore) {
      winner = 'Player 1';
    } else if (_computerScore > _playerScore) {
      winner = 'Player 2';
    } else {
      winner = 'Nobody';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('The winner is $winner!'),
          actions: [
            ElevatedButton(
                child: Text('New Game'),
                onPressed: () {
                  _startNewGame();
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
    _gameOver = true;
  }
}