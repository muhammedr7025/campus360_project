// lib/services/database_service.dart
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Create or update a user profile in the "users" node.
  Future<void> createOrUpdateUser(
      String uid, Map<String, dynamic> userData) async {
    await _dbRef.child('users').child(uid).set(userData);
  }

  /// Delete a user by UID.
  Future<void> deleteUser(String uid) async {
    await _dbRef.child('users').child(uid).remove();
  }

  /// Add a classroom under a specific batch and department.
  Future<void> addClassroom(String batch, String department, String classroomId,
      Map<String, dynamic> classroomData) async {
    await _dbRef
        .child('classrooms')
        .child(batch)
        .child(department)
        .child(classroomId)
        .set(classroomData);
  }
}
