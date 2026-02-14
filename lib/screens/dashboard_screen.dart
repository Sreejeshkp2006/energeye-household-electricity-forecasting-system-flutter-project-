import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/device_model.dart';
import '../widgets/device_tile.dart';
import '../widgets/summary_card.dart';
import 'add_device_form.dart';
import 'analysis_screen.dart';
import 'monthly_prediction_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not Logged In")),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('devices')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final devices = snapshot.data!.docs
            .map((doc) => DeviceModel.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
            .toList();

        final totalDailyUnit =
            devices.fold(0.0, (total, d) => total + d.dailyUnit);

        final totalDailyCost =
            devices.fold(0.0, (total, d) => total + d.dailyCost);

        final predictedMonthly = totalDailyCost * 30;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),

          appBar: AppBar(
            title: const Text("Energy Dashboard"),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          body: devices.isEmpty
              ? const Center(
                  child: Text("No devices added"),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// SUMMARY CARDS
                      Row(
                        children: [
                          SummaryCard(
                            title: "Daily kWh",
                            value: "${totalDailyUnit.toStringAsFixed(2)} kWh",
                            icon: Icons.flash_on,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 14),
                          SummaryCard(
                            title: "Daily Cost",
                            value: "₹${totalDailyCost.toStringAsFixed(2)}",
                            icon: Icons.currency_rupee,
                            color: Colors.blue,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// MONTHLY PREDICTION CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2E7D32),
                              Color(0xFF66BB6A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Predicted Monthly Bill",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "₹${predictedMonthly.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Today's Device Usage",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 12),

                      ...devices.map(
                        (d) => DeviceTile(
                          device: d,
                          onDelete: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('devices')
                                .doc(d.id)
                                .delete();
                          },
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// ANALYSIS BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AnalysisScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.analytics),
                          label: const Text("View Usage Analysis"),
                        ),
                      ),
                    ],
                  ),
                ),

          /// BOTTOM NAVIGATION
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: "Analysis",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: "Add Device",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: "Monthly",
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnalysisScreen(),
                  ),
                );
              }

              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddDeviceForm(),
                  ),
                );
              }

              if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MonthlyPredictionScreen(
                      dailyCost: totalDailyCost,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
