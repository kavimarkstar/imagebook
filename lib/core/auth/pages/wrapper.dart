import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:imagebook/core/auth/pages/auth/login.dart';
import 'package:imagebook/navigation/navigation.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check the connection state and user state
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for authentication status
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is signed in
          return NavigationPage();
        } else {
          // User is not signed in
          return const LoginPage();
        }
      },
    );
  }
}
