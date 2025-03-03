import 'package:flutter/material.dart';
import 'function_screen.dart';
import 'signup_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isAnimating = false;
  double _opacity = 0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isAnimating = true;
        _opacity = 1;
        _scale = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF904E95), Color(0xFFe96443)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to Safe Ping",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 700),
                  opacity: _opacity,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    scale: _scale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(_isAnimating ? 20 : 0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            label: "Username",
                            icon: Icons.person,
                            controller: _usernameController,
                          ),
                          CustomTextField(
                            label: "Password",
                            isPassword: true,
                            icon: Icons.lock,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: "LOGIN",
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const FunctionScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: "SIGN UP",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignupScreen()),
                              );
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              // Forgot password functionality can be added here
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
