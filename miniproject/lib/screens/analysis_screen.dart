import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/device_model.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not Logged In")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Usage Analysis"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('devices')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final devices = snapshot.data!.docs
              .map((doc) => DeviceModel.fromFirestore(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  ))
              .toList();

          if (devices.isEmpty) {
            return const Center(
              child: Text("No data available"),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "X-Axis: Devices",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Y-Axis: Daily Energy Usage (kWh)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < devices.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    devices[value.toInt()].name,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text("");
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        devices.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: devices[index].dailyUnit,
                              width: 18,
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
