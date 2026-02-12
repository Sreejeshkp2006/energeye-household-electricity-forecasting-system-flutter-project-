import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ import your existing screens
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // ✅ USER LOGGED IN
          return const DashboardScreen();
        }

        // ✅ USER NOT LOGGED IN
        return const LoginScreen();
      },
    );
  }
}
