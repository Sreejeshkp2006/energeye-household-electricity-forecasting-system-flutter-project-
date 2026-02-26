import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ✅ import your navigation wrapper
import 'nav_wrapper.dart';
import 'screens/login_screen.dart';

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
          // ✅ USER LOGGED IN - Go to Bottom Nav Wrapper
          return const MainNavigation();
        }

        // ✅ USER NOT LOGGED IN
        return const LoginScreen();
      },
    );
  }
}
