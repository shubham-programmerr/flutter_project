// main_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:animated_background/animated_background.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'performance_screen.dart';

AudioPlayer _clickPlayer = AudioPlayer();

Future<void> playClickSound() async {
  try {
    await _clickPlayer.setSource(AssetSource('audio/menu-button-89141.mp3'));
    await _clickPlayer.resume();
  } catch (e) {
    print('Error playing sound: $e');
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  void navigateTo(Widget screen) async {
    await playClickSound();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    setState(() {}); // Refresh if needed after return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Colors.deepPurpleAccent,
            spawnOpacity: 0.0,
            opacityChangeRate: 0.25,
            minOpacity: 0.1,
            maxOpacity: 0.4,
            spawnMinSpeed: 10.0,
            spawnMaxSpeed: 50.0,
            spawnMinRadius: 5.0,
            spawnMaxRadius: 15.0,
            particleCount: 80,
          ),
        ),
        vsync: this,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                menuButton("Start Game", () => navigateTo(const GameScreen())),
                const SizedBox(height: 16),
                menuButton(
                  "Settings",
                  () => navigateTo(const SettingsScreen()),
                ),
                const SizedBox(height: 16),
                menuButton(
                  "Performance",
                  () => navigateTo(const PerformanceScreen()),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await playClickSound();
                    showAboutDialog(
                      context: context,
                      applicationName: "Jumble Word Game",
                      applicationVersion: "1.0.0",
                      applicationLegalese: "© 2025 UnJumbleWord",
                    );
                  },
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
      ),
    );
  }

  Widget menuButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, color: Colors.white),
      ),
    );
  }
}
