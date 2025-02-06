// lib/screens/device_control/device_control_page.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class DeviceControlPage extends StatefulWidget {
  final String batch;
  final String department;
  final String classroomId;

  const DeviceControlPage({
    Key? key,
    required this.batch,
    required this.department,
    required this.classroomId,
  }) : super(key: key);

  @override
  _DeviceControlPageState createState() => _DeviceControlPageState();
}

class _DeviceControlPageState extends State<DeviceControlPage> {
  late DatabaseReference _deviceRef;
  late DatabaseReference _energyRef;

  // Device control states
  bool lightState = false;
  bool fanState = false;
  bool autoMode = false;

  // Sensor readings
  double temperature = 0.0;
  double moisture = 0.0;
  double lightIntensity = 0.0;

  // Current month energy consumption (kWh)
  double currentConsumption = 0.0;

  StreamSubscription<DatabaseEvent>? _deviceSubscription;
  StreamSubscription<DatabaseEvent>? _energySubscription;

  @override
  void initState() {
    super.initState();

    // Reference for device control
    _deviceRef = FirebaseDatabase.instance
        .ref()
        .child('classrooms')
        .child(widget.batch)
        .child(widget.department)
        .child(widget.classroomId)
        .child('devices');

    // Listen for real-time updates on device states and sensor values.
    _deviceSubscription = _deviceRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          lightState = data['light'] ?? false;
          fanState = data['fan'] ?? false;
          autoMode = data['autoMode'] ?? false;
          if (data['sensors'] != null) {
            Map sensors = data['sensors'];
            temperature = (sensors['temperature'] ?? 0).toDouble();
            moisture = (sensors['moisture'] ?? 0).toDouble();
            lightIntensity = (sensors['light'] ?? 0).toDouble();
          }
        });
      }
    });

    // Reference for energy logs.
    _energyRef = FirebaseDatabase.instance
        .ref()
        .child('energyLogs')
        .child(widget.batch)
        .child(widget.department)
        .child(widget.classroomId);

    // Fetch current month energy consumption.
    _fetchCurrentConsumption();
  }

  Future<void> _fetchCurrentConsumption() async {
    DateTime now = DateTime.now();
    DateTime monthStart = DateTime(now.year, now.month, 1);
    int monthStartMillis = monthStart.millisecondsSinceEpoch;

    // Listen for energy logs from the start of the current month.
    _energySubscription = _energyRef
        .orderByChild('timestamp')
        .startAt(monthStartMillis.toDouble())
        .onValue
        .listen((event) {
      double sum = 0.0;
      final data = event.snapshot.value as Map?;
      if (data != null) {
        data.forEach((key, value) {
          var energyVal = value['energy'];
          if (energyVal != null) {
            sum += (energyVal is num ? energyVal.toDouble() : 0.0);
          }
        });
      }
      setState(() {
        currentConsumption = sum;
      });
    });
  }

  // Toggle auto mode.
  void _toggleAutoMode(bool value) {
    _deviceRef.update({'autoMode': value});
  }

  // Toggle light manually (only if auto mode is off).
  void _toggleLight() {
    if (!autoMode) {
      _deviceRef.update({'light': !lightState});
    }
  }

  // Toggle fan manually (only if auto mode is off).
  void _toggleFan() {
    if (!autoMode) {
      _deviceRef.update({'fan': !fanState});
    }
  }

  // Download energy report: query energy logs for the current month, generate CSV, and save to file.
  Future<void> _downloadEnergyReport() async {
    DateTime now = DateTime.now();
    DateTime monthStart = DateTime(now.year, now.month, 1);
    int monthStartMillis = monthStart.millisecondsSinceEpoch;

    // Query energy logs starting from the beginning of the month.
    DataSnapshot snapshot = await _energyRef
        .orderByChild('timestamp')
        .startAt(monthStartMillis.toDouble())
        .get();

    StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln('Timestamp,Energy'); // CSV header

    if (snapshot.exists && snapshot.value != null) {
      Map data = snapshot.value as Map;
      data.forEach((key, value) {
        int timestamp = value['timestamp'] ?? 0;
        double energy = (value['energy'] != null
            ? (value['energy'] is num ? value['energy'].toDouble() : 0.0)
            : 0.0);
        String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
        csvBuffer.writeln('$formattedTime,$energy');
      });
    }

    try {
      Directory directory;
      if (Platform.isAndroid) {
        directory = (await getExternalStorageDirectory())!;
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      String fileName =
          'energy_report_${widget.classroomId}_${now.year}_${now.month}.csv';
      String filePath = '${directory.path}/$fileName';
      File file = File(filePath);
      await file.writeAsString(csvBuffer.toString());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Energy report downloaded: $filePath')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading report: $e')));
    }
  }

  @override
  void dispose() {
    _deviceSubscription?.cancel();
    _energySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Control"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Details Card
            Card(
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Batch: ${widget.batch}',
                        style: const TextStyle(fontSize: 16)),
                    Text('Department: ${widget.department}',
                        style: const TextStyle(fontSize: 16)),
                    Text('Classroom: ${widget.classroomId}',
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            // Auto Mode Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Auto Mode", style: TextStyle(fontSize: 18)),
                Switch(
                  value: autoMode,
                  onChanged: (value) => _toggleAutoMode(value),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Light Control (disabled in auto mode)
            ListTile(
              title: const Text("Light"),
              trailing: Switch(
                value: lightState,
                onChanged: autoMode ? null : (value) => _toggleLight(),
              ),
            ),
            const SizedBox(height: 20),
            // Fan Control (disabled in auto mode)
            ListTile(
              title: const Text("Fan"),
              trailing: Switch(
                value: fanState,
                onChanged: autoMode ? null : (value) => _toggleFan(),
              ),
            ),
            const Divider(height: 40),
            // Sensor Readings Section
            Text("Sensor Readings",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text("Temperature: ${temperature.toStringAsFixed(1)} °C",
                style: const TextStyle(fontSize: 16)),
            Text("Moisture: ${moisture.toStringAsFixed(1)} %",
                style: const TextStyle(fontSize: 16)),
            Text("Light Intensity: ${lightIntensity.toStringAsFixed(1)} lx",
                style: const TextStyle(fontSize: 16)),
            const Divider(height: 40),
            // Current Month Energy Consumption
            Text("Current Month Consumption",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text("${currentConsumption.toStringAsFixed(2)} kWh",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            // Download Energy Report Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _downloadEnergyReport,
                icon: const Icon(Icons.download),
                label: const Text("Download Energy Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
