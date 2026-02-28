import 'package:flutter/material.dart';
import 'analysis_screen.dart';
import 'meter_reading_screen.dart';
import 'add_device_form.dart';
import 'solar_calculator_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Services",
                style: TextStyle(
                  color: Color(0xFF2D3748),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "Optimize and analyze your consumption",
                style: TextStyle(
                  color: Colors.blueGrey.shade300,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              _buildServiceMainAction(
                context,
                "Usage Analysis",
                "Deep dive into your appliance data with visual charts.",
                Icons.bar_chart_rounded,
                Colors.teal.shade400,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalysisScreen()),
                ),
              ),

              const SizedBox(height: 20),

              _buildServiceMainAction(
                context,
                "Bill Calculator",
                "Manually calculate your monthly bill based on current units.",
                Icons.calculate_rounded,
                Colors.orange.shade300,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MeterReadingScreen()),
                ),
              ),

              const SizedBox(height: 20),

              _buildServiceMainAction(
                context,
                "Add New Device",
                "Track more appliances to refine your energy footprint.",
                Icons.add_circle_outline_rounded,
                Colors.indigo.shade300,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDeviceForm()),
                ),
              ),

              const SizedBox(height: 20),

              _buildServiceMainAction(
                context,
                "Solar Calculator",
                "Estimate your rooftop solar capacity and potential savings.",
                Icons.wb_sunny_outlined,
                Colors.amber.shade400,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SolarCalculatorScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceMainAction(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.teal.shade50),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withValues(alpha: 0.02),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey.shade400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.blueGrey.shade200),
          ],
        ),
      ),
    );
  }
}
