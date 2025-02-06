// lib/screens/debug/debug_creation_page.dart
import 'package:flutter/material.dart';
import '../../sample_data.dart';

class DebugCreationPage extends StatelessWidget {
  const DebugCreationPage({Key? key}) : super(key: key);

  Future<void> _seedAttendance(BuildContext context) async {
    await seedAttendanceDataForIT2021();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Attendance records seeded for 2021 IT batch')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Creation Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _seedAttendance(context),
              child: const Text('Seed Attendance for 2021 IT'),
            ),
            // Other debug buttons...
          ],
        ),
      ),
    );
  }
}
