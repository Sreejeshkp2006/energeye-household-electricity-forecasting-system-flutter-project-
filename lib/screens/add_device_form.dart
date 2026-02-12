import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/device_model.dart';

class AddDeviceForm extends StatefulWidget {
  final Function(DeviceModel) onAdd;
  const AddDeviceForm({super.key, required this.onAdd});

  @override
  State<AddDeviceForm> createState() => _AddDeviceFormState();
}

class _AddDeviceFormState extends State<AddDeviceForm> {
  final nameController = TextEditingController();
  final wattController = TextEditingController();
  final hourController = TextEditingController();
  final rateController = TextEditingController(text: "7");

  Future<void> saveDevice(DeviceModel device) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .add(device.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Device")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Device Name"),
            ),
            TextField(
              controller: wattController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Watt (W)"),
            ),
            TextField(
              controller: hourController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Daily Usage (hours)"),
            ),
            TextField(
              controller: rateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Rate (₹/kWh)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("ADD DEVICE"),
              onPressed: () async {
                final watt = double.parse(wattController.text);
                final hours = double.parse(hourController.text);
                final rate = double.parse(rateController.text);

                final dailyUnit = (watt * hours) / 1000;
                final dailyCost = dailyUnit * rate;

                final device = DeviceModel(
                  id: "", // 🔹 TEMP ID (Firestore gives real one)
                  name: nameController.text.trim(),
                  watt: watt,
                  hours: hours,
                  rate: rate,
                  dailyUnit: dailyUnit,
                  dailyCost: dailyCost,
                );

                widget.onAdd(device); // existing logic
                await saveDevice(device);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
