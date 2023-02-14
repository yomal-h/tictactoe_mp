import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';
import 'package:tictactoe_mp/widgets/custom_textfield.dart';

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
        const Text('Waiting for a player to join...'),
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
        const Text(
            'Please share this Game ID with the player you want to play'),
        ElevatedButton(
          onPressed: () {
            ShareExtend.share(roomIdController.text, "text");
          },
          child: const Text('Share'),
        ),
      ],
    );
  }
}
