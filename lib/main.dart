import 'package:flutter/material.dart';
import 'package:noise/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Noise Measurement App'),
        ),
        body: const HomeScreen(),
      ),
    );
  }
}
