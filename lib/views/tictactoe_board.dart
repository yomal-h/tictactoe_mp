import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/resources/game_methods.dart';
import 'package:tictactoe_mp/resources/socket_client.dart';
import 'package:tictactoe_mp/resources/socket_methods.dart';
import 'dart:math' as math;

class TicTacToeBoard extends StatefulWidget {
  const TicTacToeBoard({Key? key}) : super(key: key);

  @override
  State<TicTacToeBoard> createState() => _TicTacToeBoardState();
}

class _TicTacToeBoardState extends State<TicTacToeBoard>
    with SingleTickerProviderStateMixin {
  final SocketMethods _socketMethods = SocketMethods();
  final GlobalKey _key = GlobalKey();
  final _socketClient = SocketClient.instance.socket!;
  List<int> _winningLine = []; // New state variable for holding winning line
  Socket get socketClient => _socketClient;
  late AnimationController _animationController; // Add this line
  late Tween<double> _animationTween;

  void tappedListener(BuildContext context) {
    _socketClient.off('tapped'); //double tap in new game error fixed
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

  void updateDisplayElements(Map<String, dynamic> newRoomData) {
    // setState(() {
    //   final winner = newRoomData['winner'];
    //   if (winner != null) {
    //     _winningLine = winner['line'];
    //   } else {
    //     _winningLine = [];
    //   }
    // });
    setState(() {
      final winner = newRoomData['winner'];
      if (winner != null) {
        _winningLine = winner['line'];
        _animationController.forward(from: 0);
      } else {
        _winningLine = [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animationTween = Tween<double>(begin: 0, end: 1);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _animationController.addListener(() {
      setState(() {});
    });
    //_socketMethods.tappedListener(context);
    tappedListener(context);
  }

  @override
  void dispose() {
    _socketClient.off('tapped');
    _animationController.dispose();
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
    final roomData = Provider.of<RoomDataProvider>(context);
    final winningLine = roomData.winningLine;
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
        child: Stack(
          children: [
            GridView.builder(
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (BuildContext context, int index) {
                final displayValue = roomData.displayElements[index];
                return GestureDetector(
                  onTap: () => tapped(index, roomDataProvider),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: winningLine.contains(index)
                            ? Colors.red
                            : Colors.grey,
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
                                    roomDataProvider.displayElements[index] ==
                                            'O'
                                        ? Colors.red
                                        : Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: winningLine.isEmpty
                      ? null
                      : LinePainter(
                          boxes: winningLine,
                          color: Colors.red,
                          strokeWidth: 10.0,
                          progress: _animationController.value,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List<int> boxes;
  final Color color;
  final double strokeWidth;
  final double progress;

  LinePainter({
    required this.boxes,
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final boxSize = size.width / 3;
    final start = Offset(
      (boxes.first % 3) * boxSize + boxSize / 2,
      (boxes.first ~/ 3) * boxSize + boxSize / 2,
    );
    final end = Offset(
      (boxes.last % 3) * boxSize + boxSize / 2,
      (boxes.last ~/ 3) * boxSize + boxSize / 2,
    );

    final length = math.sqrt(
          math.pow(end.dx - start.dx, 2) + math.pow(end.dy - start.dy, 2),
        ) *
        progress;

    canvas.drawLine(start, end, paint..strokeWidth = strokeWidth);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
