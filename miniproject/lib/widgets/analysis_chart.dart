import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisChart extends StatelessWidget {
  final List<dynamic> devices;

  const AnalysisChart({
    super.key,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const Center(
        child: Text("No data available"),
      );
    }

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            axisNameWidget: Text(
              "Daily kWh",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "Devices",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF66BB6A),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
