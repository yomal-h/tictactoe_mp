// import 'package:flutter/material.dart';
// import 'dart:math';

// class TicTacToeGameHard1 extends StatefulWidget {
//   static String routeName = '/tictactoe_hard';

//   const TicTacToeGameHard1({Key? key}) : super(key: key);

//   @override
//   __TicTacToeGameHard1State createState() => __TicTacToeGameHard1State();
// }

// class __TicTacToeGameHard1State extends State<TicTacToeGameHard1> {
//   final List<String> _board = List.filled(9, '');
//   String _currentPlayer = 'X';
//   int _playerScore = 0;
//   int _computerScore = 0;
//   int _round = 1;
//   bool _gameOver = false;
//   bool _isComputerThinking = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tic-Tac-Toe with Minimax'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Round $_round',
//             style: TextStyle(fontSize: 24.0),
//           ),
//           SizedBox(height: 16.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Player: $_playerScore',
//                 style: TextStyle(fontSize: 24.0),
//               ),
//               SizedBox(width: 32.0),
//               Text(
//                 'Computer: $_computerScore',
//                 style: TextStyle(fontSize: 24.0),
//               ),
//             ],
//           ),
//           SizedBox(height: 16.0),
//           GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//             ),
//             shrinkWrap: true,
//             itemCount: _board.length,
//             itemBuilder: (BuildContext context, int index) {
//               return GestureDetector(
//                 onTap: () {
//                   if (_isComputerThinking || _gameOver || _board[index] != '') {
//                     return;
//                   }
//                   setState(() {
//                     _board[index] = _currentPlayer;
//                     _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
//                     if (_checkForWinner(_board, 'X')) {
//                       _playerScore++;
//                       _startNewRound();
//                     } else if (_checkForWinner(_board, 'O')) {
//                       _computerScore++;
//                       _startNewRound();
//                     } else if (_board.every((element) => element != '')) {
//                       _startNewRound();
//                     } else {
//                       _isComputerThinking = true;
//                       Future.delayed(Duration(seconds: 1), () {
//                         setState(() {
//                           _makeComputerMove();
//                           _isComputerThinking = false;
//                         });
//                       });
//                     }
//                   });
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.black,
//                       width: 1.0,
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       _board[index],
//                       style: TextStyle(fontSize: 48.0),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//           _gameOver
//               ? RaisedButton(
//                   child: Text('New Game'),
//                   onPressed: _startNewGame,
//                 )
//               : SizedBox.shrink(),
//           _isComputerThinking
//               ? Text(
//                   'Computer is thinking...',
//                   style: TextStyle(fontSize: 24.0),
//                 )
//               : SizedBox.shrink(),
//           _gameOver
//               ? SizedBox.shrink()
//               : Text(
//                   'Current player: $_currentPlayer',
//                   style: TextStyle(fontSize: 24.0),
//                 ),
//         ],
//       ),
//     );
//   }

// //Prioritize blocking the player's winning moves. In the 'easy' implementation,
// //the computer is only making moves randomly,
// //without any strategy to block the player.
// //this code to check if the player is one move away
// //from winning and block that move. To do this, this function
// //checks if a given move results in a winning move for the player,
// //and use this function to prioritize blocking the player
//   int _findBlockingMove() {
//     // Check if there's a winning move for the player and block it
//     for (int i = 0; i < 9; i++) {
//       if (_board[i] == '') {
//         _board[i] = 'X';
//         if (_checkForWinner(_board, 'X')) {
//           _board[i] = 'O';
//           return i;
//         }
//         _board[i] = '';
//       }
//     }
//     return -1;
//   }

// //This function returns a list of the available moves on the current board.
// //You can use it in the _makeComputerMove() function to get a list of available moves
// //to choose from when making a move.
//   List<int> _getAvailableMoves() {
//     List<int> availableMoves = [];
//     for (int i = 0; i < 9; i++) {
//       if (_board[i] == '') {
//         availableMoves.add(i);
//       }
//     }
//     return availableMoves;
//   }

