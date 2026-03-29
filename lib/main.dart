import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TagSnagApp());
}

class TagSnagApp extends StatelessWidget {
  const TagSnagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TagSnag',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
