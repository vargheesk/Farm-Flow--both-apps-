
// auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app2/pages/login/login.dart';
import 'package:app2/pages/home/home.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the snapshot has a user
        if (snapshot.hasData) {
          return const Home();
        }
        // Return login if there's no user
        return Login();
      },
    );
  }
}