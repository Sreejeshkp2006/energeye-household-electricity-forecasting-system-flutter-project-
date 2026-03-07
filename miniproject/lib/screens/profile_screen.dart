import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text("This action is permanent and will remove all your data. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("DELETE"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final uid = user.uid;
          // Delete from Firestore
          await FirebaseFirestore.instance.collection('users').doc(uid).delete();
          // Delete from Auth
          await user.delete();
          
          if (context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } catch (e) {
        if (context.mounted) {
          String message = e.toString();
          if (message.contains('requires-recent-login')) {
            message = "For security, please logout and log in again before deleting your account.";
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  Future<Map<String, dynamic>?> _getUserData(String uid, String? email) async {
    // 1. Try fetching by UID (Standard)
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }

    // 2. Secondary check: Search by email in case of legacy/unsynced accounts
    if (email != null) {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return query.docs.first.data();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Not logged in"));
    final uid = user.uid;
    final email = user.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF0F2027),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getUserData(uid, email),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong", style: TextStyle(color: Colors.white)));
            }

            final data = snapshot.data;
            if (data == null) {
              return const Center(child: Text("Profile data not found", style: TextStyle(color: Colors.white)));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  // User Avatar Placeholder
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.5), width: 2),
                    ),
                    child: const Icon(Icons.person, size: 80, color: Colors.cyanAccent),
                  ),
                  const SizedBox(height: 30),
                  
                  // Profile Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.person_outline, "Name", data['name'] ?? 'N/A'),
                        const Divider(color: Colors.white12),
                        _buildInfoRow(Icons.email_outlined, "Email", data['email'] ?? user.email ?? 'N/A'),
                        const Divider(color: Colors.white12),
                        _buildInfoRow(Icons.assignment_ind_outlined, "Consumer No", data['consumerNo'] ?? 'N/A'),
                        const Divider(color: Colors.white12),
                        _buildInfoRow(Icons.phone_android_outlined, "Mobile", data['mobile'] ?? 'N/A'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Actions
                  _buildActionButton(
                    "Edit Profile",
                    Icons.edit_outlined,
                    Colors.cyanAccent,
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditProfileScreen(userData: data)),
                      );
                      if (updated == true) {
                        setState(() {}); // Refresh data
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildActionButton(
                    "Reset Password",
                    Icons.lock_reset,
                    Colors.orange.shade300,
                    onTap: () async {
                      final email = user.email;
                      if (email != null) {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Reset email sent!"), backgroundColor: Colors.green),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildActionButton(
                    "Logout",
                    Icons.logout,
                    Colors.white70,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  TextButton.icon(
                    onPressed: () => _deleteAccount(context),
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    label: const Text("Delete Account", style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, {required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black87),
        label: Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
