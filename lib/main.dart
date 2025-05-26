import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/drawer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafePingApp());
}

class SafePingApp extends StatelessWidget {
  const SafePingApp({super.key});

  Future<Widget> _getInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");   //testing purpose

    if (userId != null && userId.isNotEmpty) {
      return const DrawerScreen();
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Safe Ping',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: snapshot.data ?? const LoginScreen(),
        );
      },
    );
  }
}
