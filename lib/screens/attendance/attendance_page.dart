import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'attendance_detail_page.dart'; // Make sure this file exists

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
  late DatabaseReference _attendanceRef;

  @override
  void initState() {
    super.initState();
    // Reference to attendance records for the given classroom.
    _attendanceRef = FirebaseDatabase.instance
        .ref()
        .child('classrooms')
        .child(widget.batch)
        .child(widget.department)
        .child(widget.classroomId)
        .child('attendance');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Records"),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _attendanceRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!.snapshot.value;
            if (data == null) {
              return const Center(child: Text("No attendance records found."));
            }
            // Assume attendance records are stored as a Map.
            Map records = data as Map;
            // Create a list of keys and sort them by timestamp descending.
            List keys = records.keys.toList();
            keys.sort((a, b) {
              int tsA = records[a]['timestamp'] ?? 0;
              int tsB = records[b]['timestamp'] ?? 0;
              return tsB.compareTo(tsA);
            });

            return ListView.builder(
              itemCount: keys.length,
              itemBuilder: (context, index) {
                String recordKey = keys[index].toString();
                Map record = Map<String, dynamic>.from(records[recordKey]);
                String teacher = record['teacher'] ?? "Unknown";
                String date = record['date'] ?? "Unknown Date";
                int timestamp = record['timestamp'] ?? 0;
                DateTime recordTime =
                    DateTime.fromMillisecondsSinceEpoch(timestamp);
                String formattedTime =
                    DateFormat('yyyy-MM-dd – kk:mm').format(recordTime);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text("Date: $date"),
                    subtitle: Text("Teacher: $teacher\nTime: $formattedTime"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Navigate to the attendance detail page.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceDetailPage(
                            attendanceRecord: record,
                            batch: widget.batch,
                            department: widget.department,
                            classroomId: widget.classroomId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
