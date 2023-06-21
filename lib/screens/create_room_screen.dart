import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tictactoe_mp/resources/socket_methods.dart';
import 'package:tictactoe_mp/responsive/responsive.dart';
import 'package:tictactoe_mp/screens/main_menu_screen.dart';
import 'package:tictactoe_mp/utils/ad_helper.dart';
import 'package:tictactoe_mp/utils/ad_manager.dart';
import 'package:tictactoe_mp/widgets/custom_button.dart';
import 'package:tictactoe_mp/widgets/custom_text.dart';
import 'package:tictactoe_mp/widgets/custom_textfield.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class CreateRoomScreen extends StatefulWidget {
  static String routeName = '/create-room';
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final SocketMethods _socketMethods = SocketMethods();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late bool _isConnected;

  //admob
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _socketMethods.createRoomSuccessListener(context);
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
    _nameController.dispose();
    _navigatorKey.currentState?.dispose();
    _bannerAd?.dispose();
    super.dispose();
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
        child: Builder(
          builder: (context) {
            return Navigator(
              key: _navigatorKey,
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => Scaffold(
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
                                  color: Colors.blueAccent,
                                )
                              ], text: 'Host Match', fontSize: 40),
                              SizedBox(height: size.height * 0.04),
                              CustomTextfield(
                                controller: _nameController,
                                hintText: 'Enter your nickname',
                                limit: 5,
                              ),
                              SizedBox(height: size.height * 0.03),
                              CustomButton(
                                onTap: () async {
                                  if (!_isConnected) {
                                    showNoInternetConnectionAlert(context);
                                    return;
                                  }

                                  final isConnected =
                                      await checkInternetConnection();
                                  if (isConnected) {
                                    _socketMethods
                                        .createRoom(_nameController.text);
                                  } else {
                                    showNoInternetConnectionAlert(context);
                                  }
                                },
                                text: 'Host',
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        bottom:
                            0, // Position the container at the bottom of the screen
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height:
                                50, // Set the desired height of the banner ad
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        ),
                      ),
                    ]),
                  ),
                );
              },
            );
          },
        ),
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


// @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Builder(
//       builder: (context) {
//         return Navigator(
//           key: _navigatorKey,
//           onGenerateRoute: (settings) {
//             return MaterialPageRoute(
//               builder: (context) => Scaffold(
//                 body: Responsive(
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       // ignore: prefer_const_literals_to_create_immutables
//                       children: [
//                         const CustomText(shadows: [
//                           Shadow(
//                             blurRadius: 40,
//                             color: Colors.blue,
//                           )
//                         ], text: 'Create Room', fontSize: 70),
//                         SizedBox(height: size.height * 0.08),
//                         CustomTextfield(
//                             controller: _nameController,
//                             hintText: 'Enter your nickname'),
//                         SizedBox(height: size.height * 0.02),
//                         CustomButton(
//                             onTap: () => _socketMethods.createRoom(
//                                   _nameController.text,
//                                 ),
//                             text: 'Create'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }