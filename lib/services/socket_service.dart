import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  late io.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  io.Socket get socket => _socket;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    _socket = io.io(
      'http://172.16.30.25:3000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    // Escuchar el evento de conexión de forma explícita
    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    // Escuchar el evento de desconexión
    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    // _socket.on('emitir-mensaje', (payload) {
    //   debugPrint('Nuevo-mensaje: $payload');
    //   debugPrint(
    //     payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No hay',
    //   );
    // });

    //  Escuchar errores de conexión
    _socket.onConnectError((data) => debugPrint('Error de conexión: $data'));
    // _socket.onTypeError((data) => debugPrint('Error de tipo: $data'));
  }
}
