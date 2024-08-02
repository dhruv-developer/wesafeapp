import 'package:flutter/material.dart';
import 'package:we_safe/screens/map_screen.dart';
import 'package:we_safe/screens/onboarding_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeSafe App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: OnboardingScreen(),
      routes: {
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
