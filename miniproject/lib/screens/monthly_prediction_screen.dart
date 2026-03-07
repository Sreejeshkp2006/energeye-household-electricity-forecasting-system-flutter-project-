import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ml_service.dart';
import '../models/device_model.dart';
import '../widgets/tips_section.dart';

class MonthlyPredictionScreen extends StatefulWidget {
  const MonthlyPredictionScreen({super.key});

  @override
  State<MonthlyPredictionScreen> createState() =>
      _MonthlyPredictionScreenState();
}

class _MonthlyPredictionScreenState extends State<MonthlyPredictionScreen> {
  Map<int, double> predictions = {};
  Map<int, double> monthlyUnits = {};
  Map<int, double> monthlyRates = {};
  bool isLoading = true;
  String? error;

  final List<String> _monthNames = [
    "January", "February", "March", "April", "May", "June", 
    "July", "August", "September", "October", "November", "December"
  ];

  @override
  void initState() {
    super.initState();
    _fetchAndPredict();
  }

  Future<void> _fetchAndPredict() async {
    setState(() => isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Resolve effective ID (UID or Email)
      String effectiveId = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists && user.email != null) {
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          effectiveId = query.docs.first.id;
        }
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(effectiveId)
          .collection('devices')
          .get();

      final devices = snapshot.docs
          .map((doc) => DeviceModel.fromFirestore(doc.id, doc.data()))
          .toList();

      // Group data by month
      final Map<int, List<DeviceModel>> grouped = {};
      for (var d in devices) {
        grouped.putIfAbsent(d.month, () => []).add(d);
      }

      final Map<int, double> newMonthlyUnits = {};
      final Map<int, double> newMonthlyRates = {};
      final Map<int, double> newPredictions = {};

      for (var month in grouped.keys) {
        final monthDevices = grouped[month]!;
        final totalUnits = monthDevices.fold(0.0, (sum, d) => sum + d.dailyUnit);
        final rate = monthDevices.first.rate;

        newMonthlyUnits[month] = totalUnits;
        newMonthlyRates[month] = rate;

        try {
          final pred = await MLService.predictBill(
            totalDailyUnits: totalUnits,
            month: month,
            unitRate: rate,
          );
          newPredictions[month] = pred;
        } catch (e) {
          debugPrint("Failed prediction for $month: $e");
        }
      }

      if (!mounted) return;

      setState(() {
        monthlyUnits = newMonthlyUnits;
        monthlyRates = newMonthlyRates;
        predictions = newPredictions;
        isLoading = false;
        error = null;
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
      backgroundColor: const Color(0xFFFBFDFF),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC)))
            : error != null
                ? _buildErrorState()
                : monthlyUnits.isEmpty
                    ? _buildEmptyState()
                    : _buildPredictionList(),
      ),
    );
  }

  Widget _buildPredictionList() {
    final sortedMonths = monthlyUnits.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _fetchAndPredict,
      color: Colors.teal.shade400,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 32),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedMonths.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final month = sortedMonths[index];
                final units = monthlyUnits[month]!;
                final pred = predictions[month];
                
                return _buildMonthCard(month, units, pred);
              },
            ),

            const SizedBox(height: 40),
            const TipsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard(int month, double units, double? prediction) {
    final bool isHigh = (prediction ?? 0) > 2000;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.teal.shade50),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _monthNames[month - 1].toUpperCase(),
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Usage: ${units.toStringAsFixed(1)} Units/Day",
                          style: TextStyle(
                            color: Colors.blueGrey.shade300,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (isHigh)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade400, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              "High",
                              style: TextStyle(color: Colors.orange.shade700, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                prediction == null
                    ? CircularProgressIndicator(color: Colors.teal.shade100, strokeWidth: 2)
                    : Column(
                        children: [
                          Text(
                            "₹${prediction.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2D3748),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Estimated Bill",
                            style: TextStyle(
                              color: Colors.blueGrey.shade200,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          if (isHigh)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.red.shade50.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Text(
                "Tip: Reduce heavy appliance usage to save.",
                style: TextStyle(color: Colors.red.shade800, fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "INSIGHTS",
          style: TextStyle(
            color: Colors.teal.shade700,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const Text(
          "Monthly Predictions",
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_rounded, color: Colors.red.shade300, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              "Something went wrong",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
            ),
            const SizedBox(height: 12),
            Text(
              error ?? "We couldn't reach the prediction engine.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey.shade400, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchAndPredict,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text("Retry", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_graph_rounded, size: 48, color: Colors.teal.shade200),
                ),
                const SizedBox(height: 24),
                const Text(
                  "No Data for Prediction",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
                ),
                const SizedBox(height: 12),
                Text(
                  "Add your appliances in the Services tab to see your projected bills for each month.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey.shade400, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

