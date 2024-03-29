import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:custom_timer/custom_timer.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/resources/socket_client.dart';
import 'package:tictactoe_mp/resources/socket_methods.dart';
import 'package:tictactoe_mp/screens/main_menu_screen.dart';
import 'package:tictactoe_mp/utils/ad_helper.dart';
import 'package:tictactoe_mp/utils/ad_manager.dart';
import 'package:tictactoe_mp/utils/colors.dart';
import 'package:tictactoe_mp/views/scoreboard.dart';
import 'package:tictactoe_mp/views/tictactoe_board.dart';
import 'package:tictactoe_mp/views/waiting_lobby.dart';
import 'dart:io' show Platform;

import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class GameScreen extends StatefulWidget {
  static String routeName = '/game';

  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final SocketMethods _socketMethods = SocketMethods();

  final GlobalKey _key = GlobalKey();
  final _socketClient = SocketClient.instance.socket!;
  List<int> _winningLine = []; // New state variable for holding winning line
  Socket get socketClient => _socketClient;
  late AnimationController _animationController; // Add this line
  late Tween<double> _animationTween;

  late AnimationController _animationController1;
  late Animation<double> _animation;
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

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
      checkWinner(newContext, _socketClient);

      _animationController
          .reset(); //in order to animation to work from the begining otherwise animation will play after it was drawn
      _animationController.forward(); // Start the animation

      print('_animationController.status: ${_animationController.status}');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _socketMethods.updateRoomListener(context);
    _socketMethods.updatePlayersStateListener(context);
    _socketMethods.pointIncreaseListener(context);
    _socketMethods.increaseCurrentRoundListener(context);
    //_socketMethods.endGameListener(context);

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _animationController.forward();
    _animationTween = Tween<double>(begin: 0, end: 1);
    // _animationController.addListener(() {
    //   setState(() {});
    // });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //_animationController.reset();
        _animationController.stop();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });

    _animationController1 = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController1,
        curve: Curves.easeInOut,
      ),
    );

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

    //_socketMethods.tappedListener(context);
    endGameListener(context);
    tappedListener(context);

    // UnityAds.init(
    //   gameId: AdManager.gameId,
    //   testMode: false,
    //   onComplete: () {
    //     print('Initialization Complete');
    //     _loadAd(AdManager.interstitialVideoAdPlacementId);
    //   },
    //   onFailed: (error, message) =>
    //       print('Initialization Failed: $error $message'),
    // );
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _socketClient.off('tapped');
    _animationController.dispose();
    _animationController1.dispose();
    _rotateController.dispose();
    _controller.dispose();
    _interstitialAd?.dispose();
    super.dispose();
    // TODO: implement dispose
  }

  void tapped(int index, RoomDataProvider roomDataProvider) {
    _socketMethods.tapGrid(index, roomDataProvider.roomData['_id'],
        roomDataProvider.displayElements, roomDataProvider.filledBoxes);
  }

