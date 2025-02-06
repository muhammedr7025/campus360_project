import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class StudentAttendancePage extends StatefulWidget {
  final String batch;
  final String department;
  final String classroomId;
  final String studentUid; // The UID of the student

  const StudentAttendancePage({
    Key? key,
    required this.batch,
    required this.department,
    required this.classroomId,
    required this.studentUid,
  }) : super(key: key);

  @override
  _StudentAttendancePageState createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  late DatabaseReference _attendanceRef;
  List<Map<String, dynamic>> studentAttendanceRecords = [];

  @override
  void initState() {
    super.initState();
    // Reference to the attendance node for the given classroom.
    _attendanceRef = FirebaseDatabase.instance
        .ref()
        .child('classrooms')
        .child(widget.batch)
        .child(widget.department)
        .child(widget.classroomId)
        .child('attendance');

    // Listen for changes and filter records for this student.
    _attendanceRef.onValue.listen((event) {
      final data = event.snapshot.value;
      List<Map<String, dynamic>> records = [];
      if (data != null && data is Map) {
        data.forEach((recordKey, value) {
          if (value is Map) {
            Map<String, dynamic> record = Map<String, dynamic>.from(value);
            record['recordKey'] = recordKey;
            List present = record['present'] ?? [];
            List absent = record['absent'] ?? [];
            // Check if the student's UID appears in either list.
            if (present.contains(widget.studentUid) ||
                absent.contains(widget.studentUid)) {
              // Add a field for status.
              record['status'] =
                  present.contains(widget.studentUid) ? 'Present' : 'Absent';
              records.add(record);
            }
          }
        });
      }
      // Sort records by timestamp descending.
      records.sort((a, b) {
        int tsA = a['timestamp'] ?? 0;
        int tsB = b['timestamp'] ?? 0;
        return tsB.compareTo(tsA);
      });
      setState(() {
        studentAttendanceRecords = records;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Attendance"),
      ),
      body: studentAttendanceRecords.isEmpty
          ? const Center(child: Text("No attendance records found."))
          : ListView.builder(
              itemCount: studentAttendanceRecords.length,
              itemBuilder: (context, index) {
                final record = studentAttendanceRecords[index];
                String date = record['date'] ?? "Unknown Date";
                int timestamp = record['timestamp'] ?? 0;
                DateTime recordTime =
                    DateTime.fromMillisecondsSinceEpoch(timestamp);
                String formattedTime =
                    DateFormat('yyyy-MM-dd – kk:mm').format(recordTime);
                String teacher = record['teacher'] ?? "Unknown";
                String status = record['status'] ?? "Unknown";
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text("Date: $date"),
                    subtitle: Text(
                        "Teacher: $teacher\nTime: $formattedTime\nStatus: $status"),
                  ),
                );
              },
            ),
    );
  }
}
