import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'audio_manager.dart'; // Custom audio manager to control music

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isMusicOn = true;
  String playerName = "Player";
  int highestLevel = 1;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isMusicOn = prefs.getBool('music') ?? true;
      playerName = prefs.getString('playerName') ?? "Player";
      highestLevel = prefs.getInt('highestLevel') ?? 1;
      _nameController.text = playerName;
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music', isMusicOn);
    await prefs.setString('playerName', _nameController.text);
    setState(() {
      playerName = _nameController.text;
    });

    // Control the music directly
    /*if (isMusicOn) {
      AudioManager.instance.playBackgroundMusic();
    } else {
      AudioManager.instance.stopBackgroundMusic();
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Player Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Music', style: TextStyle(fontSize: 20)),
              trailing: Switch(
                value: isMusicOn,
                onChanged: (value) {
                  setState(() {
                    isMusicOn = value;
                  });
                  saveSettings(); // Save & apply immediately
                },
                activeColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                'Highest Level: $highestLevel',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                saveSettings();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Settings saved')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
