import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe_mp/provider/room_data_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Consumer<RoomDataProvider>(
        builder: (context, model, _) => SwitchListTile(
          title: Text('Background Music'),
          value: model.isPlaying,
          onChanged: (value) {
            model.toggleAudio();
          },
        ),
      ),
    );
  }
}
