// lib/screens/dashboard/department_classroom_list_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../device_control/device_control_page.dart';

class DepartmentClassroomListPage extends StatefulWidget {
  final String department;
  const DepartmentClassroomListPage({Key? key, required this.department})
      : super(key: key);

  @override
  _DepartmentClassroomListPageState createState() =>
      _DepartmentClassroomListPageState();
}

class _DepartmentClassroomListPageState
    extends State<DepartmentClassroomListPage> {
  final DatabaseReference _classroomsRef =
      FirebaseDatabase.instance.ref().child('classrooms');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Classrooms in ${widget.department} Dept"),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _classroomsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
            if (data == null) {
              print("No classrooms data found in RTDB.");
              return const Center(child: Text("No classrooms found"));
            }
            // Debug: Print raw data to console.
            print("Fetched classrooms data: $data");

            // Normalize the department provided in widget for comparison.
            String widgetDeptNormalized =
                widget.department.trim().toLowerCase();

            // Flatten the nested structure into a list.
            List<Map<String, String>> classroomList = [];
            data.forEach((batchKey, departments) {
              if (departments is Map) {
                // Iterate through all departments in the current batch.
                departments.forEach((deptKey, classes) {
                  // Normalize the department key from RTDB.
                  String deptKeyNormalized =
                      deptKey.toString().trim().toLowerCase();
                  if (deptKeyNormalized == widgetDeptNormalized) {
                    if (classes is Map) {
                      classes.forEach((classKey, _) {
                        classroomList.add({
                          'batch': batchKey.toString(),
                          'department': deptKey.toString(),
                          'classroomId': classKey.toString(),
                        });
                      });
                    }
                  }
                });
              }
            });

            // Debug: Print the filtered classroom list.
            print("Classroom list for ${widget.department}: $classroomList");

            if (classroomList.isEmpty) {
              return const Center(
                  child: Text("No classrooms found for this department."));
            }

            return ListView.builder(
              itemCount: classroomList.length,
              itemBuilder: (context, index) {
                final classroom = classroomList[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.class_),
                    title: Text("Batch: ${classroom['batch']}"),
                    subtitle: Text("Classroom: ${classroom['classroomId']}"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceControlPage(
                            batch: classroom['batch']!,
                            department: classroom['department']!,
                            classroomId: classroom['classroomId']!,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
