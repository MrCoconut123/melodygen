import 'package:flutter/material.dart';
import 'dart:async';
import 'generate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      routes: {
        '/generate': (context) => Generate(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Color color1 = Color(0xFF7A9098);
  final Color color2 = Color(0xFF667A6B);
  final Color color3 = Color(0xFF5E6F6B);
  final Color color4 = Color(0xFF4F4E59);
  final Color color5 = Color(0xFF3E3D45);
  final Color color6 = Color(0xFF2F2E37);
  final Color color7 = Color(0xFF1F1E27);

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    // Simulate some initialization tasks
    await Future.delayed(Duration(seconds: 3));

    // Navigate to the Generate page
    Navigator.of(context).pushReplacementNamed('/generate');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color7, color6],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                size: 100.0,
                color: color1,
              ),
              SizedBox(height: 20),
              Text(
                'Melody Gen',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
