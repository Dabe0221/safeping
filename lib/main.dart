import  'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SafePingApp());
}

class SafePingApp extends StatelessWidget {
  const SafePingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Ping',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
