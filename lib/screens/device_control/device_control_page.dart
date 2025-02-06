import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
  bool lightState = false;
  bool fanState = false;

  @override
  void initState() {
    super.initState();
    _deviceRef = FirebaseDatabase.instance
        .ref()
        .child('classrooms')
        .child(widget.batch)
        .child(widget.department)
        .child(widget.classroomId)
        .child('devices');

    // Listen for real-time updates
    _deviceRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          lightState = data['light'] ?? false;
          fanState = data['fan'] ?? false;
        });
      }
    });
  }

  void _toggleLight() {
    _deviceRef.update({'light': !lightState});
  }

  void _toggleFan() {
    _deviceRef.update({'fan': !fanState});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Device Control"),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text("Light"),
            trailing: Switch(
              value: lightState,
              onChanged: (value) => _toggleLight(),
            ),
          ),
          ListTile(
            title: Text("Fan"),
            trailing: Switch(
              value: fanState,
              onChanged: (value) => _toggleFan(),
            ),
          ),
        ],
      ),
    );
  }
}
