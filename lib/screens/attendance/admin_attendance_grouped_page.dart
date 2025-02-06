import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'attendance_detail_page.dart';

class AdminAttendanceGroupedPage extends StatefulWidget {
  const AdminAttendanceGroupedPage({Key? key}) : super(key: key);

  @override
  _AdminAttendanceGroupedPageState createState() =>
      _AdminAttendanceGroupedPageState();
}

class _AdminAttendanceGroupedPageState
    extends State<AdminAttendanceGroupedPage> {
  final DatabaseReference _classroomsRef =
      FirebaseDatabase.instance.ref().child('classrooms');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Records Grouped by Classroom"),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _classroomsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
            if (data == null) {
              return const Center(child: Text("No attendance records found."));
            }
            List<Widget> classroomGroups = [];

            // Iterate over each batch.
            data.forEach((batchKey, departments) {
              if (departments is Map) {
                // Iterate through each department.
                departments.forEach((deptKey, classrooms) {
                  if (classrooms is Map) {
                    // Iterate through each classroom.
                    classrooms.forEach((classroomKey, classroomData) {
                      if (classroomData is Map &&
                          classroomData.containsKey('attendance')) {
                        Map attendanceRecords = classroomData['attendance'];
                        if (attendanceRecords.isNotEmpty) {
                          List<Widget> attendanceTiles = [];
                          // For each attendance record in this classroom.
                          attendanceRecords.forEach((recordKey, recordData) {
                            String teacher = recordData['teacher'] ?? "Unknown";
                            int timestamp = recordData['timestamp'] ?? 0;
                            DateTime recordTime =
                                DateTime.fromMillisecondsSinceEpoch(timestamp);
                            String formattedTime =
                                DateFormat('yyyy-MM-dd – kk:mm')
                                    .format(recordTime);

                            attendanceTiles.add(
                              ListTile(
                                title: Text("Record: $recordKey"),
                                subtitle: Text(
                                    "Teacher: $teacher\nTime: $formattedTime"),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
                                  // Pass along batch, department, and classroomId.
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AttendanceDetailPage(
                                        attendanceRecord: recordData,
                                        batch: batchKey.toString(),
                                        department: deptKey.toString(),
                                        classroomId: classroomKey.toString(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          });
                          classroomGroups.add(
                            ExpansionTile(
                              title: Text(
                                  "Batch: $batchKey | Dept: $deptKey | Classroom: $classroomKey"),
                              children: attendanceTiles,
                            ),
                          );
                        }
                      }
                    });
                  }
                });
              }
            });

            if (classroomGroups.isEmpty) {
              return const Center(child: Text("No attendance records found."));
            }
            return ListView(children: classroomGroups);
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