//   //Hard mode
//   //choose the corners or sides randomly, or with some probability,
//   void _makeComputerMove() {
//     int blockingMove = _findBlockingMove();

//     if (blockingMove != -1) {
//       _board[blockingMove] = 'O';
//     } else {
//       // Randomly choose the next move
//       List<int> availableMoves = _getAvailableMoves();
//       int randomIndex = Random().nextInt(availableMoves.length);
//       int randomMove = availableMoves[randomIndex];
//       if (availableMoves.length > 3 && randomIndex == 0) {
//         // With 20% probability, choose a random corner instead of the center
//         List<int> corners = [0, 2, 6, 8];
//         List<int> availableCorners =
//             corners.where((corner) => _board[corner] == '').toList();
//         if (availableCorners.isNotEmpty && Random().nextInt(5) == 0) {
//           int randomCorner =
//               availableCorners[Random().nextInt(availableCorners.length)];
//           randomMove = randomCorner;
//         }
//       } else if (availableMoves.length > 1 && randomIndex == 0) {
//         // With 20% probability, choose a random side instead of the center
//         List<int> sides = [1, 3, 5, 7];
//         List<int> availableSides =
//             sides.where((side) => _board[side] == '').toList();
//         if (availableSides.isNotEmpty && Random().nextInt(5) == 0) {
//           int randomSide =
//               availableSides[Random().nextInt(availableSides.length)];
//           randomMove = randomSide;
//         }
//       }

//       _board[randomMove] = 'O';
//     }

//     if (_checkForWinner(_board, 'O')) {
//       _computerScore++;
//       _startNewRound();
//     } else if (_board.every((element) => element != '')) {
//       _startNewRound();
//     } else {
//       _currentPlayer = 'X';
//     }
//   }

//   int _minimax(List<String> board, int depth, bool isMaximizing) {
//     if (_checkForWinner(board, 'O')) {
//       return 10 - depth;
//     } else if (_checkForWinner(board, 'X')) {
//       return depth - 10;
//     } else if (board.every((element) => element != '')) {
//       return 0;
//     }

//     int bestScore = isMaximizing ? -1000 : 1000;
//     for (int i = 0; i < board.length; i++) {
//       if (board[i] == '') {
//         board[i] = isMaximizing ? 'O' : 'X';
//         int score = _minimax(board, depth + 1, !isMaximizing);
//         board[i] = '';
//         if (isMaximizing) {
//           if (score > bestScore) {
//             bestScore = score;
//           }
//         } else {
//           if (score < bestScore) {
//             bestScore = score;
//           }
//         }
//       }
//     }
//     return bestScore;
//   }

//   bool _checkForWinner(List<String> board, String player) {
//     // check rows
//     for (int i = 0; i < 9; i += 3) {
//       if (board[i] == player &&
//           board[i + 1] == player &&
//           board[i + 2] == player) {
//         return true;
//       }
//     }

//     // check columns
//     for (int i = 0; i < 3; i++) {
//       if (board[i] == player &&
//           board[i + 3] == player &&
//           board[i + 6] == player) {
//         return true;
//       }
//     }

//     // check diagonals
//     if (board[0] == player && board[4] == player && board[8] == player) {
//       return true;
//     }
//     if (board[2] == player && board[4] == player && board[6] == player) {
//       return true;
//     }

//     return false;
//   }

//   void _startNewRound() {
//     String winner = _checkForWinner(_board, 'X')
//         ? 'Player'
//         : _checkForWinner(_board, 'O')
//             ? 'Computer'
//             : 'Tie';

//     if (_round > 2) {
//       // Game is over
//       _showWinner();
//     } else {
//       // Round is over
//       String dialogTitle = 'Round $_round Result';
//       String dialogContent = '';

//       if (winner == 'Tie') {
//         dialogContent = 'The round was a tie!';
//       } else {
//         dialogContent = '$winner won the round!';
//       }

