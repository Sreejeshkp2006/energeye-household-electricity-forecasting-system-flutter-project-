import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/device_model.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String? _resolvedUserId;
  bool _isLoadingId = true;

  int _selectedMonth = DateTime.now().month;
  int _touchedIndex = -1;
  final List<String> _monthNames = [
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not Logged In")),
      );
    }

    if (_isLoadingId) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    final effectiveId = _resolvedUserId ?? user.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text("Usage Analysis"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F2027), Color(0xFF203A43)],
            ),
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButton<int>(
              value: _selectedMonth,
              dropdownColor: const Color(0xFF203A43),
              underline: const SizedBox(),
              icon: const Icon(Icons.calendar_month, color: Colors.cyanAccent, size: 18),
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(
                    _monthNames[index],
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                );
              }),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedMonth = val;
                    _touchedIndex = -1;
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(effectiveId)
              .collection('devices')
              .where('month', isEqualTo: _selectedMonth)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
            }

            final devices = snapshot.data!.docs
                .map((doc) => DeviceModel.fromFirestore(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ))
                .toList();

            if (devices.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics_outlined, size: 100, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 20),
                    Text(
                      "No data for ${_monthNames[_selectedMonth - 1]}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Try adding appliances for this month in the Dashboard.",
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
              );
            }

            // Calculations
            double totalUsage = 0;
            DeviceModel? peakDevice;
            for (var d in devices) {
              totalUsage += d.dailyUnit;
              if (peakDevice == null || d.dailyUnit > peakDevice!.dailyUnit) {
                peakDevice = d;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          "Total Usage",
                          "${totalUsage.toStringAsFixed(2)} kWh",
                          Icons.bolt,
                          Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildSummaryCard(
                          "Peak Device",
                          peakDevice?.name ?? "N/A",
                          Icons.trending_up,
                          Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Appliance Consumption Breakdown",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Units (kWh) per day • Tap bars for details",
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 12),
                  ),
                  const SizedBox(height: 30),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Minimum width for each device bar section
                      const double barWidth = 60.0;
                      final double chartWidth = devices.length * barWidth < constraints.maxWidth 
                          ? constraints.maxWidth 
                          : devices.length * barWidth;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: chartWidth,
                          height: 300, // Increased height for better label space
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20, bottom: 10, left: 10),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: (peakDevice?.dailyUnit ?? 0) * 1.3,
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchCallback: (event, response) {
                                    if (response?.spot != null && event.isInterestedForInteractions) {
                                      final index = response!.spot!.touchedBarGroupIndex;
                                      if (index != _touchedIndex) {
                                        setState(() => _touchedIndex = index);
                                      }
                                    }
                                  },
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.black87,
                                    tooltipRoundedRadius: 8,
                                    tooltipBorder: const BorderSide(color: Colors.cyanAccent, width: 0.5),
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        '${devices[group.x.toInt()].name}\n',
                                        const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${rod.toY.toStringAsFixed(2)} kWh',
                                            style: const TextStyle(
                                              color: Colors.cyanAccent,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 80, // Increased reserved size
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() < devices.length && value.toInt() >= 0) {
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            space: 16,
                                            child: Transform.rotate(
                                              angle: -45 * 3.14159 / 180,
                                              child: SizedBox(
                                                width: 80, // Increased width for labels
                                                child: Text(
                                                  devices[value.toInt()].name,
                                                  style: TextStyle(
                                                    color: _touchedIndex == value.toInt() 
                                                      ? Colors.cyanAccent 
                                                      : Colors.white70,
                                                    fontSize: 10, // Slightly larger font
                                                    fontWeight: _touchedIndex == value.toInt() 
                                                      ? FontWeight.bold 
                                                      : FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 35,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toStringAsFixed(1),
                                          style: const TextStyle(color: Colors.white54, fontSize: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.white.withOpacity(0.05),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(
                                  devices.length,
                                  (index) {
                                    final isPeak = devices[index].id == peakDevice?.id;
                                    final isTouched = index == _touchedIndex;
                                    
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: devices[index].dailyUnit,
                                          gradient: LinearGradient(
                                            colors: isPeak 
                                              ? [Colors.orangeAccent, Colors.redAccent]
                                              : [Colors.cyanAccent, Colors.tealAccent],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          width: isPeak ? 18 : 12,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                          borderSide: isTouched 
                                            ? const BorderSide(color: Colors.white, width: 2)
                                            : BorderSide.none,
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: (peakDevice?.dailyUnit ?? 0) * 1.3,
                                            color: Colors.white.withOpacity(0.03),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Detail Card on Tap
                  if (_touchedIndex != -1 && _touchedIndex < devices.length)
                    _buildDetailCard(devices[_touchedIndex]),
                  
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailCard(DeviceModel device) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.electrical_services, color: Colors.cyanAccent, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      "Daily Consumption Details",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _touchedIndex = -1),
                icon: Icon(Icons.close, color: Colors.white.withOpacity(0.3), size: 20),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: Colors.white12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricDetail("Usage", "${device.dailyUnit.toStringAsFixed(2)} kWh"),
              _buildMetricDetail("Cost", "₹${device.dailyCost.toStringAsFixed(2)}"),
              _buildMetricDetail("Power", "${device.watt}W"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
