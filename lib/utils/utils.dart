import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/resources/game_methods.dart';
import 'package:tictactoe_mp/screens/main_menu_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tictactoe_mp/utils/colors.dart';
import 'package:spring/spring.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

void showGameDialog(BuildContext context, String text) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                GameMethods().clearBoard(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Play Again',
              ),
            ),
          ],
        );
      });
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

  final SpringController springController = SpringController();

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
                    Spring.scale(
                      //animation lik e zoomIn
                      start: 0.2,
                      end: 1.0,
                      child: Container(
                        child: text == ''
                            ? SizedBox.shrink()
                            : Text(
                                '${text == roomDataProvider.player1.nickname ? 'X' : 'O'}',
                                style: TextStyle(
                                  fontSize: 65,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(blurRadius: 60, color: shadowColor)
                                  ],
                                ),
                              ),
                      ),
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
                          GameMethods().clearBoard(context);

                          Navigator.pop(context);
//                 //navigateToMainMenu(context);
                          Navigator.pushNamed(
                              context, MainMenuScreen.routeName);
//
                          gameState.reset();
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
                          GameMethods().clearBoard(context);

                          Navigator.pop(context);
//                 //navigateToMainMenu(context);
                          Navigator.pushNamed(
                              context, MainMenuScreen.routeName);
//
                          gameState.reset();
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
                Builder(
                  builder: (context) {
                    Color shadowColor =
                        text == roomDataProvider.player1.nickname
                            ? Colors.pink
                            : Colors.green;
                    return text == ''
                        ? SizedBox
                            .shrink() //text should be added after this otherwise it gives error
                        : Text(
                            '${text == roomDataProvider.player1.nickname ? 'X' : 'O'}',
                            style: TextStyle(
                              fontSize: 65,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 60, color: shadowColor)
                              ],
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
                      GameMethods().clearBoard(context);

                      Navigator.pop(context);
//                 //navigateToMainMenu(context);
                      Navigator.pushNamed(context, MainMenuScreen.routeName);
//
                      gameState.reset();
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
                      GameMethods().clearBoard(context);

                      Navigator.pop(context);
//                 //navigateToMainMenu(context);
                      Navigator.pushNamed(context, MainMenuScreen.routeName);
//
                      gameState.reset();
                    },
                  ),
                ]),
              ],
            ),
          ),
        );
      });
}

// showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(text),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 GameMethods().clearBoard(context);
//                 // Navigator.pushReplacement(
//                 //   context,
//                 //   MaterialPageRoute(
//                 //     builder: (context) => const MainMenuScreen(),
//                 //   ),
//                 // );
//                 Navigator.pop(context);
//                 //navigateToMainMenu(context);
//                 Navigator.pushNamed(context, MainMenuScreen.routeName);
//                 // Navigator.pushNamed(
//                 //   context,
//                 //   MainMenuScreen.routeName,
//                 // );
//                 gameState.reset();

//                 //Navigator.of(context).popUntil((route) => route.isFirst);
//               },
//               child: const Text(
//                 'Main Menu',
//               ),
//             ),
//           ],
//         );
//       });
