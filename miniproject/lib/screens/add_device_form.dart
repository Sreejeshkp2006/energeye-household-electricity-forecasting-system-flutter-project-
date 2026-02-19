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

  final nameController = TextEditingController();
  final wattController = TextEditingController();
  final hoursController = TextEditingController();
  final rateController = TextEditingController();
  final quantityController = TextEditingController();

  int selectedMonth = DateTime.now().month; // 🔥 NEW

  final List<String> monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Device")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// DEVICE NAME
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Device Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter device name" : null,
                ),

                const SizedBox(height: 15),

                /// WATT
                TextFormField(
                  controller: wattController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Power (Watt)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter watt value" : null,
                ),

                const SizedBox(height: 15),

                /// HOURS
                TextFormField(
                  controller: hoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Hours per Day",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter hours" : null,
                ),

                const SizedBox(height: 15),

                /// ELECTRICITY RATE
                TextFormField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Electricity Rate (₹/kWh)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter electricity rate" : null,
                ),

                const SizedBox(height: 15),

                /// MONTH DROPDOWN 🔥
                DropdownButtonFormField<int>(
                  value: selectedMonth,
                  decoration: const InputDecoration(
                    labelText: "Select Month",
                    border: OutlineInputBorder(),
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

                /// QUANTITY
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Quantity (Number of Devices)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter quantity" : null,
                ),

                const SizedBox(height: 25),

                /// SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final double watt = double.parse(wattController.text);

                        final double hours = double.parse(hoursController.text);

                        final double rate = double.parse(rateController.text);

                        final int quantity = int.parse(quantityController.text);

                        // 🔥 EXISTING CALCULATION (UNCHANGED)
                        final double dailyUnit =
                            ((watt * hours) / 1000) * quantity;

                        final double dailyCost = dailyUnit * rate;

                        final user = FirebaseAuth.instance.currentUser;

                        if (user == null) return;

                        final docRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
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
                          month: selectedMonth, // 🔥 NEW FIELD
                        );

                        await docRef.set(device.toMap());

                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Save Device"),
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
