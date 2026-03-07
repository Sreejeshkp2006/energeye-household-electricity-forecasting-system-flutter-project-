import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final consumerCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;

  Future<void> register() async {
    if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty || consumerCtrl.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields")),
        );
      }
      return;
    }

    setState(() => loading = true);

    try {
      final email = emailCtrl.text.trim();
      final user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: passwordCtrl.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user!.uid)
          .set({
        'name': nameCtrl.text.trim(),
        'consumerNo': consumerCtrl.text.trim(),
        'email': email,
        'mobile': mobileCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('network-request-failed')) {
          errorMessage = "Network error. Please check your internet connection and try again.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    consumerCtrl.dispose();
    emailCtrl.dispose();
    mobileCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: const Color(0xFF0F2027),
        foregroundColor: Colors.white,
      ),
      body: Container(
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                _buildField("Name", nameCtrl, Icons.person_outline),
                const SizedBox(height: 15),
                _buildField("Consumer Number", consumerCtrl, Icons.assignment_ind_outlined),
                const SizedBox(height: 15),
                _buildField("Email Address", emailCtrl, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 15),
                _buildField("Mobile Number", mobileCtrl, Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 15),
                _buildField("Password", passwordCtrl, Icons.lock_outline, isPassword: true),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: loading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.black87)
                        : const Text(
                            "REGISTER",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
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