//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(dialogTitle),
//             content: Text(dialogContent),
//             actions: [
//               TextButton(
//                 child: Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   setState(() {
//                     _board.fillRange(0, 9, '');
//                     _currentPlayer = 'X';
//                     _round++;
//                     _gameOver = false;
//                     if (winner == 'Player') {
//                       // _playerScore++;
//                     } else if (winner == 'Computer') {
//                       // _computerScore++;
//                     }
//                   });
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }

//     _gameOver = true;
//   }

//   void _startNewGame() {
//     setState(() {
//       _board.fillRange(0, 9, '');
//       _playerScore = 0;
//       _computerScore = 0;
//       _round = 1;
//       _gameOver = false;
//       _currentPlayer = 'X';
//     });
//   }

//   void _showWinner() {
//     String winner = '';
//     if (_playerScore > _computerScore) {
//       winner = 'Player';
//     } else if (_computerScore > _playerScore) {
//       winner = 'Computer';
//     } else {
//       winner = 'Nobody';
//     }
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Game Over'),
//           content: Text('The winner is $winner!'),
//           actions: [
//             ElevatedButton(
//                 child: Text('New Game'),
//                 onPressed: () {
//                   _startNewGame();
//                   Navigator.of(context).pop();
//                 }),
//           ],
//         );
//       },
//     );
//     _gameOver = true;
//   }
// }


// import 'package:flutter/material.dart';
// import 'dart:math';

// class TicTacToeGameMedium extends StatefulWidget {
//   static String routeName = '/tictactoe_medium';

//   const TicTacToeGameMedium({Key? key}) : super(key: key);

//   @override
//   __TicTacToeGameMediumState createState() => __TicTacToeGameMediumState();
// }

// class __TicTacToeGameMediumState extends State<TicTacToeGameMedium> {
//   final List<String> _board = List.filled(9, '');
//   String _currentPlayer = 'X';
//   int _playerScore = 0;
//   int _computerScore = 0;
//   int _round = 1;
//   bool _gameOver = false;
//   bool _isComputerThinking = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tic-Tac-Toe with Minimax'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Round $_round',
//             style: TextStyle(fontSize: 24.0),
//           ),
//           SizedBox(height: 16.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Player: $_playerScore',
//                 style: TextStyle(fontSize: 24.0),
//               ),
//               SizedBox(width: 32.0),
//               Text(
//                 'Computer: $_computerScore',
//                 style: TextStyle(fontSize: 24.0),
//               ),
//             ],
//           ),
//           SizedBox(height: 16.0),
//           GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//             ),
//             shrinkWrap: true,
//             itemCount: _board.length,
//             itemBuilder: (BuildContext context, int index) {
//               return GestureDetector(
//                 onTap: () {
//                   if (_isComputerThinking || _gameOver || _board[index] != '') {
//                     return;
//                   }
//                   setState(() {
//                     _board[index] = _currentPlayer;
//                     _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
//                     if (_checkForWinner(_board, 'X')) {
//                       _playerScore++;
//                       _startNewRound();
//                     } else if (_checkForWinner(_board, 'O')) {
//                       _computerScore++;
//                       _startNewRound();
//                     } else if (_board.every((element) => element != '')) {
//                       _startNewRound();
//                     } else {
//                       _isComputerThinking = true;
//                       Future.delayed(Duration(seconds: 1), () {
//                         setState(() {
//                           _makeComputerMove();
//                           _isComputerThinking = false;
//                         });
//                       });
//                     }
//                   });
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.black,
//                       width: 1.0,
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       _board[index],
//                       style: TextStyle(fontSize: 48.0),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//           _gameOver
//               ? RaisedButton(
//                   child: Text('New Game'),
//                   onPressed: _startNewGame,
//                 )
//               : SizedBox.shrink(),
//           _isComputerThinking
//               ? Text(
//                   'Computer is thinking...',
//                   style: TextStyle(fontSize: 24.0),
//                 )
//               : SizedBox.shrink(),
//           _gameOver
//               ? SizedBox.shrink()
//               : Text(
//                   'Current player: $_currentPlayer',
//                   style: TextStyle(fontSize: 24.0),
//                 ),
//         ],
//       ),
//     );
//   }

