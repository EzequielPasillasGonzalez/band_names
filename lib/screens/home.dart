import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Band> bands = [];

  @override
  void initState() {
    super.initState();

    final SocketService socketService = Provider.of<SocketService>(
      context,
      listen: false,
    );
    socketService.socket.on('active-bands', (data) {
      // Verificamos si el widget sigue existiendo en el árbol antes de redibujar
      if (mounted) {
        setState(() {
          bands = (data as List).map((e) => Band.fromMap(e)).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    final SocketService socketService = Provider.of<SocketService>(
      context,
      listen: false,
    );

    socketService.socket.off('active-bands');
    super.dispose();
  }

  void addNewBand() {
    final textController = TextEditingController();

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
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
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('New band name:'),
          content: TextField(controller: textController),
          actions: [
            MaterialButton(
              onPressed: () => addBandToList(textController.text),
              elevation: 5,
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final SocketService socketService = Provider.of<SocketService>(
        context,
        listen: false,
      );
      socketService.socket.emit('add-band', {'band': name});
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SocketService socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
        elevation: 3,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red[300]),
          ),
        ],
      ),

      body: Column(
        children: [
          _ShowGrafica(bands: bands),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) =>
                  _BandTile(band: bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add),
      ),
    );
  }
}

class _ShowGrafica extends StatelessWidget {
  final List<Band> bands;
  const _ShowGrafica({required this.bands});

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {};

    for (var band in bands) {
      dataMap[band.name] = band.votes.toDouble();
    }

    if (dataMap.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final List<Color> colorList = [
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.red,
      Colors.green,
    ];

    return Expanded(
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "Bands",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
      ),
    );
  }
}

class _BandTile extends StatelessWidget {
  const _BandTile({required this.band});

  final Band band;

  @override
  Widget build(BuildContext context) {
    final SocketService socketService = Provider.of<SocketService>(context);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) =>
          socketService.socket.emit('delete-band', {'id': band.id}),
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
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }
}
