import 'package:campus360/screens/attendance/admin_attendance_grouped_page.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'department_classroom_list_page.dart';
import 'department_energy_report_page.dart';

class HODDashboard extends StatelessWidget {
  final String department; // e.g., "IT"
  HODDashboard({Key? key, required this.department}) : super(key: key);
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HOD Dashboard - $department Dept"),
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
            // Attendance Section
            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment_turned_in),
                title: const Text("View Attendance"),
                subtitle:
                    const Text("See attendance records for your department"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminAttendanceGroupedPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Device Control Section
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_remote),
                title: const Text("Control Devices"),
                subtitle: const Text("Manage devices in your department"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DepartmentClassroomListPage(department: department),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Energy Consumption Section
            Card(
              child: ListTile(
                leading: const Icon(Icons.bolt),
                title: const Text("View Energy Consumption"),
                subtitle: const Text("Check current month's consumption"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DepartmentEnergyReportPage(department: department),
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
