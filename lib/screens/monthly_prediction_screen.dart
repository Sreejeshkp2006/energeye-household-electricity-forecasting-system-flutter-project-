import 'package:flutter/material.dart';

class MonthlyPredictionScreen extends StatelessWidget {
  final double dailyCost;

  const MonthlyPredictionScreen({
    super.key,
    required this.dailyCost,
  });

  @override
  Widget build(BuildContext context) {
    final monthly = dailyCost * 30;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Prediction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  "₹${monthly.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Calculated as: Total Daily Cost × 30 days",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
