import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'student_attendance_page.dart';

class StudentDashboard extends StatelessWidget {
  final String allocatedBatch;
  final String allocatedDepartment;
  final String allocatedClassroomId;
  final String studentUid;

  StudentDashboard({
    Key? key,
    required this.allocatedBatch,
    required this.allocatedDepartment,
    required this.allocatedClassroomId,
    required this.studentUid,
  }) : super(key: key);
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display allocated class details.
            Card(
              child: ListTile(
                leading: const Icon(Icons.class_),
                title: Text("Allocated Class: $allocatedClassroomId"),
                subtitle:
                    Text("Batch: $allocatedBatch, Dept: $allocatedDepartment"),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentAttendancePage(
                      batch: allocatedBatch,
                      department: allocatedDepartment,
                      classroomId: allocatedClassroomId,
                      studentUid: studentUid,
                    ),
                  ),
                );
              },
              child: const Text("View My Attendance"),
            ),
          ],
        ),
      ),
    );
  }
}
