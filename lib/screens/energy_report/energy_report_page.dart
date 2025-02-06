import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class EnergyReportPage extends StatefulWidget {
  final String batch;
  final String department;
  final String classroomId;

  const EnergyReportPage({
    Key? key,
    required this.batch,
    required this.department,
    required this.classroomId,
  }) : super(key: key);

  @override
  _EnergyReportPageState createState() => _EnergyReportPageState();
}

class _EnergyReportPageState extends State<EnergyReportPage> {
  List<charts.Series<dynamic, DateTime>> _seriesList = [];

  @override
  void initState() {
    super.initState();
    _fetchEnergyData();
  }

  Future<void> _fetchEnergyData() async {
    DatabaseReference energyRef = FirebaseDatabase.instance
        .ref()
        .child('energyLogs')
        .child(widget.batch)
        .child(widget.department)
        .child(widget.classroomId);

    final snapshot = await energyRef.get();
    List<EnergyData> data = [];
    if (snapshot.exists) {
      Map<dynamic, dynamic> logs = snapshot.value as Map;
      logs.forEach((key, value) {
        data.add(EnergyData(
          DateTime.fromMillisecondsSinceEpoch(value['timestamp']),
          value['energy']?.toDouble() ?? 0.0,
        ));
      });
    }

    setState(() {
      _seriesList = [
        charts.Series<EnergyData, DateTime>(
          id: 'Energy',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (EnergyData log, _) => log.time,
          measureFn: (EnergyData log, _) => log.energy,
          data: data,
        )
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Energy Consumption Report"),
      ),
      body: _seriesList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: charts.TimeSeriesChart(
                _seriesList,
                animate: true,
              ),
            ),
    );
  }
}

class EnergyData {
  final DateTime time;
  final double energy;
  EnergyData(this.time, this.energy);
}
