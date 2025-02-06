import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AttendancePage extends StatefulWidget {
  final String batch;
  final String department;
  final String classroomId;

  const AttendancePage({
    Key? key,
    required this.batch,
    required this.department,
    required this.classroomId,
  }) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  Map<String, dynamic> attendanceData = {};

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    DatabaseReference attendanceRef = FirebaseDatabase.instance
        .ref()
        .child('classrooms')
        .child(widget.batch)
        .child(widget.department)
        .child(widget.classroomId)
        .child('attendance');

    final snapshot = await attendanceRef.get();
    if (snapshot.exists) {
      setState(() {
        attendanceData = Map<String, dynamic>.from(snapshot.value as Map);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance"),
      ),
      body: attendanceData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: attendanceData.entries.map((entry) {
                return ListTile(
                  title: Text("Date: ${entry.key}"),
                  subtitle: Text("Details: ${entry.value.toString()}"),
                );
              }).toList(),
            ),
    );
  }
}
