import 'package:flutter/material.dart';
import 'drawer_screen.dart';
import 'map_screen.dart';

class FunctionScreen extends StatefulWidget {
  const FunctionScreen({super.key});

  @override
  _FunctionScreenState createState() => _FunctionScreenState();
}

class _FunctionScreenState extends State<FunctionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.2)
          .chain(CurveTween(curve: Curves.elasticOut))
          .animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeOut),
        ),
      );
    });

    _fadeAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, 1.0, curve: Curves.easeIn),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safe Ping"),
        backgroundColor: const Color(0xFF651FFF),
      ),
      drawer: const DrawerScreen(),
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
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      List<String> labels = ["Reports", "Ping Location", "Upload"];
                      List<IconData> icons = [Icons.message, Icons.location_on, Icons.cloud_upload];
                      List<VoidCallback> actions = [
                            () {},
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen())),
                            () {},
                      ];

                      return Column(
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimations[index],
                            child: ScaleTransition(
                              scale: _scaleAnimations[index],
                              child: _buildCircularButton(labels[index], icons[index], actions[index]),
                            ),
                          ),
                          if (index < 2) const SizedBox(height: 20),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton(String label, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ],
    );
  }
}