// //Prioritize blocking the player's winning moves. In the 'easy' implementation,
// //the computer is only making moves randomly,
// //without any strategy to block the player.
// //this code to check if the player is one move away
// //from winning and block that move. To do this, this function
// //checks if a given move results in a winning move for the player,
// //and use this function to prioritize blocking the player
//   int _findBlockingMove() {
//     // Check if there's a winning move for the player and block it
//     for (int i = 0; i < 9; i++) {
//       if (_board[i] == '') {
//         _board[i] = 'X';
//         if (_checkForWinner(_board, 'X')) {
//           _board[i] = 'O';
//           return i;
//         }
//         _board[i] = '';
//       }
//     }
//     return -1;
//   }

// //This function returns a list of the available moves on the current board.
// //You can use it in the _makeComputerMove() function to get a list of available moves
// //to choose from when making a move.
//   List<int> _getAvailableMoves() {
//     List<int> availableMoves = [];
//     for (int i = 0; i < 9; i++) {
//       if (_board[i] == '') {
//         availableMoves.add(i);
//       }
//     }
//     return availableMoves;
//   }

//   //Medium mode
//   //choose the corners or sides randomly, or with some probability,
//   void _makeComputerMove() {
//     int blockingMove = _findBlockingMove();

//     if (blockingMove != -1) {
//       _board[blockingMove] = 'O';
//     } else {
//       // Randomly choose the next move
//       List<int> availableMoves = _getAvailableMoves();
//       int randomIndex = Random().nextInt(availableMoves.length);
//       int randomMove = availableMoves[randomIndex];
//       if (availableMoves.length > 3 && randomIndex == 0) {
//         // With 60% probability, choose a random corner instead of the center
//         List<int> corners = [0, 2, 6, 8];
//         List<int> availableCorners =
//             corners.where((corner) => _board[corner] == '').toList();
//         if (availableCorners.isNotEmpty && Random().nextInt(10) < 6) {
//           int randomCorner =
//               availableCorners[Random().nextInt(availableCorners.length)];
//           randomMove = randomCorner;
//         }
//       } else if (availableMoves.length > 1 && randomIndex == 0) {
//         // With 60% probability, choose a random side instead of the center
//         List<int> sides = [1, 3, 5, 7];
//         List<int> availableSides =
//             sides.where((side) => _board[side] == '').toList();
//         if (availableSides.isNotEmpty && Random().nextInt(10) < 6) {
//           int randomSide =
//               availableSides[Random().nextInt(availableSides.length)];
//           randomMove = randomSide;
//         }
//       }

//       _board[randomMove] = 'O';
//     }

//     if (_checkForWinner(_board, 'O')) {
//       _computerScore++;
//       _startNewRound();
//     } else if (_board.every((element) => element != '')) {
//       _startNewRound();
//     } else {
//       _currentPlayer = 'X';
//     }
//   }

//   int _minimax(List<String> board, int depth, bool isMaximizing) {
//     if (_checkForWinner(board, 'O')) {
//       return 10 - depth;
//     } else if (_checkForWinner(board, 'X')) {
//       return depth - 10;
//     } else if (board.every((element) => element != '')) {
//       return 0;
//     }

//     int bestScore = isMaximizing ? -1000 : 1000;
//     for (int i = 0; i < board.length; i++) {
//       if (board[i] == '') {
//         board[i] = isMaximizing ? 'O' : 'X';
//         int score = _minimax(board, depth + 1, !isMaximizing);
//         board[i] = '';
//         if (isMaximizing) {
//           if (score > bestScore) {
//             bestScore = score;
//           }
//         } else {
//           if (score < bestScore) {
//             bestScore = score;
//           }
//         }
//       }
//     }
//     return bestScore;
//   }

