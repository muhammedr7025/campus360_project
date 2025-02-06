// lib/screens/dashboard/dashboard_page.dart
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
  DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String role = 'Student'; // default role if not found
  // Additional properties for student details.
  String allocatedBatch = '';
  String allocatedDepartment = '';
  String allocatedClassroomId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch the user's profile (including role and, if student, their allocated class details).
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
            // If the role is Student, also fetch the allocated class details.
            if (role == 'Student') {
              allocatedBatch = data['batch'] ?? '';
              allocatedDepartment = data['department'] ?? '';
              allocatedClassroomId = 'classroom101';
            }
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
        // For HOD, you might pass the department from the profile.
        return HODDashboard(department: dataOrFallback('department'));
      case 'Staff Advisor':
        return StaffAdvisorDashboard(
          allocatedBatch: dataOrFallback('batch'),
          allocatedDepartment: dataOrFallback('department'),
          allocatedClassroomId: dataOrFallback('classroomId'),
        );
      case 'Student Rep':
        return StudentRepDashboard(
          allocatedBatch: dataOrFallback('batch'),
          allocatedDepartment: dataOrFallback('department'),
          allocatedClassroomId: dataOrFallback('classroomId'),
        );
      case 'Student':
      default:
        // For a student, ensure that the allocated details are not empty.
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

  // Helper function to provide fallback data (if needed).
  String dataOrFallback(String key) {
    // In a complete implementation, you would read this from the user profile.
    // Here we assume the profile contains the fields.
    return ''; // Replace with actual data retrieval if needed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildDashboardForRole(),
    );
  }
}
