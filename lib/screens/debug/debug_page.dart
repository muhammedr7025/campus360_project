// lib/screens/debug/debug_creation_page.dart
import 'package:flutter/material.dart';
import '../../sample_data.dart'; // Ensure this imports the seed functions

class DebugCreationPage extends StatelessWidget {
  const DebugCreationPage({Key? key}) : super(key: key);

  Future<void> _seedEnergyConsumption(BuildContext context) async {
    await seedEnergyConsumptionForFebruary2025();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Energy consumption logs seeded for February 2025')),
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
              onPressed: () => _seedEnergyConsumption(context),
              child: const Text('Seed Energy Consumption (Feb 2025)'),
            ),
            // Other debug buttons...
          ],
        ),
      ),
    );
  }
}
