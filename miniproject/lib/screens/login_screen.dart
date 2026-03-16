import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifierCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;

  Future<void> login() async {
    if (!mounted) return;

    final input = identifierCtrl.text.trim();
    String? email;

    setState(() => loading = true);

    try {
      if (input.contains('@')) {
        email = input;
      } else {
        try {
          debugPrint("🔍 Looking up consumerNo: $input");
          // 1. Try to find the email by Consumer Number in Firestore
          final userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('consumerNo', isEqualTo: input)
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            email = userQuery.docs.first.get('email');
            debugPrint("✅ Found linked email: $email");
          } else {
            debugPrint(
                "❌ No document found for consumerNo: $input in Firestore 'users' collection.");
          }
        } catch (firestoreError) {
          debugPrint("🚨 Firestore lookup error for $input: $firestoreError");
          if (firestoreError.toString().contains('permission-denied')) {
            debugPrint(
                "💡 TIP: Check your Firestore Security Rules. Ensure 'users' is readable by unauthenticated users if you want this lookup to work BEFORE login.");
          }
        }

        // 2. Fallback logic: legacy email if lookup failed or returned no results
        if (email == null) {
          email = "$input@energeye.com";
          debugPrint("⚠️ Falling back to legacy format: $email");
        }
      }

      debugPrint("🚀 Attempting auth login for: $email");
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passwordCtrl.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        String errorMessage = "Login Failed";

        if (e.toString().contains('network-request-failed')) {
          errorMessage =
              "Network error. Please check your internet connection.";
        } else if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found' ||
              e.code == 'wrong-password' ||
              e.code == 'invalid-credential') {
            errorMessage = "Login Failed: Invalid Credentials";
            if (!input.contains('@')) {
              errorMessage =
                  "Login Failed. If you registered with an Email, please use it to sign in.";
            }
          } else {
            errorMessage = e.message ?? "Authentication Error";
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            action: identifierCtrl.text.trim().contains('@')
                ? null
                : SnackBarAction(
                    label: "Use Email?",
                    textColor: Colors.white,
                    onPressed: () {
                      // Hint the user they might need to use their registered email
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "If you registered with a Gmail/Email, please enter it in the top field.")),
                        );
                      }
                    },
                  ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> resetPassword() async {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "Enter your Consumer Number or Email to receive a reset link."),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () async {
              final input = emailController.text.trim();
              if (input.isEmpty) return;

              if (mounted) Navigator.pop(context);

              try {
                String? email = input.contains('@') ? input : null;

                // If input is not an email, lookup by Consumer Number
                if (email == null) {
                  final query = await FirebaseFirestore.instance
                      .collection('users')
                      .where('consumerNo', isEqualTo: input)
                      .limit(1)
                      .get();

                  if (query.docs.isNotEmpty) {
                    email = query.docs.first.get('email');
                  } else {
                    // Fallback to legacy format but warn if no account found
                    email = "$input@energeye.com";
                  }
                }

                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email!);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Reset link sent to $email"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } on FirebaseAuthException catch (e) {
                if (mounted) {
                  String errorMessage = "Failed to send reset email.";
                  if (e.code == 'user-not-found') {
                    errorMessage =
                        "Account not found for this Consumer No/Email.";
                  } else if (e.code == 'invalid-email') {
                    errorMessage = "The email address is not valid.";
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  String message = "Error: $e";
                  if (e.toString().contains('network-request-failed')) {
                    message = "Network error. Please check your internet.";
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: const Text("SEND RESET LINK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    identifierCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt,
                    size: 80,
                    color: Colors.cyanAccent,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "EnergEYE",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  "Smart Consumption Tracking",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 40),
                // Glassmorphic Card
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: identifierCtrl,
                        label: "Email Address",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: passwordCtrl,
                        label: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: resetPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.cyanAccent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.black87)
                              : const Text(
                                  "SIGN IN",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style:
                          TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      children: const [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.cyanAccent,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
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
