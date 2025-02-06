// lib/sample_data.dart
import 'services/database_service.dart';

final DatabaseService _dbService = DatabaseService();

/// Creates a sample structure where for each department in [departments],
/// two batches (from [batches]) are created, and in each batch one classroom is added.
/// Adjust the lists as needed.
Future<void> createSampleClassroomsForDepartments() async {
  // Define the departments you need (e.g., IT, CS, MECH, EC, EEE).
  final List<String> departments = ['IT', 'CS', 'MECH', 'EC', 'EEE'];

  // Define the two batches to be created for each department.
  final List<String> batches = ['2021', '2022'];

  // Define a constant classroom id for simplicity.
  final String classroomId = 'classroom101';

  // Define the classroom data structure.
  final Map<String, dynamic> classroomData = {
    'devices': {
      'light': false,
      'fan': false,
      'autoMode': false,
      'sensors': {
        'motion': false,
        'temperature': 0,
        'moisture': 0,
        'light': 0,
      }
    },
    'attendance': {}
  };

  // Iterate over each department and batch, creating one classroom per combination.
  for (final dept in departments) {
    for (final batch in batches) {
      try {
        await _dbService.addClassroom(batch, dept, classroomId, classroomData);
        print(
            'Created classroom $classroomId for batch $batch in department $dept');
      } catch (e) {
        print(
            'Error creating classroom for batch $batch in department $dept: $e');
      }
    }
  }
}
