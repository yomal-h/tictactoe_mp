import 'package:flutter/material.dart';
import 'dart:math';

class TicTacToeGameEasy extends StatefulWidget {
  static String routeName = '/tictactoe_easy';

  const TicTacToeGameEasy({Key? key}) : super(key: key);

  @override
  __TicTacToeGameEasyState createState() => __TicTacToeGameEasyState();
}

class __TicTacToeGameEasyState extends State<TicTacToeGameEasy> {
  final List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  int _playerScore = 0;
  int _computerScore = 0;
  int _round = 1;
  bool _gameOver = false;
  bool _isComputerThinking = false;

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
                'Player: $_playerScore',
                style: TextStyle(fontSize: 24.0),
              ),
              SizedBox(width: 32.0),
              Text(
                'Computer: $_computerScore',
                style: TextStyle(fontSize: 24.0),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            shrinkWrap: true,
            itemCount: _board.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  if (_isComputerThinking || _gameOver || _board[index] != '') {
                    return;
                  }
                  setState(() {
                    _board[index] = _currentPlayer;
                    _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
                    if (_checkForWinner(_board, 'X')) {
                      _playerScore++;
                      _startNewRound();
                    } else if (_checkForWinner(_board, 'O')) {
                      _computerScore++;
                      _startNewRound();
                    } else if (_board.every((element) => element != '')) {
                      _startNewRound();
                    } else {
                      _isComputerThinking = true;
                      Future.delayed(Duration(seconds: 1), () {
                        setState(() {
                          _makeComputerMove();
                          _isComputerThinking = false;
                        });
                      });
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
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

  //Easy mode
  void _makeComputerMove() {
    // Choose the center if it's available
    if (_board[4] == '') {
      _board[4] = 'O';
    } else {
      // Choose a random corner if one is available
      List<int> corners = [0, 2, 6, 8];
      List<int> availableCorners =
          corners.where((corner) => _board[corner] == '').toList();
      if (availableCorners.isNotEmpty) {
        int randomCorner =
            availableCorners[Random().nextInt(availableCorners.length)];
        _board[randomCorner] = 'O';
      } else {
        // Choose a random side if one is available
        List<int> sides = [1, 3, 5, 7];
        List<int> availableSides =
            sides.where((side) => _board[side] == '').toList();
        int randomSide =
            availableSides[Random().nextInt(availableSides.length)];
        _board[randomSide] = 'O';
      }
    }

    if (_checkForWinner(_board, 'O')) {
      _computerScore++;
      _startNewRound();
    } else if (_board.every((element) => element != '')) {
      _startNewRound();
    } else {
      _currentPlayer = 'X';
    }
  }

  int _minimax(List<String> board, int depth, bool isMaximizing) {
    if (_checkForWinner(board, 'O')) {
      return 10 - depth;
    } else if (_checkForWinner(board, 'X')) {
      return depth - 10;
    } else if (board.every((element) => element != '')) {
      return 0;
    }

    int bestScore = isMaximizing ? -1000 : 1000;
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = isMaximizing ? 'O' : 'X';
        int score = _minimax(board, depth + 1, !isMaximizing);
        board[i] = '';
        if (isMaximizing) {
          if (score > bestScore) {
            bestScore = score;
          }
        } else {
          if (score < bestScore) {
            bestScore = score;
          }
        }
      }
    }
    return bestScore;
  }

  bool _checkForWinner(List<String> board, String player) {
    // check rows
    for (int i = 0; i < 9; i += 3) {
      if (board[i] == player &&
          board[i + 1] == player &&
          board[i + 2] == player) {
        return true;
      }
    }

    // check columns
    for (int i = 0; i < 3; i++) {
      if (board[i] == player &&
          board[i + 3] == player &&
          board[i + 6] == player) {
        return true;
      }
    }

    // check diagonals
    if (board[0] == player && board[4] == player && board[8] == player) {
      return true;
    }
    if (board[2] == player && board[4] == player && board[6] == player) {
      return true;
    }

    return false;
  }

  void _startNewRound() {
    String winner = _checkForWinner(_board, 'X')
        ? 'Player'
        : _checkForWinner(_board, 'O')
            ? 'Computer'
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
                  Navigator.of(context).pop();
                  setState(() {
                    _board.fillRange(0, 9, '');
                    _currentPlayer = 'X';
                    _round++;
                    _gameOver = false;
                    if (winner == 'Player') {
                      // _playerScore++;
                    } else if (winner == 'Computer') {
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
    });
  }

  void _showWinner() {
    String winner = '';
    if (_playerScore > _computerScore) {
      winner = 'Player';
    } else if (_computerScore > _playerScore) {
      winner = 'Computer';
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
