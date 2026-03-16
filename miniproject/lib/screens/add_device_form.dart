import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/device_model.dart';

class AddDeviceForm extends StatefulWidget {
  const AddDeviceForm({super.key});

  @override
  State<AddDeviceForm> createState() => _AddDeviceFormState();
}

class _AddDeviceFormState extends State<AddDeviceForm> {
  final _formKey = GlobalKey<FormState>();
  String? _resolvedUserId;
  bool _isLoadingId = true;

  final nameController = TextEditingController();
  final wattController = TextEditingController();
  final hoursController = TextEditingController();
  final rateController = TextEditingController();
  final quantityController = TextEditingController();

  int selectedMonth = DateTime.now().month;

  final List<String> monthNames = [
    "January", "February", "March", "April", "May", "June", 
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    _resolveId();
  }

  Future<void> _resolveId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingId = false);
      return;
    }

    // 1. Try UID
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      if (mounted) setState(() { _resolvedUserId = user.uid; _isLoadingId = false; });
      return;
    }

    // 2. Try Email Fallback
    if (user.email != null) {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _resolvedUserId = query.docs.first.id;
            _isLoadingId = false;
          });
        }
        return;
      }
    }

    if (mounted) setState(() => _isLoadingId = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingId) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Device"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Device Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.devices),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter device name" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: wattController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Power (Watt)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bolt),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter watt value" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Hours per Day",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter hours" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Electricity Rate (₹/kWh)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter electricity rate" : null,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<int>(
                  initialValue: selectedMonth,
                  decoration: const InputDecoration(
                    labelText: "Select Month",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  items: List.generate(12, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(monthNames[index]),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                    });
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Quantity",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter quantity" : null,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final double watt = double.parse(wattController.text);
                        final double hours = double.parse(hoursController.text);
                        final double rate = double.parse(rateController.text);
                        final int quantity = int.parse(quantityController.text);

                        final double dailyUnit = ((watt * hours) / 1000) * quantity;
                        final double dailyCost = dailyUnit * rate;

                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;
                        
                        final effectiveId = _resolvedUserId ?? user.uid;

                        final docRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(effectiveId)
                            .collection('devices')
                            .doc();

                        final device = DeviceModel(
                          id: docRef.id,
                          name: nameController.text,
                          watt: watt,
                          hours: hours,
                          rate: rate,
                          quantity: quantity,
                          dailyUnit: dailyUnit,
                          dailyCost: dailyCost,
                          month: selectedMonth,
                        );

                        await docRef.set(device.toMap());
                        if (!mounted) return;
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Save Device", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
