import 'package:flutter/material.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tictactoe_mp/screens/main_menu_game_modes_screen.dart';
import 'package:tictactoe_mp/utils/ad_helper.dart';
import 'package:tictactoe_mp/utils/ad_manager.dart';

import 'package:tictactoe_mp/utils/colors.dart';
import 'package:tictactoe_mp/widgets/custom_flickering_menu_text.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class DifficultyLevelSelectionScreen extends StatefulWidget {
  static const routeName = '/difficulty_level_selection_screen';
  const DifficultyLevelSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DifficultyLevelSelectionScreen> createState() =>
      _DifficultyLevelSelectionScreenState();
}

class _DifficultyLevelSelectionScreenState
    extends State<DifficultyLevelSelectionScreen> {
//admob
  BannerAd? _bannerAd;

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
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
                  const SizedBox(height: 20),
                  Text(
                    'Select Difficulty',
                    style: TextStyle(
                      fontSize: 40,
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
                  const SizedBox(height: 55),
                  _buildButton(
                    context,
                    'Easy',
                    () => Navigator.pushReplacementNamed(
                        context, '/tictactoe_easy'),
                  ),
                  const SizedBox(height: 28),
                  _buildButton(
                    context,
                    'Medium',
                    () => Navigator.pushReplacementNamed(
                      context,
                      '/tictactoe_medium',
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildButton(
                    context,
                    'Hard',
                    () => Navigator.pushReplacementNamed(
                      context,
                      '/tictactoe_hard',
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildButton(
                    context,
                    'Expert',
                    () => Navigator.pushReplacementNamed(
                      context,
                      '/tictactoe_expert',
                    ),

                    true, // Make this button different
                  ),
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
      width: 200, // Fixed width for all buttons
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
    Navigator.pushAndRemoveUntil(
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
      (route) => false,
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

  // _showAd(String placementId) {
  //   UnityBannerAd(
  //     placementId: placementId,
  //     onLoad: (placementId) => print('Banner loaded: $placementId'),
  //     onClick: (placementId) => print('Banner clicked: $placementId'),
  //     onFailed: (placementId, error, message) =>
  //         print('Banner Ad $placementId failed: $error $message'),
  //   );
  // }
}
