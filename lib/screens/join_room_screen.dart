import 'package:flutter/material.dart';
import 'package:tictactoe_mp/resources/socket_methods.dart';
import 'package:tictactoe_mp/responsive/responsive.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
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
                color: Colors.blue,
              )
            ], text: 'Join Room', fontSize: 70),
            SizedBox(height: size.height * 0.08),
            CustomTextfield(
                controller: _nameController, hintText: 'Enter your nickname'),
            const SizedBox(
              height: 20,
            ),
            CustomTextfield(
                controller: _gameIdController, hintText: 'Enter Game ID'),
            SizedBox(height: size.height * 0.03),
            CustomButton(
                onTap: (() => _socketMethods.joinRoom(
                    _nameController.text, _gameIdController.text)),
                text: 'Join')
          ],
        ),
      ),
    ));
  }
}
