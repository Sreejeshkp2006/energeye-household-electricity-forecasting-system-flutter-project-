import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController consumerCtrl;
  late TextEditingController mobileCtrl;
  late TextEditingController emailCtrl;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.userData['name']);
    consumerCtrl = TextEditingController(text: widget.userData['consumerNo']);
    mobileCtrl = TextEditingController(text: widget.userData['mobile']);
    emailCtrl = TextEditingController(text: widget.userData['email'] ?? FirebaseAuth.instance.currentUser?.email);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    consumerCtrl.dispose();
    mobileCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    final newEmail = emailCtrl.text.trim();
    if (nameCtrl.text.trim().isEmpty || consumerCtrl.text.trim().isEmpty || newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name, Consumer Number, and Email are required")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user!.uid;
      final oldEmail = user.email;

      // 1. Update Email in Firebase Auth if changed
      if (newEmail != oldEmail) {
        try {
          // Send verification email before updating to ensure the new email is valid
          await user.verifyBeforeUpdateEmail(newEmail);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("A verification email has been sent to your new email. Please verify it to complete the shift."),
                backgroundColor: Colors.blueAccent,
                duration: Duration(seconds: 5),
              ),
            );
          }
        } on FirebaseAuthException catch (authError) {
          if (authError.code == 'requires-recent-login') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Email update requires a recent login. Please logout and log back in."),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
            setState(() => loading = false);
            return;
          }
          rethrow;
        }
      }

      // 2. Update Firestore data
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameCtrl.text.trim(),
        'consumerNo': consumerCtrl.text.trim(),
        'mobile': mobileCtrl.text.trim(),
        'email': newEmail,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Return true to indicate change
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating profile: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              _buildField("Name", nameCtrl, Icons.person_outline),
              const SizedBox(height: 20),
              _buildField("Email Address", emailCtrl, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildField("Consumer Number", consumerCtrl, Icons.assignment_ind_outlined),
              const SizedBox(height: 20),
              _buildField("Mobile Number", mobileCtrl, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.black87)
                      : const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}
