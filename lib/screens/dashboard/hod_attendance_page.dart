import 'package:flutter/material.dart';

class HODAttendancePage extends StatelessWidget {
  final String department;
  const HODAttendancePage({Key? key, required this.department})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Here you would normally query and display attendance records for all classrooms
    // in the department. For this example, we show a placeholder.
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance - $department Dept"),
      ),
      body: Center(
        child: Text(
          "Attendance records for the $department department will appear here.",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
