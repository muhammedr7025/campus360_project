// lib/screens/dashboard/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'admin_dashboard.dart';

// Role-specific dashboard widgets

class SecurityDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Security Dashboard\nControl All Devices"));
  }
}

class HODDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("HOD Dashboard\nAttendance & Energy Data"));
  }
}

class ClassDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text("Class Dashboard\nControl & Attendance for Your Class"));
  }
}

class StudentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Student Dashboard\nView Your Attendance"));
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String role = "Student"; // default role

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  // Fetch user role from Firebase Realtime Database
  Future<void> _fetchUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref("users/${user.uid}");
      final snapshot = await userRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        setState(() {
          role = data['role'] ?? 'Student';
          print(role);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget dashboardWidget;

    // Choose dashboard based on user role
    switch (role) {
      case 'Admin':
        dashboardWidget = AdminDashboard();
        break;
      case 'Security':
        dashboardWidget = SecurityDashboard();
        break;
      case 'HOD':
        dashboardWidget = HODDashboard();
        break;
      case 'Staff Advisor':
      case 'Student Rep':
        dashboardWidget = ClassDashboard();
        break;
      default:
        dashboardWidget = StudentDashboard();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard - $role"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: dashboardWidget,
    );
  }
}
