// lib/sample_data.dart
import 'package:firebase_database/firebase_database.dart';
import 'services/database_service.dart';

final DatabaseService _dbService = DatabaseService();

/// Creates a sample admin user with profile information.
Future<void> createSampleAdmin() async {
  final Map<String, dynamic> adminData = {
    'name': 'Admin User',
    'email': 'admin@gmail.com',
    'role': 'Admin',
    'batch': '2021',
    'department': 'IT',
    'profilePhotoUrl': '',
  };

  // NOTE:
  // For a real admin user, you need to use the UID provided by FirebaseAuth.
  // For debugging, we use a hard-coded UID.
  const String uid = 'gCvOWbCuXxaoD93eCM3VWKZztqm2';
  try {
    await _dbService.createOrUpdateUser(uid, adminData);
    print('Sample admin created successfully!');
  } catch (e) {
    print('Error creating sample admin: $e');
  }
}

/// Creates a sample regular user.
Future<void> createSampleUser() async {
  final Map<String, dynamic> userData = {
    'name': 'Sample Student',
    'email': 'student@college.com',
    'role': 'Student',
    'batch': '2021',
    'department': 'CS',
    'profilePhotoUrl': '',
  };

  // Generate a UID for the sample user.
  String uid = DateTime.now().millisecondsSinceEpoch.toString();
  try {
    await _dbService.createOrUpdateUser(uid, userData);
    print('Sample user created successfully!');
  } catch (e) {
    print('Error creating sample user: $e');
  }
}

/// Creates a sample classroom.
Future<void> createSampleClassroom() async {
  final Map<String, dynamic> classroomData = {
    'devices': {
      'light': false,
      'fan': false,
      'sensors': {
        'motion': false,
        'temperature': 0,
        'moisture': 0,
        'light': 0,
      },
    },
    'attendance': {},
  };

  try {
    await _dbService.addClassroom('2021', 'IT', 'classroom101', classroomData);
    print('Sample classroom created successfully!');
  } catch (e) {
    print('Error creating sample classroom: $e');
  }
}
