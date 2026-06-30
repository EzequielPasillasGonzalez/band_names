import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Server Status: ${socketService.serverStatus}')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final Map<String, dynamic> mensaje = {
            'nombre': 'Flutter',
            'mensaje': 'Hola desde Flutter',
          };
          socketService.socket.emit('emitir-mensaje', mensaje);
        },
        child: Icon(Icons.message),
      ),
    );
  }
}
