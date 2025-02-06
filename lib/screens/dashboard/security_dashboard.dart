import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/auth_service.dart';
import '../device_control/device_control_page.dart';

class SecurityDashboard extends StatefulWidget {
  SecurityDashboard({Key? key}) : super(key: key);

  @override
  _SecurityDashboardState createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  final DatabaseReference _classroomsRef =
      FirebaseDatabase.instance.ref().child('classrooms');
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _classroomsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Retrieve the entire classrooms node.
            final data =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
            if (data == null) {
              return const Center(child: Text("No classrooms found"));
            }
            // Flatten the nested structure into a list.
            List<Map<String, String>> classroomList = [];
            data.forEach((batchKey, departments) {
              if (departments is Map) {
                departments.forEach((deptKey, classes) {
                  if (classes is Map) {
                    classes.forEach((classKey, _) {
                      classroomList.add({
                        'batch': batchKey.toString(),
                        'department': deptKey.toString(),
                        'classroomId': classKey.toString(),
                      });
                    });
                  }
                });
              }
            });

            return ListView.builder(
              itemCount: classroomList.length,
              itemBuilder: (context, index) {
                final classroom = classroomList[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.class_),
                    title: Text(
                        "Batch: ${classroom['batch']} | Dept: ${classroom['department']}"),
                    subtitle: Text("Classroom: ${classroom['classroomId']}"),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Navigate to the Device Control page for the selected classroom.
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
