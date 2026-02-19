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
import 'meter_reading_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedMonth = DateTime.now().month;

  final List<String> _monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

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
          .where('month', isEqualTo: _selectedMonth)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),

          /// APP BAR
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

          /// BODY
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// MONTH SELECTOR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedMonth,
                      isExpanded: true,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      items: List.generate(12, (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(
                            "Viewing Usage: ${_monthNames[index]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      }),
                      onChanged: (val) {
                        setState(() {
                          _selectedMonth = val!;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                /// SUMMARY CARDS
                Row(
                  children: [
                    Stack(
                      children: [
                        SummaryCard(
                          title: "Daily kWh",
                          value: "${totalDailyUnit.toStringAsFixed(2)} kWh",
                          icon: Icons.flash_on,
                          color: Colors.orange,
                        ),
                        if (totalDailyUnit * 30 > 300)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Icon(Icons.warning, color: Colors.red[700], size: 20),
                          ),
                      ],
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

                const SizedBox(height: 30),

                Text(
                  devices.isEmpty 
                    ? "No devices for ${_monthNames[_selectedMonth - 1]}"
                    : "Usage Breakdown for ${_monthNames[_selectedMonth - 1]}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                if (devices.isEmpty)
                   Center(
                     child: Padding(
                       padding: const EdgeInsets.only(top: 40),
                       child: Column(
                         children: [
                           Icon(Icons.device_hub, size: 60, color: Colors.grey[300]),
                           const SizedBox(height: 10),
                           Text("Click [+] to add devices for this month", style: TextStyle(color: Colors.grey[600])),
                         ],
                       ),
                     ),
                   )
                else
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
                const SizedBox(height: 15),
                /// CALCULATOR BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MeterReadingScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bolt),
                    label: const Text("Calculate Bill & Usage Details"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2C5364),
                      side: const BorderSide(color: Color(0xFF2C5364)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
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
                if (devices.isNotEmpty) {
                  final totalDailyUnits =
                      devices.fold(0.0, (total, d) => total + d.dailyUnit);

                  final double unitRate = devices.first.rate;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MonthlyPredictionScreen(
                        totalDailyUnits: totalDailyUnits,
                        month: _selectedMonth,
                        unitRate: unitRate,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Add devices for ${_monthNames[_selectedMonth - 1]} first")),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}

