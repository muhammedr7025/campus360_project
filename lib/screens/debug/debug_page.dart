// lib/screens/debug/debug_creation_page.dart
import 'package:flutter/material.dart';
import '../../sample_data.dart';

class DebugCreationPage extends StatelessWidget {
  const DebugCreationPage({Key? key}) : super(key: key);

  /// Calls the sample admin creation function.
  Future<void> _createAdmin(BuildContext context) async {
    await createSampleAdmin();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Sample Admin Created')));
  }

  /// Calls the sample user creation function.
  Future<void> _createUser(BuildContext context) async {
    await createSampleUser();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Sample User Created')));
  }

  /// Calls the sample classroom creation function.
  Future<void> _createClassroom(BuildContext context) async {
    await createSampleClassroom();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample Classroom Created')));
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
              onPressed: () => _createAdmin(context),
              child: const Text('Create Sample Admin'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _createUser(context),
              child: const Text('Create Sample User'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _createClassroom(context),
              child: const Text('Create Sample Classroom'),
            ),
            const SizedBox(height: 16),
            // Optionally, add a button to navigate to user management.
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/adminUserManagement');
              },
              child: const Text('Go to User Management'),
            ),
          ],
        ),
      ),
    );
  }
}