//   bool _checkForWinner(List<String> board, String player) {
//     // check rows
//     for (int i = 0; i < 9; i += 3) {
//       if (board[i] == player &&
//           board[i + 1] == player &&
//           board[i + 2] == player) {
//         return true;
//       }
//     }

//     // check columns
//     for (int i = 0; i < 3; i++) {
//       if (board[i] == player &&
//           board[i + 3] == player &&
//           board[i + 6] == player) {
//         return true;
//       }
//     }

//     // check diagonals
//     if (board[0] == player && board[4] == player && board[8] == player) {
//       return true;
//     }
//     if (board[2] == player && board[4] == player && board[6] == player) {
//       return true;
//     }

//     return false;
//   }

//   void _startNewRound() {
//     String winner = _checkForWinner(_board, 'X')
//         ? 'Player'
//         : _checkForWinner(_board, 'O')
//             ? 'Computer'
//             : 'Tie';

//     if (_round > 2) {
//       // Game is over
//       _showWinner();
//     } else {
//       // Round is over
//       String dialogTitle = 'Round $_round Result';
//       String dialogContent = '';

//       if (winner == 'Tie') {
//         dialogContent = 'The round was a tie!';
//       } else {
//         dialogContent = '$winner won the round!';
//       }

//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(dialogTitle),
//             content: Text(dialogContent),
//             actions: [
//               TextButton(
//                 child: Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   setState(() {
//                     _board.fillRange(0, 9, '');
//                     _currentPlayer = 'X';
//                     _round++;
//                     _gameOver = false;
//                     if (winner == 'Player') {
//                       // _playerScore++;
//                     } else if (winner == 'Computer') {
//                       // _computerScore++;
//                     }
//                   });
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }

//     _gameOver = true;
//   }

//   void _startNewGame() {
//     setState(() {
//       _board.fillRange(0, 9, '');
//       _playerScore = 0;
//       _computerScore = 0;
//       _round = 1;
//       _gameOver = false;
//       _currentPlayer = 'X';
//     });
//   }

//   void _showWinner() {
//     String winner = '';
//     if (_playerScore > _computerScore) {
//       winner = 'Player';
//     } else if (_computerScore > _playerScore) {
//       winner = 'Computer';
//     } else {
//       winner = 'Nobody';
//     }
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Game Over'),
//           content: Text('The winner is $winner!'),
//           actions: [
//             ElevatedButton(
//                 child: Text('New Game'),
//                 onPressed: () {
//                   _startNewGame();
//                   Navigator.of(context).pop();
//                 }),
//           ],
//         );
//       },
//     );
//     _gameOver = true;
//   }
// }

// //unbeatable mode
//   void _makeComputerMove() {
//     int bestMove = -1;
//     int bestScore = -1000;
//     for (int i = 0; i < _board.length; i++) {
//       if (_board[i] == '') {
//         _board[i] = 'O';
//         int score = _minimax(_board, 0, false);
//         _board[i] = '';
//         if (score > bestScore) {
//           bestScore = score;
//           bestMove = i;
//         }
//       }
//     }
//     _board[bestMove] = 'O';
//     if (_checkForWinner(_board, 'O')) {
//       _computerScore++;
//       _startNewRound();
//     } else if (_board.every((element) => element != '')) {
//       _startNewRound();
//     } else {
//       _currentPlayer = 'X';
//     }
//   }

//   int _minimax(List<String> board, int depth, bool isMaximizing) {
//     if (_checkForWinner(board, 'O')) {
//       return 10 - depth;
//     } else if (_checkForWinner(board, 'X')) {
//       return depth - 10;
//     } else if (board.every((element) => element != '')) {
//       return 0;
//     }

