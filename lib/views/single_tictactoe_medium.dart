import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:tictactoe_mp/utils/colors.dart';

class TicTacToeGameMedium extends StatefulWidget {
  static String routeName = '/tictactoe_medium';

  const TicTacToeGameMedium({Key? key}) : super(key: key);

  @override
  __TicTacToeGameMediumState createState() => __TicTacToeGameMediumState();
}

class __TicTacToeGameMediumState extends State<TicTacToeGameMedium>
    with TickerProviderStateMixin {
  final List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  int _playerScore = 0;
  int _computerScore = 0;
  int _round = 1;
  bool _gameOver = false;
  bool _isComputerThinking = false;
  List<int> _winningLine = [];
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _animationController;
  late Animation<double> _animation;

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

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotateController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height:
                  Platform.isIOS ? 90 : 70), //55 for android and //90 for ios
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
                    offset: Offset(0, 0), // changes position of the shadow
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'MRound $_round',
                  style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    Text(
                      'Player',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 40, color: boardBorderColor)
                          ]),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: boardBorderColor.withOpacity(0.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Text(
                          '$_playerScore',
                          style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                    blurRadius: 40, color: Colors.purpleAccent)
                              ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '   :   ',
                style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 40, color: Colors.purpleAccent)
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    Text(
                      'Computer',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 40, color: Colors.greenAccent)
                          ]),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: boardBorderColor.withOpacity(0.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Text(
                          '$_computerScore',
                          style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                    blurRadius: 40, color: Colors.purpleAccent)
                              ]),
                        ),
                      ),
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
                              if (_isComputerThinking ||
                                  _gameOver ||
                                  _board[index] != '') {
                                return;
                              }
                              setState(() {
                                _board[index] = _currentPlayer;

                                if (_checkForWinner(_board, 'X')) {
                                  _playerScore++;

                                  Future.delayed(Duration(seconds: 3), () {
                                    _controller.stop();
                                    _rotateController.stop();
                                  });
                                  _controller.repeat(reverse: true);
                                  _rotateController.repeat(reverse: true);
                                  _animationController.repeat(reverse: true);
                                  _startNewRound();
                                } else if (_checkForWinner(_board, 'O')) {
                                  _computerScore++;

                                  Future.delayed(Duration(seconds: 3), () {
                                    _controller.stop();
                                    _rotateController.stop();
                                  });
                                  _controller.repeat(reverse: true);
                                  _rotateController.repeat(reverse: true);
                                  _animationController.repeat(reverse: true);
                                  _startNewRound();
                                } else if (_board
                                    .every((element) => element != '')) {
                                  _startNewRound();
                                } else {
                                  _currentPlayer = _currentPlayer == 'X'
                                      ? 'O'
                                      : 'X'; //otherwise current player wont be displayed
                                  _isComputerThinking = true;
                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() {
                                      _makeComputerMove();
                                      _isComputerThinking = false;
                                      if (_checkForWinner(_board, 'O')) {
                                        Future.delayed(Duration(seconds: 3),
                                            () {
                                          _controller.stop();
                                          _rotateController.stop();
                                        });
                                        _controller.repeat(reverse: true);
                                        _rotateController.repeat(reverse: true);
                                        _animationController.repeat(
                                            reverse:
                                                true); //need to add these here, otherwise if computer won the game for thr first time, it wont animate alert dialog symbol animation
                                      }
                                    });
                                  });
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
                                        ? boardBorderColor.withOpacity(
                                            0.5) //winning boxes highlight color
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
          _isComputerThinking
              ? Text(
                  'Computer is thinking...',
                  style: TextStyle(fontSize: 1.0),
                )
              : SizedBox.shrink(),
          _gameOver
              ? SizedBox.shrink()
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: boardBorderColor.withOpacity(0.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          shadows: [
                            Shadow(blurRadius: 40, color: boardBorderColor),
                          ],
                        ),
                        children: [
                          TextSpan(
                            text: 'Current player:  ',
                            style: TextStyle(
                              fontFamily: 'Beon',
                            ),
                          ),
                          TextSpan(
                            text: _currentPlayer,
                            style: TextStyle(
                                fontSize: 24.0,
                                fontFamily: 'Beon',
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  BoxShadow(
                                    color: _currentPlayer == 'X'
                                        ? Colors.pinkAccent.withOpacity(0.8)
                                        : Colors.greenAccent,
                                    blurRadius: 12,
                                    offset: Offset(0, 0),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                  icon: Icon(Icons.home),
                  onPressed: _goToMainMenu,
                  splashRadius: 18,
                  iconSize: 28,
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.white,
                  splashColor: boardBorderColor.withOpacity(0.9),
                  highlightColor: Colors.transparent,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _startNewGame,
                  splashRadius: 18,
                  iconSize: 28,
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.white,
                  splashColor: boardBorderColor.withOpacity(0.9),
                  highlightColor: Colors.transparent,
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

//Prioritize blocking the player's winning moves. In the 'easy' implementation,
//the computer is only making moves randomly,
//without any strategy to block the player.
//this code to check if the player is one move away
//from winning and block that move. To do this, this function
//checks if a given move results in a winning move for the player,
//and use this function to prioritize blocking the player
  int _findBlockingMove() {
    // Check if there's a winning move for the player and block it
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        _board[i] = 'X';
        if (_checkForWinner(_board, 'X')) {
          _board[i] = 'O';
          return i;
        }
        _board[i] = '';
      }
    }
    return -1;
  }

//This function returns a list of the available moves on the current board.
//You can use it in the _makeComputerMove() function to get a list of available moves
//to choose from when making a move.
  List<int> _getAvailableMoves() {
    List<int> availableMoves = [];
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        availableMoves.add(i);
      }
    }
    return availableMoves;
  }

  //Medium mode
  //choose the corners or sides randomly, or with some probability,
  void _makeComputerMove() {
    int blockingMove = _findBlockingMove();

    if (blockingMove != -1) {
      _board[blockingMove] = 'O';
    } else {
      // Randomly choose the next move
      List<int> availableMoves = _getAvailableMoves();
      int randomIndex = Random().nextInt(availableMoves.length);
      int randomMove = availableMoves[randomIndex];
      if (availableMoves.length > 3 && randomIndex == 0) {
        // With 60% probability, choose a random corner instead of the center
        List<int> corners = [0, 2, 6, 8];
        List<int> availableCorners =
            corners.where((corner) => _board[corner] == '').toList();
        if (availableCorners.isNotEmpty && Random().nextInt(10) < 6) {
          int randomCorner =
              availableCorners[Random().nextInt(availableCorners.length)];
          randomMove = randomCorner;
        }
      } else if (availableMoves.length > 1 && randomIndex == 0) {
        // With 60% probability, choose a random side instead of the center
        List<int> sides = [1, 3, 5, 7];
        List<int> availableSides =
            sides.where((side) => _board[side] == '').toList();
        if (availableSides.isNotEmpty && Random().nextInt(10) < 6) {
          int randomSide =
              availableSides[Random().nextInt(availableSides.length)];
          randomMove = randomSide;
        }
      }

      _board[randomMove] = 'O';
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
    } else if (board[2] == symbol && board[4] == symbol && board[6] == symbol) {
      _winningLine = [2, 4, 6];
      return true;
    }

    // No winning line found
    _winningLine = []; //here
    return false;
  }
  //if there is no winning line found, the _winningLine
  // variable is set to an empty list,
  //indicating that there is no winning line to highlight

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

      showGeneralDialog(
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
            return Transform(
              transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
              child: Opacity(
                  opacity: a1.value,
                  child: Dialog(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: PrimaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: boardBorderColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dialogTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                BoxShadow(
                                  color: Colors.pinkAccent.withOpacity(0.8),
                                  blurRadius: 12,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              Color shadowColor = winner == 'Player'
                                  ? Colors.pink
                                  : Colors.green;
                              return Transform.scale(
                                scale: _animation.value,
                                child: winner == 'Tie'
                                    ? SizedBox
                                        .shrink() //text should be added after this otherwise it gives error
                                    : Text(
                                        '${winner == 'Player' ? 'X' : 'O'}',
                                        style: TextStyle(
                                          fontSize: 55,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                                blurRadius: 60,
                                                color: shadowColor)
                                          ],
                                        ),
                                      ),
                              );
                            },
                          ),
                          SizedBox(height: 8),
                          Text(
                            dialogContent,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            child: Text(
                              'OK',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.purple, // background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    18.0), // rounded corner radius
                              ),
                            ),
                            onPressed: () {
                              _winningLine.clear();
                              Navigator.of(context).pop();
                              setState(() {
                                _board.fillRange(0, 9, '');
                                //_currentPlayer = 'X';
                                _round++;
                                _gameOver = false;
                                if (winner == 'Player') {
                                  // _playerScore++;
                                  _controller.stop();
                                  _controller.reset();
                                  _rotateController.stop();
                                  _rotateController.reset();
                                  _currentPlayer = 'O';
                                  _isComputerThinking =
                                      true; //to disable player then add computer's move code
                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() {
                                      _makeComputerMove();
                                      _isComputerThinking = false;
                                    });
                                  });
                                } else if (winner == 'Computer') {
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
                      ),
                    ),
                  )),
            );
          },
          transitionDuration: Duration(milliseconds: 600),
          barrierLabel: '',
          context: context,
          pageBuilder: (context, animation1, animation2) {
            return Dialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: PrimaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: boardBorderColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dialogTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.8),
                            blurRadius: 12,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        Color shadowColor =
                            winner == 'Player' ? Colors.pink : Colors.green;
                        return Transform.scale(
                          scale: _animation.value,
                          child: winner == 'Tie'
                              ? SizedBox
                                  .shrink() //text should be added after this otherwise it gives error
                              : Text(
                                  '${winner == 'Player' ? 'X' : 'O'}',
                                  style: TextStyle(
                                    fontSize: 55,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(blurRadius: 60, color: shadowColor)
                                    ],
                                  ),
                                ),
                        );
                      },
                    ),
                    SizedBox(height: 8),
                    Text(
                      dialogContent,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple, // background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              18.0), // rounded corner radius
                        ),
                      ),
                      onPressed: () {
                        _winningLine.clear();
                        Navigator.of(context).pop();
                        setState(() {
                          _board.fillRange(0, 9, '');
                          //_currentPlayer = 'X';
                          _round++;
                          _gameOver = false;
                          if (winner == 'Player') {
                            // _playerScore++;
                            _controller.stop();
                            _controller.reset();
                            _rotateController.stop();
                            _rotateController.reset();
                            _currentPlayer = 'O';
                          } else if (winner == 'Computer') {
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
                ),
              ),
            );
          });
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

  void _goToMainMenu() {
    Navigator.pushNamed(context, '/main_menu_game_modes_screen');
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
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: Dialog(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: PrimaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: boardBorderColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10),
                      AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText(
                            'Game Over',
                            textStyle: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                BoxShadow(
                                  color: Colors.pinkAccent.withOpacity(0.8),
                                  blurRadius: 12,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                      SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          Color shadowColor =
                              winner == 'Player' ? Colors.pink : Colors.green;
                          return Transform.scale(
                            scale: _animation.value,
                            child: winner == 'Nobody'
                                ? SizedBox
                                    .shrink() //text should be added after this otherwise it gives error
                                : Text(
                                    '${winner == 'Player' ? 'X' : 'O'}',
                                    style: TextStyle(
                                      fontSize: 65,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 60, color: shadowColor)
                                      ],
                                    ),
                                  ),
                          );
                        },
                      ),
                      SizedBox(height: 8),
                      Text(
                        'The winner is',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Colors.pinkAccent,
                                Colors.blue,
                                Colors.pinkAccent
                              ],
                              tileMode: TileMode.mirror,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '$winner',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              child: Text(
                                'Main Menu',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.purple, // background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      18.0), // rounded corner radius
                                ),
                              ),
                              onPressed: () {
                                _goToMainMenu();
                                Navigator.of(context).pop();
                              },
                            ),
                            SizedBox(width: 15),
                            ElevatedButton(
                              child: Text(
                                'New Game',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.purple, // background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      18.0), // rounded corner radius
                                ),
                              ),
                              onPressed: () {
                                _startNewGame();
                                Navigator.of(context).pop();
                              },
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 600),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Dialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: PrimaryColor,
                boxShadow: [
                  BoxShadow(
                    color: boardBorderColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  AnimatedTextKit(
                    animatedTexts: [
                      WavyAnimatedText(
                        'Game Over',
                        textStyle: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.8),
                              blurRadius: 12,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                    isRepeatingAnimation: false,
                  ),
                  SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      Color shadowColor =
                          winner == 'Player' ? Colors.pink : Colors.green;
                      return Transform.scale(
                        scale: _animation.value,
                        child: winner == 'Nobody'
                            ? SizedBox
                                .shrink() //text should be added after this otherwise it gives error
                            : Text(
                                '${winner == 'Player' ? 'X' : 'O'}',
                                style: TextStyle(
                                  fontSize: 65,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(blurRadius: 60, color: shadowColor)
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The winner is',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.pinkAccent,
                            Colors.blue,
                            Colors.pinkAccent
                          ],
                          tileMode: TileMode.mirror,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$winner',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      child: Text(
                        'Main Menu',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple, // background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              18.0), // rounded corner radius
                        ),
                      ),
                      onPressed: () {
                        _goToMainMenu();
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(width: 15),
                    ElevatedButton(
                      child: Text(
                        'New Game',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple, // background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              18.0), // rounded corner radius
                        ),
                      ),
                      onPressed: () {
                        _startNewGame();
                        Navigator.of(context).pop();
                      },
                    ),
                  ]),
                ],
              ),
            ),
          );
        });
    _gameOver = true;
  }
}
