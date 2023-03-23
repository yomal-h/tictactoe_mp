import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/widgets/custom_textfield.dart';
import 'package:lottie/lottie.dart';

class WaitingLobby extends StatefulWidget {
  const WaitingLobby({Key? key}) : super(key: key);

  @override
  State<WaitingLobby> createState() => _WaitingLobbyState();
}

class _WaitingLobbyState extends State<WaitingLobby> {
  late TextEditingController roomIdController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    roomIdController = TextEditingController(
      text:
          Provider.of<RoomDataProvider>(context, listen: false).roomData['_id'],
    );
    Provider.of<RoomDataProvider>(context, listen: false).setFilledBoxesTo0();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    roomIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/lottie/waiting.json',
          height: 200,
          width: 200,
        ),
        const Text('Waiting for a player to join...',
            style: TextStyle(color: Colors.white)),
        const Text(
          'Please share this Game ID with the player you want to play',
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(
          height: 20,
        ),
        CustomTextfield(
          controller: roomIdController,
          hintText: '',
          isReadOnly: true,
        ),
        const SizedBox(
          height: 20,
        ),

        Container(
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            gradient: LinearGradient(
              colors: [
                Colors.purpleAccent.withOpacity(0.8),
                Colors.purpleAccent.withOpacity(0.8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple,
                blurRadius: 12.0,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              ShareExtend.share(roomIdController.text, "text");
              // Add your logic here for when the button is pressed
            },
            icon: Icon(Icons.share),
            label: Text('Share'),
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
              elevation: MaterialStateProperty.all<double>(0.0),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
          ),
        ),
        // ElevatedButton.icon(
        //   onPressed: () {
        //     ShareExtend.share(roomIdController.text, "text");
        //   },
        //   icon: Icon(Icons.share),
        //   label: Text('Share'),
        //   style: ButtonStyle(
        //     backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        //   ),
        // ),
      ],
    );
  }
}
