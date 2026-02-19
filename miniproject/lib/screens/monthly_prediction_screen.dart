import 'package:flutter/material.dart';
import '../services/ml_service.dart';

class MonthlyPredictionScreen extends StatefulWidget {
  final double totalDailyUnits;
  final int month;
  final double unitRate;

  const MonthlyPredictionScreen({
    super.key,
    required this.totalDailyUnits,
    required this.month,
    required this.unitRate,
  });

  @override
  State<MonthlyPredictionScreen> createState() =>
      _MonthlyPredictionScreenState();
}

class _MonthlyPredictionScreenState extends State<MonthlyPredictionScreen> {
  double? predictedBill;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _predictBill();
  }

  Future<void> _predictBill() async {
    try {
      final result = await MLService.predictBill(
        totalDailyUnits: widget.totalDailyUnits,
        month: widget.month,
        unitRate: widget.unitRate,
      );

      if (!mounted) return;

      setState(() {
        predictedBill = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Prediction (ML)"),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : error != null
                ? Text("Error: $error")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Predicted Monthly Bill",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "₹${predictedBill!.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Prediction powered by ML"),
                    ],
                  ),
      ),
    );
  }
}
