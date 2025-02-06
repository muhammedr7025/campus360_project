import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DepartmentEnergyReportPage extends StatefulWidget {
  final String department;
  const DepartmentEnergyReportPage({Key? key, required this.department})
      : super(key: key);

  @override
  _DepartmentEnergyReportPageState createState() =>
      _DepartmentEnergyReportPageState();
}

class _DepartmentEnergyReportPageState
    extends State<DepartmentEnergyReportPage> {
  final DatabaseReference _energyRef =
      FirebaseDatabase.instance.ref().child('energyLogs');
  double totalConsumption = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchEnergyConsumption();
  }

  void _fetchEnergyConsumption() async {
    DateTime now = DateTime.now();
    DateTime monthStart = DateTime(now.year, now.month, 1);
    int monthStartMillis = monthStart.millisecondsSinceEpoch;
    double sum = 0.0;

    // energyLogs structure: /energyLogs/{batch}/{department}/{classroomId}/logX
    DataSnapshot snapshot = await _energyRef.get();
    if (snapshot.exists && snapshot.value != null) {
      final data = snapshot.value as Map;
      data.forEach((batchKey, departments) {
        if (departments is Map && departments.containsKey(widget.department)) {
          var deptData = departments[widget.department];
          if (deptData is Map) {
            deptData.forEach((classroomId, logs) {
              if (logs is Map) {
                logs.forEach((logKey, logData) {
                  if (logData is Map) {
                    int timestamp = logData['timestamp'] ?? 0;
                    if (timestamp >= monthStartMillis) {
                      double energy = (logData['energy'] != null
                          ? (logData['energy'] as num).toDouble()
                          : 0.0);
                      sum += energy;
                    }
                  }
                });
              }
            });
          }
        }
      });
    }
    setState(() {
      totalConsumption = sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Energy Report - ${widget.department} Dept"),
      ),
      body: Center(
        child: Text(
          "Total Energy Consumption (Current Month): ${totalConsumption.toStringAsFixed(2)} kWh",
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