//     int bestScore = isMaximizing ? -1000 : 1000;
//     for (int i = 0; i < board.length; i++) {
//       if (board[i] == '') {
//         board[i] = isMaximizing ? 'O' : 'X';
//         int score = _minimax(board, depth + 1, !isMaximizing);
//         board[i] = '';
//         if (isMaximizing) {
//           if (score > bestScore) {
//             bestScore = score;
//           }
//         } else {
//           if (score < bestScore) {
//             bestScore = score;
//           }
//         }
//       }
//     }
//     return bestScore;
//   }

// import 'dart:ui';
// import 'package:flutter_glow/flutter_glow.dart';
// import 'package:flutter/material.dart';
// import 'dart:math';

// class TicTacToeGameOfflineMultiplayer extends StatefulWidget {
//   static String routeName = '/tictactoe_offline_multiplayer1';

//   const TicTacToeGameOfflineMultiplayer({Key? key}) : super(key: key);

//   @override
//   __TicTacToeGameOfflineMultiplayerState createState() =>
//       __TicTacToeGameOfflineMultiplayerState();
// }

// class __TicTacToeGameOfflineMultiplayerState
//     extends State<TicTacToeGameOfflineMultiplayer>
//     with SingleTickerProviderStateMixin {
//   final List<String> _board = List.filled(9, '');
//   String _currentPlayer = 'X';
//   int _playerScore = 0;
//   int _computerScore = 0;
//   int _round = 1;
//   bool _gameOver = false;
//   final bool _isComputerThinking = false;
//   List<int> _winningLine = [];
//   late AnimationController _animationController;
//   late Tween<double> _animationTween;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 500),
//     )..addListener(() {
//         setState(() {});
//       });
//     _animationTween = Tween<double>(begin: 0.0, end: 1.0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(height: 90.0),
//           Center(
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.white,
//                   width: 2,
//                 ),
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.purple.withOpacity(0.5),
//                     spreadRadius: 4,
//                     blurRadius: 7,
//                     offset: Offset(0, 0), // changes position of shadow
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Text(
//                   'Round $_round',
//                   style: const TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       shadows: [
//                         Shadow(blurRadius: 40, color: Colors.purpleAccent)
//                       ]),
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: 50.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 30.0),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Player 1',
//                       style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           shadows: [
//                             Shadow(blurRadius: 40, color: Colors.purpleAccent)
//                           ]),
//                     ),
//                     Text(
//                       '$_playerScore',
//                       style: const TextStyle(
//                         fontSize: 25,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Text(
//                 '   :   ',
//                 style: const TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     shadows: [
//                       Shadow(blurRadius: 40, color: Colors.purpleAccent)
//                     ]),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 30.0),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Player 2',
//                       style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           shadows: [
//                             Shadow(blurRadius: 40, color: Colors.purpleAccent)
//                           ]),
//                     ),
//                     Text(
//                       '$_computerScore',
//                       style: const TextStyle(
//                         fontSize: 25,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 2.0),
//           Expanded(
//             child: AspectRatio(
//               aspectRatio: 0.9,
//               child: Padding(
//                 padding: const EdgeInsets.all(5.0),
//                 child: LayoutBuilder(builder:
//                     (BuildContext context, BoxConstraints constraints) {
//                   double fontSize1 = constraints.maxWidth / 4.5;
//                   return Stack(
//                     children: [
//                       GridView.builder(
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3,
//                         ),
//                         shrinkWrap: true,
//                         itemCount: _board.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           return GestureDetector(
//                             onTap: () {
//                               if (_gameOver || _board[index] != '') {
//                                 return;
//                               }
//                               setState(() {
//                                 _animationController.reset();
//                                 _animationController.forward();
//                                 _board[index] = _currentPlayer;
//                                 if (_checkForWinner(_board, 'X')) {
//                                   _playerScore++;
//                                   _startNewRound();
//                                 } else if (_checkForWinner(_board, 'O')) {
//                                   _computerScore++;
//                                   _startNewRound();
//                                 } else if (_board
//                                     .every((element) => element != '')) {
//                                   _startNewRound();
//                                 } else {
//                                   _currentPlayer =
//                                       _currentPlayer == 'X' ? 'O' : 'X';
//                                 }
//                               });
//                             },
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 300),
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: _winningLine.contains(index)
//                                       ? Colors.purple
//                                       : Colors.white24,
//                                   width: 1.0,
//                                 ),
//                               ),
//                               child: Center(
//                                 child: AnimatedSize(
//                                   duration: const Duration(milliseconds: 200),
//                                   child: Text(
//                                     _board[index],
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: fontSize1,
//                                         shadows: [
//                                           Shadow(
//                                             blurRadius: 40,
//                                             color: _board[index] == 'O'
//                                                 ? Colors.greenAccent
//                                                 : Colors.pink,
//                                           ),
//                                         ]),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       if (_gameOver && _winningLine.isNotEmpty)
//                         ShaderMask(
//                           blendMode: BlendMode.srcOver,
//                           shaderCallback: (Rect rect) {
//                             return LinearGradient(
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                               colors: [
//                                 Colors.white,
//                                 Colors.pinkAccent.withOpacity(0.2),
//                                 Colors.pinkAccent.withOpacity(0.4),
//                                 Colors.pinkAccent.withOpacity(0.6),
//                                 Colors.pinkAccent.withOpacity(0.4),
//                                 Colors.white,
//                               ],
//                               stops: [
//                                 0.0,
//                                 0.2,
//                                 0.4,
//                                 0.6,
//                                 0.8,
//                                 1.0,
//                               ],
//                             ).createShader(rect);
//                           },
//                           child: CustomPaint(
//                             painter: WinningLinePainter(
//                               _winningLine,
//                               _animationTween.animate(_animationController),
//                               context,
//                             ),
//                           ),
//                         )
//                     ],
//                   );
//                 }),
//               ),
//             ),
//           ),
//           _gameOver
//               ? ElevatedButton(
//                   child: Text('New Game'),
//                   onPressed: _startNewGame,
//                 )
//               : SizedBox.shrink(),
//           _isComputerThinking
//               ? Text(
//                   'Computer is thinking...',
//                   style: TextStyle(fontSize: 24.0),
//                 )
//               : SizedBox.shrink(),
//           _gameOver
//               ? SizedBox.shrink()
//               : Text(
//                   'Current player: $_currentPlayer',
//                   style: TextStyle(fontSize: 24.0),
//                 ),
//           SizedBox(
//             height: 20.0,
//           ),
//           GlowButton(
//             onPressed: _startNewGame,
//             child: Text('Resetr4r4r4'),
//             blurRadius: 15,
//             color: Colors.purple,
//           ),
//           SizedBox(
//             height: 40.0,
//           ),
//         ],
//       ),
//     );
//   }

//   bool _checkForWinner(List<String> board, String symbol) {
//     // Check rows
//     for (int i = 0; i < 9; i += 3) {
//       if (board[i] == symbol &&
//           board[i + 1] == symbol &&
//           board[i + 2] == symbol) {
//         _winningLine = [i, i + 1, i + 2];
//         return true;
//       }
//     }

//     // Check columns
//     for (int i = 0; i < 3; i++) {
//       if (board[i] == symbol &&
//           board[i + 3] == symbol &&
//           board[i + 6] == symbol) {
//         _winningLine = [i, i + 3, i + 6];
//         return true;
//       }
//     }

//     // Check diagonals
//     if (board[0] == symbol && board[4] == symbol && board[8] == symbol) {
//       _winningLine = [0, 4, 8];
//       return true;
//     }
//     if (board[2] == symbol && board[4] == symbol && board[6] == symbol) {
//       _winningLine = [2, 4, 6];
//       return true;
//     }

//     return false;
//   }

//   void _startNewRound() {
//     String winner = _checkForWinner(_board, 'X')
//         ? 'Player 1'
//         : _checkForWinner(_board, 'O')
//             ? 'Player 2'
//             : 'Tie';

//     if (_round > 2) {
//       // Game is over

//       _showWinner();
//     } else {
//       // Round is over
//       String dialogTitle = 'Round $_round Result';
//       String dialogContent = '';

//       if (winner == 'Tie') {
//         dialogContent = 'The round was a tie!';
//       } else {
//         _animationController
//             .reset(); //use these two otherwise A.I animation will not work
//         _animationController.forward();
//         dialogContent = '$winner won the round!';
//       }

//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text(dialogTitle),
//             content: Text(dialogContent),
//             actions: [
//               TextButton(
//                 child: Text('OK'),
//                 onPressed: () {
//                   _winningLine.clear();
//                   Navigator.of(context).pop();
//                   setState(() {
//                     _board.fillRange(0, 9, '');
//                     //_currentPlayer = 'X';
//                     _round++;
//                     _gameOver = false;
//                     if (winner == 'Player 1') {
//                       // _playerScore++;
//                       _currentPlayer = 'O';
//                     } else if (winner == 'Player 2') {
//                       // _computerScore++;
//                       _currentPlayer = 'X';
//                     }
//                   });
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }

