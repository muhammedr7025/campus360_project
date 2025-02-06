import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
  double energyConsumption = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchEnergyConsumption();
  }

  Future<void> _fetchEnergyConsumption() async {
    // For simplicity, we fetch all energy logs under the classroom and sum the energy values.
    DatabaseReference energyRef = FirebaseDatabase.instance
        .ref()
        .child('energyLogs')
        .child(widget.batch)
        .child(widget.department)
        .child(widget.classroomId);

    DataSnapshot snapshot = await energyRef.get();
    double sum = 0.0;
    if (snapshot.exists && snapshot.value != null) {
      final data = snapshot.value as Map;
      data.forEach((key, value) {
        if (value is Map && value['energy'] != null) {
          sum += (value['energy'] as num).toDouble();
        }
      });
    }
    setState(() {
      energyConsumption = sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Energy Consumption"),
      ),
      body: Center(
        child: Text(
          "Total Energy Consumption: ${energyConsumption.toStringAsFixed(2)} kWh",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
