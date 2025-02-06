import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'helper.dart'; // Ensure this file exists as shown below.

class AttendanceDetailPage extends StatelessWidget {
  final Map attendanceRecord;
  final String batch;
  final String department;
  final String classroomId;

  const AttendanceDetailPage({
    Key? key,
    required this.attendanceRecord,
    required this.batch,
    required this.department,
    required this.classroomId,
  }) : super(key: key);

  Future<String> _getUserName(String uid) async {
    return await getUserName(uid);
  }

  @override
  Widget build(BuildContext context) {
    // Extract attendance details.
    String teacher = attendanceRecord['teacher'] ?? "Unknown";
    String date = attendanceRecord['date'] ?? "Unknown Date";
    int timestamp = attendanceRecord['timestamp'] ?? 0;
    DateTime recordTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedTime = DateFormat('yyyy-MM-dd – kk:mm').format(recordTime);

    List<dynamic> presentList = attendanceRecord['present'] ?? [];
    List<dynamic> absentList = attendanceRecord['absent'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Details - $classroomId"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class details
            Text("Batch: $batch", style: const TextStyle(fontSize: 16)),
            Text("Department: $department",
                style: const TextStyle(fontSize: 16)),
            Text("Classroom: $classroomId",
                style: const TextStyle(fontSize: 16)),
            const Divider(height: 20),
            // Attendance summary
            Text("Date: $date",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Teacher: $teacher", style: const TextStyle(fontSize: 16)),
            Text("Time: $formattedTime", style: const TextStyle(fontSize: 16)),
            const Divider(height: 20),
            // Present students list
            const Text("Present Students:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            presentList.isEmpty
                ? const Text("No present records.")
                : Column(
                    children: presentList.map((uid) {
                      return FutureBuilder<String>(
                        future: _getUserName(uid.toString()),
                        builder: (context, snapshot) {
                          String displayName = (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData)
                              ? snapshot.data!
                              : uid.toString();
                          return ListTile(
                            leading: const Icon(Icons.check_circle,
                                color: Colors.green),
                            title: Text(displayName),
                          );
                        },
                      );
                    }).toList(),
                  ),
            const Divider(height: 20),
            // Absent students list
            const Text("Absent Students:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            absentList.isEmpty
                ? const Text("No absent records.")
                : Column(
                    children: absentList.map((uid) {
                      return FutureBuilder<String>(
                        future: _getUserName(uid.toString()),
                        builder: (context, snapshot) {
                          String displayName = (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData)
                              ? snapshot.data!
                              : uid.toString();
                          return ListTile(
                            leading:
                                const Icon(Icons.cancel, color: Colors.red),
                            title: Text(displayName),
                          );
                        },
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
