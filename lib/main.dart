import 'package:flutter/material.dart';
import 'welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jumble Word Game',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const WelcomeScreen(),
    );
  }
}
