import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Band> bands = [
    Band(id: '', name: 'Arroladora Banda el Limon', votes: 5),
    Band(id: '', name: 'La Trakalosa de Monterrey', votes: 5),
    Band(id: '', name: 'No se', votes: 5),
    Band(id: '', name: 'Chi che', votes: 5),
  ];

  void addNewBand() {
    final textController = TextEditingController();

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Text('New band name:'),
            content: CupertinoTextField(controller: textController),
            actions: [
              CupertinoDialogAction(
                onPressed: () => addBandToList(textController.text),
                isDefaultAction: true,
                child: const Text('Add'),
              ),
              CupertinoDialogAction(
                onPressed: () =>
                    Navigator.canPop(context) ? Navigator.pop(context) : null,
                isDestructiveAction: true,
                child: const Text('Dismiss'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('New band name:'),
            content: TextField(controller: textController),
            actions: [
              MaterialButton(
                onPressed: () => addBandToList(textController.text),
                elevation: 5,
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      bands.add(Band(id: DateTime.now().toString(), name: name));
      setState(() {});
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        elevation: 3,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (BuildContext context, int index) =>
            _BandTile(band: bands[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add),
      ),
    );
  }
}

class _BandTile extends StatelessWidget {
  const _BandTile({required this.band});

  final Band band;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        debugPrint('Direction: $direction');
        debugPrint('id: ${band.id}');
        // TODO: Llamar el borrado en el server
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.only(left: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Detele Band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
        onTap: () {
          debugPrint(band.name);
        },
      ),
    );
  }
}
