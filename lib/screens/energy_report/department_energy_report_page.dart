import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class DepartmentEnergyReportPage extends StatefulWidget {
  final String department;
  final String firstYear; // e.g., "2021" for 1st year
  final String secondYear; // e.g., "2022" for 2nd year
  final String thirdYear; // e.g., "2023" for 3rd year
  final String fourthYear; // e.g., "2024" for 4th year

  const DepartmentEnergyReportPage({
    Key? key,
    required this.department,
    required this.firstYear,
    required this.secondYear,
    required this.thirdYear,
    required this.fourthYear,
  }) : super(key: key);

  @override
  _DepartmentEnergyReportPageState createState() =>
      _DepartmentEnergyReportPageState();
}

class _DepartmentEnergyReportPageState
    extends State<DepartmentEnergyReportPage> {
  // Energy usage values for current month
  double usageFirst = 0.0;
  double usageSecond = 0.0;
  double usageThird = 0.0;
  double usageFourth = 0.0;
  // Energy usage for previous month (total across batches)
  double previousMonthUsage = 0.0;
  // Calculated total current usage across all batches.
  double totalCurrentUsage = 0.0;
  // Expected energy price rate (e.g., $0.10 per kWh)
  final double priceRate = 0.10;
  double expectedPrice = 0.0;
  // Comparison text: "Higher" or "Lower"
  String comparisonText = "N/A";
  // Highest usage class name (e.g., "1st year")
  String highestUsageClass = "";
  // Loading flag
  bool loading = true;
  String reportMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchEnergyData();
  }

  /// Get the total energy usage for a given batch (year) and department
  /// for a specified time range.
  Future<double> _getUsageForBatch({
    required String batch,
    required String department,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    double sum = 0.0;
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('energyLogs')
        .child(batch)
        .child(department);
    // Get all classrooms under the department.
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      Map data = snapshot.value as Map;
      int startMillis = startTime.millisecondsSinceEpoch;
      int endMillis = endTime.millisecondsSinceEpoch;
      // Iterate over each classroom.
      data.forEach((classroomId, logs) {
        if (logs is Map) {
          logs.forEach((logKey, logData) {
            if (logData is Map) {
              int timestamp = logData['timestamp'] ?? 0;
              if (timestamp >= startMillis && timestamp < endMillis) {
                double energy = (logData['energy'] != null
                    ? (logData['energy'] as num).toDouble()
                    : 0.0);
                sum += energy;
              }
            }
          });
        }
      });
    }
    return sum;
  }

  Future<void> _fetchEnergyData() async {
    try {
      DateTime now = DateTime.now();
      // Current month start and end.
      DateTime currentMonthStart = DateTime(now.year, now.month, 1);
      DateTime nextMonthStart = DateTime(
          now.year, now.month + 1, 1); // Automatically handles year wrap-around
      // Previous month start and end.
      DateTime previousMonthStart = DateTime(now.year, now.month - 1, 1);
      DateTime currentMonthStartFromPrev =
          DateTime(now.year, now.month, 1); // end of previous month

      // For each batch, get current month usage.
      double firstUsage = await _getUsageForBatch(
        batch: widget.firstYear,
        department: widget.department,
        startTime: currentMonthStart,
        endTime: nextMonthStart,
      );
      double secondUsage = await _getUsageForBatch(
        batch: widget.secondYear,
        department: widget.department,
        startTime: currentMonthStart,
        endTime: nextMonthStart,
      );
      double thirdUsage = await _getUsageForBatch(
        batch: widget.thirdYear,
        department: widget.department,
        startTime: currentMonthStart,
        endTime: nextMonthStart,
      );
      double fourthUsage = await _getUsageForBatch(
        batch: widget.fourthYear,
        department: widget.department,
        startTime: currentMonthStart,
        endTime: nextMonthStart,
      );

      // Total current usage
      double totalCurrent = firstUsage + secondUsage + thirdUsage + fourthUsage;

      // Previous month total usage (summing all batches)
      double prevFirst = await _getUsageForBatch(
        batch: widget.firstYear,
        department: widget.department,
        startTime: previousMonthStart,
        endTime: currentMonthStartFromPrev,
      );
      double prevSecond = await _getUsageForBatch(
        batch: widget.secondYear,
        department: widget.department,
        startTime: previousMonthStart,
        endTime: currentMonthStartFromPrev,
      );
      double prevThird = await _getUsageForBatch(
        batch: widget.thirdYear,
        department: widget.department,
        startTime: previousMonthStart,
        endTime: currentMonthStartFromPrev,
      );
      double prevFourth = await _getUsageForBatch(
        batch: widget.fourthYear,
        department: widget.department,
        startTime: previousMonthStart,
        endTime: currentMonthStartFromPrev,
      );
      double totalPrevious = prevFirst + prevSecond + prevThird + prevFourth;

      // Comparison: compare totalCurrent vs totalPrevious (if previous > 0).
      String compare = "N/A";
      if (totalPrevious > 0) {
        compare = totalCurrent > totalPrevious ? "Higher" : "Lower";
      }

      // Determine the highest energy usage among the four batches.
      Map<String, double> usageMap = {
        "1st year": firstUsage,
        "2nd year": secondUsage,
        "3rd year": thirdUsage,
        "4th year": fourthUsage,
      };
      String highestClass =
          usageMap.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

      // Expected energy price.
      double price = totalCurrent * priceRate;

      // Build the report string.
      String report =
          "----- Energy Report of ${DateFormat('MMMM yyyy').format(now)} -----\n\n";
      report += "Department: ${widget.department}\n\n";
      report +=
          "1st Year Usage (Monthly): ${firstUsage.toStringAsFixed(2)} kWh\n";
      report +=
          "2nd Year Usage (Monthly): ${secondUsage.toStringAsFixed(2)} kWh\n";
      report +=
          "3rd Year Usage (Monthly): ${thirdUsage.toStringAsFixed(2)} kWh\n";
      report +=
          "4th Year Usage (Monthly): ${fourthUsage.toStringAsFixed(2)} kWh\n\n";
      report += "Total Energy Usage: ${totalCurrent.toStringAsFixed(2)} kWh\n";
      report +=
          "Previous Month Energy Usage: ${totalPrevious.toStringAsFixed(2)} kWh\n";
      report += "Usage Compared to Previous Month: $compare\n\n";
      report += "Most Energy Used Class: $highestClass\n";
      report += "Most Energy Used Device: Fan\n";
      report += "Expected Energy Price: ${price.toStringAsFixed(2)}\n";

      setState(() {
        usageFirst = firstUsage;
        usageSecond = secondUsage;
        usageThird = thirdUsage;
        usageFourth = fourthUsage;
        totalCurrentUsage = totalCurrent;
        previousMonthUsage = totalPrevious;
        expectedPrice = price;
        comparisonText = compare;
        highestUsageClass = highestClass;
        reportMessage = report;
        loading = false;
      });
    } catch (e) {
      setState(() {
        reportMessage = "Error fetching energy data: $e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Department Energy Report"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                reportMessage,
                style: const TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}
