import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'welcome_screen.dart'; // Import the WelcomeScreen

AudioPlayer _clickPlayer = AudioPlayer();

Future<void> playClickSound() async {
  try {
    await _clickPlayer.setSource(AssetSource('assets/menu-button-89141.mp3'));
    await _clickPlayer.resume();
  } catch (e) {
    print('Error playing sound: $e');
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void startGame(BuildContext context) async {
    await playClickSound();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  void showSettings(BuildContext context) async {
    await playClickSound();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void showAbout(BuildContext context) async {
    await playClickSound();
    showAboutDialog(
      context: context,
      applicationName: "Jumble Word Game",
      applicationVersion: "1.0.0",
      applicationLegalese: "© 2025 Dadhich tech",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text('Main Menu'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => startGame(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  "Start Game",
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => showSettings(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  "Settings",
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => showAbout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  "About",
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jumble Word Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      // Set the WelcomeScreen as the first screen
      home: const WelcomeScreen(),
    );
  }
}
