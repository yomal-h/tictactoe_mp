import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:tictactoe_mp/resources/socket_methods.dart';
import 'package:tictactoe_mp/responsive/responsive.dart';
import 'package:tictactoe_mp/screens/main_menu_screen.dart';
import 'package:tictactoe_mp/utils/ad_manager.dart';
import 'package:tictactoe_mp/widgets/custom_button.dart';
import 'package:tictactoe_mp/widgets/custom_text.dart';
import 'package:tictactoe_mp/widgets/custom_textfield.dart';

class JoinRoomScreen extends StatefulWidget {
  static String routeName = '/join-room';
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gameIdController = TextEditingController();
  final SocketMethods _socketMethods = SocketMethods();
  late bool _isConnected = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isConnected = true;
    _socketMethods.joinRoomSuccessListener(context);
    _socketMethods.errorOccuredListener(context);
    _socketMethods.updatePlayersStateListener(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _gameIdController.dispose();
  }

  Future<void> initConnectivity() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  Future<bool> checkInternetConnection() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      return false;
    } else {
      try {
        final response = await InternetAddress.lookup('google.com');
        if (response.isNotEmpty && response[0].rawAddress.isNotEmpty) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }
  }

  // Future<bool> checkInternetConnection() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   return connectivityResult != ConnectivityResult.none;
  // }

  void showNoInternetConnectionAlert(BuildContext context) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.warning,
      title: "No Internet Connection",
      text: "Please check your internet connection and try again.",
      confirmBtnText: "OK",
      barrierDismissible: false,
      confirmBtnColor: Colors.purpleAccent,
      backgroundColor: Colors.purple,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onHorizontalDragUpdate: (_) {},
        child: Scaffold(
            body: Stack(
          children: [
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => _goToMainMenu(),
              ),
            ),
            Responsive(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const CustomText(shadows: [
                      Shadow(
                        blurRadius: 40,
                        color: Colors.blue,
                      )
                    ], text: 'Join Match', fontSize: 40),
                    SizedBox(height: size.height * 0.04),
                    CustomTextfield(
                      controller: _nameController,
                      hintText: 'Enter your nickname',
                      limit: 5,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomTextfield(
                      controller: _gameIdController,
                      hintText: 'Enter Game ID',
                      limit: 15,
                    ),
                    SizedBox(height: size.height * 0.03),
                    CustomButton(
                      onTap: () async {
                        if (!_isConnected) {
                          showNoInternetConnectionAlert(context);
                          return;
                        }

                        final isConnected = await checkInternetConnection();
                        if (isConnected) {
                          _socketMethods.joinRoom(
                              _nameController.text, _gameIdController.text);
                        } else {
                          showNoInternetConnectionAlert(context);
                        }
                      },
                      text: 'Join',
                    ),
                    // CustomButton(
                    //     onTap: (() => _socketMethods.joinRoom(
                    //         _nameController.text, _gameIdController.text)),
                    //     text: 'Join'
                    //     ),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  void _goToMainMenu() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          // Build the page you want to navigate to
          return MainMenuScreen();
        },
        transitionDuration:
            Duration(milliseconds: 250), // Set the duration of the animation
        transitionsBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child) {
          // Define the animation for the transition
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
