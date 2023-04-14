import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tictactoe_mp/resources/socket_methods.dart';
import 'package:tictactoe_mp/responsive/responsive.dart';
import 'package:tictactoe_mp/widgets/custom_button.dart';
import 'package:tictactoe_mp/widgets/custom_text.dart';
import 'package:tictactoe_mp/widgets/custom_textfield.dart';

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

  bool _isInternetAvailable = false;

  @override
  void initState() {
    super.initState();
    _socketMethods.createRoomSuccessListener(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _navigatorKey.currentState?.dispose();
    super.dispose();
  }

  Future<void> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          _isInternetAvailable = true;
        });
        _socketMethods.createRoomSuccessListener(context);
      }
    } on SocketException catch (_) {
      setState(() {
        _isInternetAvailable = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
              'Please check your internet connection and try again.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Builder(
      builder: (context) {
        return Navigator(
          key: _navigatorKey,
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Responsive(
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
                            onTap: () => _socketMethods.createRoom(
                                  _nameController.text,
                                ),
                            text: 'Host'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
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