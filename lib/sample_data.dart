// lib/sample_data.dart
import 'package:firebase_database/firebase_database.dart';

Future<void> seedAttendanceDataForIT2021() async {
  // Build a reference to the attendance node for classroom101 in the 2021 IT batch.
  DatabaseReference attendanceRef = FirebaseDatabase.instance
      .ref()
      .child('classrooms')
      .child('2022')
      .child('IT')
      .child('classroom101')
      .child('attendance');

  // Define two sample attendance records for the same day.
  // Record 1: Taken by Ms. Smith at 8:00 AM on 2021-10-10.
  DateTime record1Time = DateTime.parse("2025-02-06 08:00:00");
  Map<String, dynamic> attendanceRecord1 = {
    "date": "2021-10-10",
    "teacher": "Ms. Smith",
    "timestamp": record1Time.millisecondsSinceEpoch,
    "present": [
      "AOLwqtBtd1OtjdyToMMaULiJWR82",
      "17gcvAb1WSOe4OpCQLxT0uutPy23"
    ], // Sample UIDs for present students.
    "absent": [
      "s9Qt1cEeFcdmJSq8Udp2d8c1Nzi2"
    ] // Sample UIDs for absent students.
  };

  // Record 2: Taken by Mr. Jones at 1:00 PM on 2021-10-10.
  DateTime record2Time = DateTime.parse("2025-02-06 13:00:00");
  Map<String, dynamic> attendanceRecord2 = {
    "date": "2021-10-10",
    "teacher": "Mr. Jones",
    "timestamp": record2Time.millisecondsSinceEpoch,
    "present": ["17gcvAb1WSOe4OpCQLxT0uutPy23"], // Different sample UIDs.
    "absent": ["AOLwqtBtd1OtjdyToMMaULiJWR82", "s9Qt1cEeFcdmJSq8Udp2d8c1Nzi2"]
  };

  try {
    // Save the attendance records under distinct keys.
    await attendanceRef.child("record1").set(attendanceRecord1);
    await attendanceRef.child("record2").set(attendanceRecord2);
    print('Attendance records seeded for 2021 IT classroom101 on 2021-10-10.');
  } catch (e) {
    print('Error seeding attendance records: $e');
  }
}