//to fix non host device printing host device's symbol when tapped rapidly,
//a debounce function added to limit the number of times the onTap function can be called in a certain time period
  Function() debounce(Function() func, [int milliseconds = 250]) {
    Timer? timer;
    return () {
      if (timer != null) {
        timer?.cancel();
      }
      timer = Timer(Duration(milliseconds: milliseconds), func);
    };
  }

  void increaseRound(RoomDataProvider roomDataProvider) {
    print('round increased');
    _socketMethods.increaseCurrentRound(roomDataProvider.roomData['_id']);
  }

  void _goToMainMenu() {
    //_showAd(AdManager.interstitialVideoAdPlacementId);
    _showInterstitialAd();
    final gameState = Provider.of<RoomDataProvider>(context, listen: false);
    clearBoard(context);

//                 //navigateToMainMenu(context);
    Navigator.pushNamed(context, MainMenuScreen.routeName);
//
    gameState.reset();
  }

  @override
  Widget build(BuildContext context) {
    RoomDataProvider roomDataProvider = Provider.of<RoomDataProvider>(context);
    //print(Provider.of<RoomDataProvider>(context).player1.nickname);
    //print(Provider.of<RoomDataProvider>(context).player2.nickname);
    final roomData = Provider.of<RoomDataProvider>(context);
    final winningLine = roomData.winningLine;
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        child: Scaffold(
            body: roomDataProvider.roomData.containsKey('isJoin')
                ? roomDataProvider.roomData['isJoin']
                    ? const WaitingLobby()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          SizedBox(
                              height: Platform.isIOS
                                  ? 90
                                  : 70), //55 for android and //90 for ios
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
                                    offset: Offset(
                                        0, 0), // changes position of the shadow
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Round ${Provider.of<RoomDataProvider>(context).currentRound}',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 40,
                                            color: boardBorderColor)
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30.0),
                                child: Column(
                                  children: [
                                    Text(
                                      roomDataProvider.player1.nickname,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                                blurRadius: 40,
                                                color: boardBorderColor)
                                          ]),
                                    ),
                                    SizedBox(height: 10.0),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color:
                                            boardBorderColor.withOpacity(0.2),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 10.0),
                                        child: Text(
                                          roomDataProvider.player1.points
                                              .toInt()
                                              .toString(),
                                          style: const TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 40,
                                                    color: Colors.purpleAccent)
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
                                      Shadow(
                                          blurRadius: 40,
                                          color: Colors.purpleAccent)
                                    ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: Column(
                                  children: [
                                    Text(
                                      roomDataProvider.player2.nickname,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                                blurRadius: 40,
                                                color: Colors.greenAccent)
                                          ]),
                                    ),
                                    SizedBox(height: 10.0),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color:
                                            boardBorderColor.withOpacity(0.2),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 10.0),
                                        child: Text(
                                          roomDataProvider.player2.points
                                              .toInt()
                                              .toString(),
                                          style: const TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 40,
                                                    color: Colors.purpleAccent)
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
                          //const Scoreboard(),
                          Expanded(
                            key: _key,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Padding(
                                padding:
                                    EdgeInsets.all(Platform.isIOS ? 5 : 10),
                                child: LayoutBuilder(builder:
                                    (BuildContext context,
                                        BoxConstraints constraints) {
                                  double fontSize1 = constraints.maxWidth / 4.5;
                                  return AbsorbPointer(
                                    absorbing: roomDataProvider.roomData['turn']
                                            ['socketID'] !=
                                        _socketMethods.socketClient.id,
                                    child: Stack(
                                      children: [
                                        GridView.builder(
                                          itemCount: 9,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                          ),
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final displayValue =
                                                roomData.displayElements[index];
                                            return GestureDetector(
                                              onTap: debounce(() {
                                                tapped(index, roomDataProvider);
                                              }, 65), //debounce added to fix the bug caused by rapid tapping
                                              child: Transform.translate(
                                                offset: Offset(
                                                  0.0,
                                                  winningLine.contains(index)
                                                      ? -_shakeAnimation.value
                                                      : 0.0,
                                                ),
                                                child: AnimatedContainer(
                                                  //grid container
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: winningLine
                                                              .contains(index)
                                                          ? boardBorderColor
                                                              .withOpacity(
                                                                  0.5) //winning boxes highlight color
                                                          : boardBorderColor
                                                              .withOpacity(0.3),
                                                      width: winningLine
                                                              .contains(index)
                                                          ? 5.0
                                                          : 1.0,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: PrimaryColor
                                                            .withOpacity(0.5),
                                                        spreadRadius: 5,
                                                        blurRadius: 10,
                                                        offset: Offset(0, 0),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: AnimatedSize(
                                                      duration: const Duration(
                                                          milliseconds: 200),
                                                      child: Transform.scale(
                                                        scale: winningLine
                                                                .contains(index)
                                                            ? _scaleAnimation
                                                                .value
                                                            : 1.0,
                                                        child: Text(
                                                          roomDataProvider
                                                                  .displayElements[
                                                              index],
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: fontSize1,
                                                            shadows: [
                                                              Shadow(
                                                                blurRadius: 40,
                                                                color: roomDataProvider.displayElements[
                                                                            index] ==
                                                                        'O'
                                                                    ? Colors
                                                                        .greenAccent
                                                                    : Colors
                                                                        .pink,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // AnimatedBuilder(
                                        //   animation: _animationController,
                                        //   builder: (BuildContext context,
                                        //       Widget? child) {
                                        //     return CustomPaint(
                                        //       size: Size.infinite,
                                        //       painter: winningLine.isEmpty
                                        //           ? null
                                        //           : LinePainter(
                                        //               boxes: winningLine,
                                        //               color: Colors.red,
                                        //               strokeWidth: 10.0,
                                        //               progress: _animationTween
                                        //                   .animate(CurvedAnimation(
                                        //                       parent:
                                        //                           _animationController,
                                        //                       curve: Curves
                                        //                           .easeInOutCirc))
                                        //                   .value,
                                        //             ),
                                        //     );
                                        //   },
                                        // ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          Container(
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: boardBorderColor.withOpacity(0.2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 10.0,
                              ),
                              child: Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 40,
                                            color: boardBorderColor),
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
                                        text:
                                            '${roomDataProvider.roomData['turn']['nickname']}',
                                        style: TextStyle(
                                            fontSize: 24.0,
                                            fontFamily: 'Beon',
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              BoxShadow(
                                                color:
                                                    '${roomDataProvider.roomData['turn']['nickname']}' ==
                                                            'X'
                                                        ? Colors.pinkAccent
                                                            .withOpacity(0.8)
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
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
                          SizedBox(
                            height: Platform.isIOS ? 40 : 2, //2 for android
                          ),
                          // Text(
                          //     '${roomDataProvider.roomData['turn']['nickname']}\'s turn'),
                        ],
                      )
                : Container()),
      ),
    );
  }

  void showEndGameDialog(BuildContext context, String text) {
    final gameState = Provider.of<RoomDataProvider>(context, listen: false);
    RoomDataProvider roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    void navigateToMainMenu(BuildContext context) {
      Navigator.of(context).pushNamed('/main_menu');
    }

    Color shadowColor =
        text == roomDataProvider.player1.nickname ? Colors.pink : Colors.green;

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
                        animation: _animationController1,
                        builder: (context, child) {
                          Color shadowColor =
                              text == roomDataProvider.player1.nickname
                                  ? Colors.pink
                                  : Colors.green;
                          return Transform.scale(
                            scale: _animation.value,
                            child: text == ''
                                ? SizedBox
                                    .shrink() //text should be added after this otherwise it gives error
                                : Text(
                                    '${text == roomDataProvider.player1.nickname ? 'X' : 'O'}',
                                    style: TextStyle(
                                      fontSize: 55,
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
                              text,
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
                      SizedBox(width: 15),
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
                          clearBoard(context);
                          // _showAd(AdManager.interstitialVideoAdPlacementId);
                          _showInterstitialAd();
                          Navigator.pop(context);
//                 //navigateToMainMenu(context);
                          Navigator.pushNamed(
                              context, MainMenuScreen.routeName);
//
                          gameState.reset();
                        },
                      ),
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
                    animation: _animationController1,
                    builder: (context, child) {
                      Color shadowColor =
                          text == roomDataProvider.player1.nickname
                              ? Colors.pink
                              : Colors.green;
                      return Transform.scale(
                        scale: _animation.value,
                        child: text == ''
                            ? SizedBox
                                .shrink() //text should be added after this otherwise it gives error
                            : Text(
                                '${text == roomDataProvider.player1.nickname ? 'X' : 'O'}',
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
                          text,
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
                  SizedBox(width: 15),
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
                      clearBoard(context);
                      //_showAd(AdManager.interstitialVideoAdPlacementId);
                      _showInterstitialAd();
                      Navigator.pop(context);
//                 //navigateToMainMenu(context);
                      Navigator.pushNamed(context, MainMenuScreen.routeName);
//
                      gameState.reset();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void endGameListener(BuildContext context) {
    _socketClient.on('endGame', (playerData) {
      //final gameState = Provider.of<RoomDataProvider>(context, listen: false);
      //_socketClient.emit('reset', {'id': 'roomId'});
      //gameState.reset();
      Navigator.pop(context);
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const MainMenuScreen(),
      //   ),
      // );
      // Navigator.pushNamed(context, MainMenuScreen.routeName);//working

      showEndGameDialog(context, '${playerData['nickname']}');
      _animationController1.repeat(reverse: true);
      //Navigator.popUntil(context, ModalRoute.withName('/main_menu'));
      //Navigator.popUntil(context, (route) => false);
    });
  }

  void showGameDialog(BuildContext context, String text) {
    RoomDataProvider roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    String dialogContent = '';

    if (text == 'Draw') {
      dialogContent = 'The round was a tie!';
    } else {
      dialogContent = '$text won the round!';
    }

    Timer? timer = Timer(Duration(milliseconds: 5000), () {
      _winningLine.clear();
      clearBoard(context);
      _rotateController.stop();
      _rotateController.reset();
      _controller.stop();
      _controller.reset();
      Navigator.pop(context);
    });

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
                          'Round ${roomDataProvider.roomData['currentRound']} Result',
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
                          animation: _animationController1,
                          builder: (context, child) {
                            Color shadowColor =
                                text == roomDataProvider.player1.nickname
                                    ? Colors.pink
                                    : Colors.green;
                            return Transform.scale(
                              scale: _animation.value,
                              child: text == 'Draw'
                                  ? SizedBox
                                      .shrink() //text should be added after this otherwise it gives error
                                  : Text(
                                      '${text == roomDataProvider.player1.nickname ? 'X' : 'O'}',
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
                            fontSize: 20,
                            color: Colors.white,
                            shadows: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.8),
                                blurRadius: 12,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '${text == "Draw" ? "The round will restart in..." : "The next round starting in..."}',
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                        SizedBox(height: 5),
                        CustomTimer(
                          from: Duration(seconds: 5),
                          to: Duration(seconds: 0),
                          onBuildAction: CustomTimerAction.auto_start,
                          builder: (CustomTimerRemainingTime remaining) {
                            return Text(
                              '${remaining.secondsWithoutFill}',
                              style: TextStyle(
                                  fontSize: 30.0, color: Colors.white),
                            );
                          },
                        ),
                        // ElevatedButton(
                        //   child: Text(
                        //     'OK',
                        //     style: TextStyle(
                        //       fontSize: 18,
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        //   style: ElevatedButton.styleFrom(
                        //     primary: Colors.purple, // background color
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(
                        //           18.0), // rounded corner radius
                        //     ),
                        //   ),
                        //   onPressed: () {
                        //     _winningLine.clear();
                        //     clearBoard(context);
                        //     Navigator.pop(context);
                        //   },
                        // ),
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
                    'Round ${roomDataProvider.roomData['currentRound']} Result',
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
                    animation: _animationController1,
                    builder: (context, child) {
                      Color shadowColor =
                          text == roomDataProvider.player1.nickname
                              ? Colors.pink
                              : Colors.green;
                      return Transform.scale(
                        scale: _animation.value,
                        child: text == 'Draw'
                            ? SizedBox
                                .shrink() //text should be added after this otherwise it gives error
                            : Text(
                                '${text == roomDataProvider.player1.nickname ? 'X' : 'O'}',
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
                  Text(
                    'The next round starting in...',
                    style: TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  CustomTimer(
                    from: Duration(seconds: 5),
                    to: Duration(seconds: 0),
                    onBuildAction: CustomTimerAction.auto_start,
                    builder: (CustomTimerRemainingTime remaining) {
                      return Text(
                        'the next round starting in...${remaining.secondsWithoutFill}',
                        style: TextStyle(fontSize: 30.0, color: Colors.white),
                      );
                    },
                  ),
                  // ElevatedButton(
                  //   child: Text(
                  //     'OK',
                  //     style: TextStyle(
                  //       fontSize: 18,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  //   style: ElevatedButton.styleFrom(
                  //     primary: Colors.purple, // background color
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(
                  //           18.0), // rounded corner radius
                  //     ),
                  //   ),
                  //   onPressed: () {
                  //     _winningLine.clear();
                  //     clearBoard(context);
                  //     Navigator.pop(context);
                  //   },
                  // ),
                ],
              ),
            ),
          );
        }).then((value) {
      // dispose the timer in case something else has triggered the dismiss.
      timer?.cancel();
      timer = null;
    });

    // Future.delayed(Duration(seconds: 5), () {
    //   Navigator.of(context).pop();
    //   _winningLine.clear();
    //   clearBoard(context);
    // });

    // showDialog(
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Text('Round ${roomDataProvider.roomData['currentRound']}'),
    //         actions: [
    //           TextButton(
    //             onPressed: () {
    //               clearBoard(context);
    //               Navigator.pop(context);
    //               //increaseRound(roomDataProvider);
    //             },
    //             child: const Text(
    //               'Play Again',
    //             ),
    //           ),
    //         ],
    //       );
    //     });
  }

  void checkWinner(BuildContext context, Socket socketClient) {
    RoomDataProvider roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    String winner = ''; //'X' or 'O'
    int filledBoxes = 0;

    // Checking rows
    if (roomDataProvider.displayElements[0] ==
            roomDataProvider.displayElements[1] &&
        roomDataProvider.displayElements[0] ==
            roomDataProvider.displayElements[2] &&
        roomDataProvider.displayElements[0] != '') {
      winner = roomDataProvider.displayElements[0];
    }
    if (roomDataProvider.displayElements[3] ==
            roomDataProvider.displayElements[4] &&
        roomDataProvider.displayElements[3] ==
            roomDataProvider.displayElements[5] &&
        roomDataProvider.displayElements[3] != '') {
      winner = roomDataProvider.displayElements[3];
    }
    if (roomDataProvider.displayElements[6] ==
            roomDataProvider.displayElements[7] &&
        roomDataProvider.displayElements[6] ==
            roomDataProvider.displayElements[8] &&
        roomDataProvider.displayElements[6] != '') {
      winner = roomDataProvider.displayElements[6];
    }

    // Checking Column
    if (roomDataProvider.displayElements[0] ==
            roomDataProvider.displayElements[3] &&
        roomDataProvider.displayElements[0] ==
            roomDataProvider.displayElements[6] &&
        roomDataProvider.displayElements[0] != '') {
      winner = roomDataProvider.displayElements[0];
    }
    if (roomDataProvider.displayElements[1] ==
            roomDataProvider.displayElements[4] &&
        roomDataProvider.displayElements[1] ==
            roomDataProvider.displayElements[7] &&
        roomDataProvider.displayElements[1] != '') {
      winner = roomDataProvider.displayElements[1];
    }
    if (roomDataProvider.displayElements[2] ==
            roomDataProvider.displayElements[5] &&
        roomDataProvider.displayElements[2] ==
            roomDataProvider.displayElements[8] &&
        roomDataProvider.displayElements[2] != '') {
      winner = roomDataProvider.displayElements[2];
    }

    // Checking Diagonal
    if (roomDataProvider.displayElements[0] ==
            roomDataProvider.displayElements[4] &&
        roomDataProvider.displayElements[0] ==
            roomDataProvider.displayElements[8] &&
        roomDataProvider.displayElements[0] != '') {
      winner = roomDataProvider.displayElements[0];
    }
    if (roomDataProvider.displayElements[2] ==
            roomDataProvider.displayElements[4] &&
        roomDataProvider.displayElements[2] ==
            roomDataProvider.displayElements[6] &&
        roomDataProvider.displayElements[2] != '') {
      winner = roomDataProvider.displayElements[2];
    }

    if (winner != '') {
      if (roomDataProvider.player1.playerType == winner) {
        showGameDialog(context, '${roomDataProvider.player1.nickname}');
        //display game dialog box saying player 1 is the winner
        _animationController1.repeat(reverse: true);
        socketClient.emit('winner', {
          'winnerSocketId': roomDataProvider.player1.socketID,
          'roomId': roomDataProvider.roomData['_id'],
        });
        Future.delayed(Duration(seconds: 3), () {
          _controller.stop();
          _rotateController.stop();
        });
        _rotateController.repeat(reverse: true);
        _controller.repeat(reverse: true);
        //increaseRound(roomDataProvider);
      } else {
        showGameDialog(context, '${roomDataProvider.player2.nickname}');
        //display game dialog box saying player 2 is the winner
        _animationController1.repeat(reverse: true);
        socketClient.emit('winner', {
          'winnerSocketId': roomDataProvider.player2.socketID,
          'roomId': roomDataProvider.roomData['_id'],
        });
        Future.delayed(Duration(seconds: 3), () {
          _controller.stop();
          _rotateController.stop();
        });
        _rotateController.repeat(reverse: true);
        _controller.repeat(reverse: true);
        // increaseRound(roomDataProvider);
      }
    } else if (roomDataProvider.filledBoxes == 9) {
      winner = '';
      //display game dialog box saying draw
      showGameDialog(context, 'Draw');
    }
  }

  void clearBoard(BuildContext context) {
    RoomDataProvider roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    for (int i = 0; i < roomDataProvider.displayElements.length; i++) {
      roomDataProvider.updateDisplayElements(i, '');
    }
    roomDataProvider.setFilledBoxesTo0();
  }

  void _loadInterstitialAd() async {
    final adUnitId = AdHelper.interstitialAdUnitId;
    final adRequest = AdRequest();
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: adRequest,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad admob loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd admob failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _loadInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // void _loadAd(String placementId) async {
  //   await UnityAds.load(
  //     placementId: AdManager.interstitialVideoAdPlacementId,
  //   );
  // }

  // void _showAd(String placementId) {
  //   UnityAds.showVideoAd(
  //     placementId: placementId,
  //     onComplete: (placementId) {
  //       print('Video Ad $placementId completed');
  //       _loadAd(placementId);
  //     },
  //     onFailed: (placementId, error, message) {
  //       print('Video Ad $placementId failed: $error $message');
  //       _loadAd(placementId);
  //     },
  //     onStart: (placementId) => print('Video Ad $placementId started'),
  //     onClick: (placementId) => print('Video Ad $placementId click'),
  //     onSkipped: (placementId) {
  //       print('Video Ad $placementId skipped');
  //       _loadAd(placementId);
  //     },
  //   );
  // }
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
      ..strokeCap = StrokeCap.square;

    final boxSize = size.width / 3;
    final start = Offset(
      (boxes.first % 3 + 0.5) * boxSize,
      (boxes.first ~/ 3 + 0.5) * boxSize,
    );
    final end = Offset(
      (boxes.last % 3 + 0.5) * boxSize,
      (boxes.last ~/ 3 + 0.5) * boxSize,
    );

    final lineLength = (end - start).distance;
    final currentLength = lineLength * progress;

    final currentEnd = start + ((end - start) * (currentLength / lineLength));

    canvas.drawLine(
      start,
      currentEnd,
      paint,
    );
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
