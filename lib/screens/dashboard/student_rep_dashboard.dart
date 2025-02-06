import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../attendance/attendance_page.dart';
import '../device_control/device_control_page.dart';
import '../../screens/energy_report/energy_report_page.dart';

class StudentRepDashboard extends StatelessWidget {
  final String allocatedBatch;
  final String allocatedDepartment;
  final String allocatedClassroomId;

  StudentRepDashboard({
    Key? key,
    required this.allocatedBatch,
    required this.allocatedDepartment,
    required this.allocatedClassroomId,
  }) : super(key: key);
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Rep Dashboard"),
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
            // Attendance Section
            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment_turned_in),
                title: const Text("View Attendance"),
                subtitle: const Text("See attendance records for your class"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendancePage(
                        batch: allocatedBatch,
                        department: allocatedDepartment,
                        classroomId: allocatedClassroomId,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Device Control Section
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_remote),
                title: const Text("Control Devices"),
                subtitle: const Text("Manage devices in your class"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceControlPage(
                        batch: allocatedBatch,
                        department: allocatedDepartment,
                        classroomId: allocatedClassroomId,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Energy Consumption Section
            Card(
              child: ListTile(
                leading: const Icon(Icons.bolt),
                title: const Text("View Energy Consumption"),
                subtitle: const Text("Check energy usage for your class"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnergyReportPage(
                        batch: allocatedBatch,
                        department: allocatedDepartment,
                        classroomId: allocatedClassroomId,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
