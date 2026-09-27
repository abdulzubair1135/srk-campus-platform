import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants.dart';

typedef SocketCallback = void Function(dynamic data);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  io.Socket? socket;
  bool isConnected = false;
  final Map<String, List<SocketCallback>> _listeners = {};

  SocketService._internal();

  void init(String token) {
    if (socket != null && socket!.connected) {
      return;
    }

    try {
      socket = io.io(
        AppConstants.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .enableReconnection()
            .build(),
      );

      socket!.onConnect((_) {
        isConnected = true;
      });

      socket!.onDisconnect((_) {
        isConnected = false;
      });

      // Forward events
      socket!.on('meeting.new', (data) => _notify('meeting.new', data));
      socket!.on('meeting.updated', (data) => _notify('meeting.updated', data));
      socket!.on('radar.updated', (data) => _notify('radar.updated', data));
      socket!.on('broadcast.new', (data) => _notify('broadcast.new', data));
    } catch (e) {
      // Ignore socket connection errors gracefully
    }
  }

  void on(String event, SocketCallback callback) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = [];
    }
    _listeners[event]!.add(callback);
  }

  void off(String event, SocketCallback callback) {
    _listeners[event]?.remove(callback);
  }

  void _notify(String event, dynamic data) {
    if (_listeners.containsKey(event)) {
      for (final cb in _listeners[event]!) {
        cb(data);
      }
    }
  }

  void disconnect() {
    socket?.disconnect();
    isConnected = false;
  }
}
