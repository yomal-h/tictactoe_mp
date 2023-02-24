import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

class TicTacToeGameOfflineMultiplayer extends StatefulWidget {
  static String routeName = '/tictactoe_offline_multiplayer';

  const TicTacToeGameOfflineMultiplayer({Key? key}) : super(key: key);

  @override
  __TicTacToeGameOfflineMultiplayerState createState() =>
      __TicTacToeGameOfflineMultiplayerState();
}

class __TicTacToeGameOfflineMultiplayerState
    extends State<TicTacToeGameOfflineMultiplayer>
    with SingleTickerProviderStateMixin {
  final List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  int _playerScore = 0;
  int _computerScore = 0;
  int _round = 1;
  bool _gameOver = false;
  bool _isComputerThinking = false;
  List<int> _winningLine = [];
  late AnimationController _animationController;
  late Tween<double> _animationTween;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });
    _animationTween = Tween<double>(begin: 0.0, end: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic-Tac-Toe with Minimax'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Round $_round',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Player 1: $_playerScore',
                style: TextStyle(fontSize: 24.0),
              ),
              SizedBox(width: 32.0),
              Text(
                'Player 2: $_computerScore',
                style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Stack(
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
                        _animationController.reset();
                        _animationController.forward();
                        _board[index] = _currentPlayer;
                        if (_checkForWinner(_board, 'X')) {
                          _playerScore++;
                          _startNewRound();
                        } else if (_checkForWinner(_board, 'O')) {
                          _computerScore++;
                          _startNewRound();
                        } else if (_board.every((element) => element != '')) {
                          _startNewRound();
                        } else {
                          _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _winningLine.contains(index)
                              ? Colors.purple
                              : Colors.white24,
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _board[index],
                          style: TextStyle(fontSize: 48.0),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_gameOver && _winningLine.isNotEmpty)
                Positioned.fill(
                  child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: WinningLinePainter(
                              _winningLine,
                              _animationTween.animate(_animationController),
                              context),
                        );
                      }),
                ),
            ],
          ),
          _gameOver
              ? RaisedButton(
                  child: Text('New Game'),
                  onPressed: _startNewGame,
                )
              : SizedBox.shrink(),
          _isComputerThinking
              ? Text(
                  'Computer is thinking...',
                  style: TextStyle(fontSize: 24.0),
                )
              : SizedBox.shrink(),
          _gameOver
              ? SizedBox.shrink()
              : Text(
                  'Current player: $_currentPlayer',
                  style: TextStyle(fontSize: 24.0),
                ),
        ],
      ),
    );
  }

  void _winnercheckandnextround() {
    if (_checkForWinner(_board, 'O')) {
      _computerScore++;
      _startNewRound();
    } else if (_board.every((element) => element != '')) {
      _startNewRound();
    } else {
      _currentPlayer = 'X';
    }
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
        _animationController
            .reset(); //use these two otherwise A.I animation will not work
        _animationController.forward();
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
                    _currentPlayer = 'X';
                    _round++;
                    _gameOver = false;
                    if (winner == 'Player 1') {
                      // _playerScore++;
                    } else if (winner == 'Player 2') {
                      // _computerScore++;
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
    });
  }

  void _showWinner() {
    String winner = '';
    if (_playerScore > _computerScore) {
      winner = 'Player 1';
      _animationController.reset();
      _animationController.forward();
    } else if (_computerScore > _playerScore) {
      winner = 'Player 2';
      _animationController.reset();
      _animationController.forward();
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

class WinningLinePainter extends CustomPainter {
  final List<int> _winningLine;
  final Animation<double> _animation;
  BuildContext _context;
  WinningLinePainter(this._winningLine, this._animation, this._context);

  @override
  void paint(Canvas canvas, Size size) {
    if (_winningLine.isEmpty) {
      return;
    }

    Paint paint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 5.0;

    double boxSize = MediaQuery.of(_context).size.width / 3;
    double startx = _winningLine[0] % 3 * boxSize + boxSize / 2;
    double starty = _winningLine[0] ~/ 3 * boxSize + boxSize / 2;
    double endx = _winningLine.last % 3 * boxSize + boxSize / 2;
    double endy = _winningLine.last ~/ 3 * boxSize + boxSize / 2;

    double dx = (endx - startx) * _animation.value;
    double dy = (endy - starty) * _animation.value;

    canvas.drawLine(
      Offset(startx, starty),
      Offset(startx + dx, starty + dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(WinningLinePainter oldDelegate) {
    return _winningLine != oldDelegate._winningLine ||
        _animation != oldDelegate._animation;
  }
}
