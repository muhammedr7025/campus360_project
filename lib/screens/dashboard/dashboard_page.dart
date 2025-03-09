import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// Import the dashboards for different roles.
import 'admin_dashboard.dart';
import 'security_dashboard.dart';
import 'hod_dashboard.dart';
import 'staff_advisor_dashboard.dart';
import 'student_rep_dashboard.dart';
import '../student/student_dashboard.dart'; // Student module

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String role = 'Student'; // default role if not found
  // For all roles, we fetch these details.
  String allocatedBatch = '';
  String allocatedDepartment = '';
  String allocatedClassroomId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch the user's profile (including role and allocated class details).
  Future<void> _fetchUserProfile() async {
    if (user != null) {
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child("users").child(user!.uid);
      DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map?;
        if (data != null) {
          setState(() {
            role = data['role'] ?? 'Student';
            // For all roles, try to fetch the allocated details.
            allocatedBatch = data['batch'] ?? '';
            allocatedDepartment = data['department'] ?? '';
            allocatedClassroomId = data['classroomId'] ?? 'classroom101';
          });
        }
      }
    }
  }

  Widget _buildDashboardForRole() {
    switch (role) {
      case 'Admin':
        return AdminDashboard();
      case 'Security':
        return SecurityDashboard();
      case 'HOD':
        return HODDashboard(department: allocatedDepartment);
      case 'Staff Advisor':
        return StaffAdvisorDashboard(
          allocatedBatch: allocatedBatch,
          allocatedDepartment: allocatedDepartment,
          allocatedClassroomId: allocatedClassroomId,
        );
      case 'Student Rep':
        return StudentRepDashboard(
          allocatedBatch: allocatedBatch,
          allocatedDepartment: allocatedDepartment,
          allocatedClassroomId: allocatedClassroomId,
        );
      case 'Student':
      default:
        return StudentDashboard(
          allocatedBatch:
              allocatedBatch.isNotEmpty ? allocatedBatch : 'Unknown',
          allocatedDepartment:
              allocatedDepartment.isNotEmpty ? allocatedDepartment : 'Unknown',
          allocatedClassroomId: allocatedClassroomId.isNotEmpty
              ? allocatedClassroomId
              : 'Unknown',
          studentUid: user?.uid ?? '',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildDashboardForRole(),
    );
  }
}
