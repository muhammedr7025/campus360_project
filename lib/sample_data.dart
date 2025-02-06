// lib/sample_data.dart
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'services/database_service.dart';

final DatabaseService _dbService = DatabaseService();

/// Seeds energy consumption data for February 2025.
/// For each department in [departments] and for each batch in [batches],
/// it creates energy logs for the classroom 'classroom101' for every day in February 2025.
Future<void> seedEnergyConsumptionForFebruary2025() async {
  // Define the departments and batches.
  final List<String> departments = ['IT', 'CS', 'MECH', 'EC', 'EEE'];
  final List<String> batches = ['2021', '2022'];
  const String classroomId = 'classroom101';

  final Random random = Random();

  // Loop over each batch and department.
  for (final batch in batches) {
    for (final dept in departments) {
      // Build the reference to the energyLogs node for this classroom.
      DatabaseReference energyRef = FirebaseDatabase.instance
          .ref()
          .child('energyLogs')
          .child(batch)
          .child(dept)
          .child(classroomId);

      // Loop through each day in February 2025.
      for (int day = 1; day <= 28; day++) {
        // Create a log at noon for each day.
        DateTime logTime = DateTime(2025, 2, day, 12, 0, 0);
        int timestamp = logTime.millisecondsSinceEpoch;
        // Generate a random energy consumption value between 10 and 20 kWh.
        double energy = 10 + random.nextDouble() * 10;

        Map<String, dynamic> energyData = {
          'timestamp': timestamp,
          'energy': energy,
        };

        // Push this energy log to the RTDB.
        await energyRef.push().set(energyData);
      }
      print(
          'Seeded energy logs for Batch: $batch, Department: $dept, Classroom: $classroomId');
    }
  }
}
