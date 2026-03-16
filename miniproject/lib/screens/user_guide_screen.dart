import 'package:flutter/material.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        title: const Text(
          "App Guide & Workings",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("How EnergEYE Works"),
            _buildParagraph(
              "EnergEYE helps you monitor and forecast your household electricity consumption. By adding your appliances and their usage patterns, our system calculates daily and monthly energy units (kWh).",
            ),
            _buildParagraph(
              "1. **Add Appliances**: Enter the wattage and average daily usage hours for each device.\n"
              "2. **Real-time Tracking**: See your current consumption and estimated billing cost on the dashboard.\n"
              "3. **Smart Forecasting**: Use the Prediction tab to see future consumption based on your current habits.\n"
              "4. **Optimization**: Check the analysis charts to see which devices are consuming the most energy.",
            ),
            const SizedBox(height: 32),
            _buildSectionHeader("Typical Device Power Ratings"),
            _buildInfoNote("Note: These are typical ranges — actual wattage can vary by model/brand."),
            const SizedBox(height: 16),
            _buildDeviceTable(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: Colors.blueGrey.shade700,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildInfoNote(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.teal.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.teal.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTable() {
    final devices = [
      ["Ceiling Fan", "60–75 W"],
      ["Table/Wall Fan", "45–70 W"],
      ["LED Bulb", "7–12 W"],
      ["Tube Light", "~22 W"],
      ["LED TV (32″)", "50–100 W"],
      ["Refrigerator", "150–400 W"],
      ["Washing Machine", "400–1,200 W"],
      ["Microwave Oven", "600–1,200 W"],
      ["Electric Kettle", "1,200–2,000 W"],
      ["Water Heater (Geyser)", "1,000–3,000 W"],
      ["Induction Cooker", "1,200–2,000 W"],
      ["Mixer Grinder", "500–1,000 W"],
      ["Wet Grinder", "150–750 W"],
      ["Water Filter (RO/UV)", "15–60 W"],
      ["Set-Top Box", "25–60 W"],
      ["Speaker", "5–500 W"],
      ["Laptop", "30–90 W"],
      ["Desktop PC", "150–300 W"],
      ["Wi-Fi Router", "~10 W"],
      ["Phone Charger", "4–7 W"],
      ["EV Charging – Scooter", "500–1,500 W"],
      ["EV Charging – Car", "3,300–7,200 W"],
      ["1 Ton AC", "900–1,200 W"],
      ["1.5 Ton AC", "1,400–1,800 W"],
      ["2 Ton AC", "1,800–2,500 W"],
      ["Window AC", "1,500–2,000 W"],
      ["Room Heater", "1,000–2,000 W"],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade50),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.teal.shade50.withValues(alpha: 0.5)),
              children: const [
                Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text("Device", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                ),
                Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text("Power (W)", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                ),
              ],
            ),
            ...devices.map((device) {
              return TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.teal.shade50)),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                    child: Text(device[0], style: const TextStyle(fontSize: 14, color: Color(0xFF4A5568))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                    child: Text(device[1], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.teal.shade600)),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
