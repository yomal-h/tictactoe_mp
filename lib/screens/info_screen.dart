import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/screens/main_menu_game_modes_screen.dart';
import 'package:tictactoe_mp/utils/ad_helper.dart';
import 'package:tictactoe_mp/utils/ad_manager.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);
  static const routeName = '/info';

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
//admob
  BannerAd? _bannerAd;

  @override
  void initState() {
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
    // _roomProvider = RoomDataProvider();
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
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Help',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 25.0),
                        Text(
                          'Objective:',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Get three of your symbols (X or O) in a row on a 3x3 grid.',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Singleplayer Mode:',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Play against the computer. You are X and the computer is O.',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Multiplayer Mode (Offline):',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Play against a friend on the same device. One player is X and the other is O.',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Multiplayer Mode (Online):',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          'Play against other people online. Share the game ID with your opponent and take turns placing Xs and Os.',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Rules:',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          '1. X always goes first.\n2. Players take turns placing their symbols on the grid. \n3. Each game mode consists of 5 rounds. \n4. The round is over when one player gets three of their symbols in a row or there are no more empty cells on the grid.\n5. If all cells are filled and there is no winner, the round ends in a tie.',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
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
            ],
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
