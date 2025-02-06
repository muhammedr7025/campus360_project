// lib/screens/debug/debug_creation_page.dart
import 'package:flutter/material.dart';
import '../../sample_data.dart';

class DebugCreationPage extends StatelessWidget {
  const DebugCreationPage({Key? key}) : super(key: key);

  Future<void> _createClassrooms(BuildContext context) async {
    await createSampleClassroomsForDepartments();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample classrooms created')),
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
              onPressed: () => _createClassrooms(context),
              child: const Text('Create Classrooms for Departments'),
            ),
            // Other debug buttons…
          ],
        ),
      ),
    );
  }
}
