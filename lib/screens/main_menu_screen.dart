// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tictactoe_mp/responsive/responsive.dart';
import 'package:tictactoe_mp/screens/create_room_screen.dart';
import 'package:tictactoe_mp/screens/join_room_screen.dart';
import 'package:tictactoe_mp/screens/main_menu_game_modes_screen.dart';
import 'package:tictactoe_mp/utils/ad_helper.dart';
import 'package:tictactoe_mp/utils/ad_manager.dart';
import 'package:tictactoe_mp/utils/colors.dart';
import 'package:tictactoe_mp/widgets/custom_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class MainMenuScreen extends StatefulWidget {
  static String routeName = '/main_menu';

  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
//admob
  BannerAd? _bannerAd;

  Future<bool> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    } else {
      try {
        final response = await InternetAddress.lookup('google.com');
        if (response.isNotEmpty && response[0].rawAddress.isNotEmpty) {
          return true;
        } else {
          return false;
        }
      } on SocketException catch (_) {
        return false;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // UnityAds.init(
    //   gameId: AdManager.gameId,
    //   testMode: false,
    //   onComplete: () {
    //     print('Initialization Complete');
    //     _loadAd(AdManager.bannerAdPlacementId);
    //   },
    //   onFailed: (error, message) =>
    //       print('Initialization Failed: $error $message'),
    // );
    _loadBannerAd();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();
    super.dispose();
  }

  void createRoom(BuildContext context) async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      Navigator.pushNamed(context, CreateRoomScreen.routeName);
    } else {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: "No Internet Connection",
        text: "Please check your internet connection and try again.",
        confirmBtnText: "OK",
        barrierDismissible: false,
        confirmBtnColor: Colors.purpleAccent,
        backgroundColor: Colors.purple,
        onConfirmBtnTap: () => Navigator.pop(context),
      );
    }
  }

  void joinRoom(BuildContext context) async {
    bool isConnected = await checkInternetConnection();
    if (isConnected) {
      Navigator.pushNamed(context, JoinRoomScreen.routeName);
    } else {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        title: "No Internet Connection",
        text: "Please check your internet connection and try again.",
        confirmBtnText: "OK",
        barrierDismissible: false,
        confirmBtnColor: Colors.purpleAccent,
        backgroundColor: Colors.purple,
        onConfirmBtnTap: () => Navigator.pop(context),
      );
    }
  }
  // void createRoom(BuildContext context) {
  //   Navigator.pushNamed(context, CreateRoomScreen.routeName);
  // }

  // void joinRoom(BuildContext context) {
  //   Navigator.pushNamed(context, JoinRoomScreen.routeName);
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onHorizontalDragUpdate: (_) {},
        child: Scaffold(
          backgroundColor: bgColor,
          body: Stack(children: [
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => _goToMainMenu(),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 55),
                  _buildButton(
                    context,
                    'Host Match',
                    () => createRoom(context),
                  ),
                  const SizedBox(height: 28),
                  _buildButton(
                    context,
                    'Join Match',
                    () => joinRoom(context),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Positioned.fill(
              bottom: 0, // Position the container at the bottom of the screen
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 50, // Set the desired height of the banner ad
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed,
      [bool isDifferent = false]) {
    final buttonStyle = ElevatedButton.styleFrom(
        primary: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: const StadiumBorder(),
        side: BorderSide(
          width: 1.0,
          color: Colors.purpleAccent.withOpacity(0.3),
        ),
        elevation: 20.0,
        shadowColor: isDifferent
            ? Colors.pink.withOpacity(0.9)
            : Color.fromARGB(255, 21, 125, 211));

    final gradient = isDifferent
        ? LinearGradient(
            colors: [
              Colors.pink.withOpacity(0.5),
              Colors.pink.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              boardBorderColor.withOpacity(0.5),
              PrimaryColor.withOpacity(0.3),
              boardBorderColor.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return SizedBox(
      width: 250, // Fixed width for all buttons
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: gradient,
        ),
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.blueAccent.withOpacity(0.9),
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToMainMenu() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          // Build the page you want to navigate to
          return MainMenuGameModesScreen();
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

  void _loadBannerAd() async {
    final adUnitId = AdHelper.bannerAdUnitId;

    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('Banner Ad loaded.');
          setState(() {});
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner Ad failed to load: $error');
        },
      ),
      request: AdRequest(),
    );

    _bannerAd?.load();
  }

  // void _loadAd(String placementId) async {
  //   await UnityAds.load(
  //     placementId: AdManager.bannerAdPlacementId,
  //   );
  // }
}



//  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Responsive(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CustomButton(
//             onTap: () => createRoom(context),
//             text: 'Create Room',
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           CustomButton(
//             onTap: () => joinRoom(context),
//             text: 'Join Room',
//           ),
//         ],
//       ),
//     ));
//   }