//     _gameOver = true;
//   }

//   void _startNewGame() {
//     setState(() {
//       _board.fillRange(0, 9, '');
//       _playerScore = 0;
//       _computerScore = 0;
//       _round = 1;
//       _gameOver = false;
//       _currentPlayer = 'X';
//       _winningLine.clear();
//     });
//   }

//   void _showWinner() {
//     String winner = '';
//     if (_playerScore > _computerScore) {
//       winner = 'Player 1';
//       _animationController.reset();
//       _animationController.forward();
//     } else if (_computerScore > _playerScore) {
//       winner = 'Player 2';
//       _animationController.reset();
//       _animationController.forward();
//     } else {
//       winner = 'Nobody';
//     }
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Game Over'),
//           content: Text('The winner is $winner!'),
//           actions: [
//             ElevatedButton(
//                 child: Text('New Game'),
//                 onPressed: () {
//                   _startNewGame();
//                   Navigator.of(context).pop();
//                 }),
//           ],
//         );
//       },
//     );
//     _gameOver = true;
//   }
// }

// class WinningLinePainter extends CustomPainter {
//   final List<int> _winningLine;
//   final Animation<double> _animation;
//   final BuildContext _context;

//   WinningLinePainter(this._winningLine, this._animation, this._context);

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (_winningLine.isEmpty) {
//       return;
//     }

//     double boxSize = MediaQuery.of(_context).size.width / 3;
//     double startx = _winningLine[0] % 3 * boxSize + boxSize / 2;
//     double starty = _winningLine[0] ~/ 3 * boxSize + boxSize / 2;
//     double endx = _winningLine.last % 3 * boxSize + boxSize / 2;
//     double endy = _winningLine.last ~/ 3 * boxSize + boxSize / 2;

//     double dx = (endx - startx) * _animation.value;
//     double dy = (endy - starty) * _animation.value;

//     Paint paint = Paint()
//       ..strokeWidth = 10.0
//       ..style = PaintingStyle.stroke
//       ..shader = LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           Colors.purple,
//           Colors.purple,
//         ],
//       ).createShader(Rect.fromPoints(
//           Offset(startx, starty), Offset(startx + dx, starty + dy)));

//     Path path = Path();
//     path.moveTo(startx, starty);
//     path.lineTo(startx + dx, starty + dy);

//     // Add a pulsating effect to the neon glow
//     Paint glowPaint = Paint()
//       ..color = Colors.pinkAccent.withOpacity(0.6 + 0.4 * _animation.value)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 16.0
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16.0 * _animation.value);

//     canvas.drawPath(path, glowPaint);
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(WinningLinePainter oldDelegate) {
//     return _winningLine != oldDelegate._winningLine ||
//         _animation != oldDelegate._animation;
//   }
// }