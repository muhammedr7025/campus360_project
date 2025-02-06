// lib/screens/dashboard/admin_dashboard.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'admin_user_management_page.dart';
import 'classroom_list_page.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({Key? key}) : super(key: key);
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
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
            // Other admin dashboard widgets and sections can be added here.
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminUserManagementPage(),
                  ),
                );
              },
              child: const Text("User Management"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ClassroomListPage()),
                );
              },
              child: const Text("View All Classrooms"),
            )

            // Add additional admin controls as needed.
          ],
        ),
      ),
    );
  }
}
