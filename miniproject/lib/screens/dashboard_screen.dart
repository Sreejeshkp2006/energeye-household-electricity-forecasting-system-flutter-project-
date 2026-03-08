import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_screen.dart';
import '../models/device_model.dart';
import '../widgets/device_tile.dart';
import '../widgets/tips_section.dart';
import 'user_guide_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedMonth = DateTime.now().month;
  String? _resolvedUserId;
  bool _isLoadingId = true;

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

    print("DEBUG: Resolving ID for User UID: ${user.uid}, Email: ${user.email}");

    // 1. Try UID
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      print("DEBUG: Found document by UID");
      if (mounted) {
        setState(() {
          _resolvedUserId = user.uid;
          _isLoadingId = false;
        });
      }
      return;
    }

    // 2. Try Email Fallback
    if (user.email != null) {
      print("DEBUG: UID doc missing, trying Email fallback...");
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        print("DEBUG: Found document by Email: ${query.docs.first.id}");
        if (mounted) {
          setState(() {
            _resolvedUserId = query.docs.first.id;
            _isLoadingId = false;
          });
        }
        return;
      }
    }

    print("DEBUG: No document found, defaulting to UID");
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
        backgroundColor: Color(0xFFFBFDFF),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC))),
      );
    }

    final effectiveId = _resolvedUserId ?? user.uid;
    print("DEBUG: Dashboard using effectiveId: $effectiveId");

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(effectiveId)
          .collection('devices')
          .where('month', isEqualTo: _selectedMonth)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFFBFDFF),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC))),
          );
        }

        final devices = snapshot.data!.docs
            .map((doc) => DeviceModel.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
            .toList();

        final totalDailyUnit =
            devices.fold(0.0, (total, d) => total + d.dailyUnit);

        final totalDailyCost =
            devices.fold(0.0, (total, d) => total + d.dailyCost);

        return Scaffold(
          backgroundColor: const Color(0xFFFBFDFF),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  /// NATURAL HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "EnergEYE",
                            style: TextStyle(
                              color: Colors.teal.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            "Dashboard",
                            style: TextStyle(
                              color: Color(0xFF2D3748),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.teal.shade50,
                          child: Icon(Icons.person_2_outlined, color: Colors.teal.shade400, size: 22),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),

                  /// INTEGRATED MONTH SELECTOR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedMonth,
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.teal.shade300),
                        style: const TextStyle(
                          color: Color(0xFF4A5568),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        items: List.generate(12, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text("Billing Period: ${_monthNames[index]}"),
                          );
                        }),
                        onChanged: (val) {
                          setState(() {
                            _selectedMonth = val!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// MINIMALIST SUMMARY SECTION
                  Row(
                    children: [
                      _buildNaturalCard(
                        "Energy Units",
                        "${totalDailyUnit.toStringAsFixed(1)} kWh",
                        Icons.bolt_rounded,
                        Colors.teal.shade400,
                        isWarning: totalDailyUnit * 30 > 300,
                      ),
                      const SizedBox(width: 16),
                      _buildNaturalCard(
                        "Current Cost",
                        "₹${totalDailyCost.toStringAsFixed(0)}",
                        Icons.payments_outlined,
                        Colors.orange.shade300,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  /// TIPS SECTION
                  const TipsSection(),

                  const SizedBox(height: 24),

                  /// APP GUIDE ACTION
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserGuideScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade400, Colors.teal.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "App Guide & Workings",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Learn how to optimize energy",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// LIST HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "My Appliances",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                      if (devices.isNotEmpty)
                         Text(
                           "${devices.length} active",
                           style: TextStyle(color: Colors.teal.shade300, fontSize: 13, fontWeight: FontWeight.w500),
                         ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (devices.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: devices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final d = devices[index];
                        return DeviceTile(
                          device: d,
                          onDelete: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(effectiveId)
                                .collection('devices')
                                .doc(d.id)
                                .delete();
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNaturalCard(String title, String value, IconData icon, Color color, {bool isWarning = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isWarning ? Colors.red.shade50 : Colors.teal.shade50),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isWarning ? Colors.red.shade300 : color, size: 22),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                if (isWarning)
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade300, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.teal.shade50.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade50),
      ),
      child: Column(
        children: [
          Icon(Icons.eco_outlined, size: 40, color: Colors.teal.shade100),
          const SizedBox(height: 16),
          Text(
            "Track your appliances by heading to the Services tab and adding more!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
