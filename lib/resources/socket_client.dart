import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  SocketClient();
  IO.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket =
        IO.io('https://tictactoe-mp-backend.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }

  void connect() {
    if (socket != null && !socket!.connected) {
      socket!.connect();
      print("Socket connected");
    }
  }

  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
      print("Socket disconnected");
    }
  }
}
