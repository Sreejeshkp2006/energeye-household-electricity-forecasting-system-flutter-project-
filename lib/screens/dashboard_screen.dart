import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/device_model.dart';
import 'add_device_form.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<DeviceModel> devices = [];

  // ===== EXISTING CALCULATIONS (UNCHANGED) =====
  double get totalDailyCost => devices.fold(0, (sum, d) => sum + d.dailyCost);

  double get totalDailyUnit => devices.fold(0, (sum, d) => sum + d.dailyUnit);

  double get predictedMonthlyBill => totalDailyCost * 30;

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  // ===== FIRESTORE LOAD (UNCHANGED LOGIC) =====
  Future<void> fetchDevices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .get();

    final loadedDevices = snapshot.docs
        .map((doc) => DeviceModel.fromFirestore(doc.id, doc.data()))
        .toList();

    setState(() {
      devices
        ..clear()
        ..addAll(loadedDevices);
    });
  }

  // ===== DELETE FUNCTION (ADDED, SAFE) =====
  Future<void> deleteDevice(DeviceModel device) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(device.id)
        .delete();

    setState(() {
      devices.removeWhere((d) => d.id == device.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Energy Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddDeviceForm(
                onAdd: (device) {
                  setState(() => devices.add(device));
                },
              ),
            ),
          );
        },
      ),
      body: devices.isEmpty
          ? const Center(child: Text("No devices added"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== SUMMARY CARDS =====
                  Row(
                    children: [
                      _summaryCard(
                        title: "Daily kWh Used",
                        value: "${totalDailyUnit.toStringAsFixed(2)} kWh",
                        icon: Icons.flash_on,
                      ),
                      const SizedBox(width: 10),
                      _summaryCard(
                        title: "Daily Cost",
                        value: "₹${totalDailyCost.toStringAsFixed(2)}",
                        icon: Icons.currency_rupee,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ===== MONTHLY PREDICTION =====
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.trending_up),
                      title: const Text("Predicted Monthly Bill"),
                      subtitle: const Text("ML ready"),
                      trailing: Text(
                        "₹${predictedMonthlyBill.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== DEVICE LIST =====
                  const Text(
                    "Today's Device Usage",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  ...devices.map(
                    (d) => Card(
                      child: ListTile(
                        title: Text(d.name),
                        subtitle: Text(
                          "${d.dailyUnit.toStringAsFixed(2)} kWh/day",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "₹${d.dailyCost.toStringAsFixed(2)}",
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete Device"),
                                    content: const Text(
                                        "Are you sure you want to delete this device?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          deleteDevice(d);
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== TIPS & ALERTS =====
                  const Text(
                    "Tips & Alerts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (totalDailyUnit > 5)
                    _alertTile(
                      icon: Icons.warning,
                      color: Colors.red,
                      text: "High energy usage detected. Try reducing usage.",
                    ),

                  _alertTile(
                    icon: Icons.lightbulb,
                    color: Colors.green,
                    text: "Use energy-efficient appliances to reduce cost.",
                  ),
                ],
              ),
            ),
    );
  }

  // ===== UI HELPERS =====
  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(title),
              const SizedBox(height: 4),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _alertTile({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(text),
      ),
    );
  }
}
