import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_manager.dart'; // Make sure this is correctly implemented

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isMusicOn = true;
  String playerName = "Player";
  int highestLevel = 1;
  int numberOfWords = 10;
  String difficulty = "Easy";

  final TextEditingController _nameController = TextEditingController();

  final List<String> difficultyOptions = ['Easy', 'Medium', 'Hard'];
  final List<int> wordCountOptions = [5, 10, 15, 20, 25, 30];

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isMusicOn = prefs.getBool('music') ?? true;
    playerName = prefs.getString('playerName') ?? "Player";
    highestLevel = prefs.getInt('highestLevel') ?? 1;
    numberOfWords = prefs.getInt('numberOfWords') ?? 10;
    difficulty = prefs.getString('difficulty') ?? "Easy";

    _nameController.text = playerName;

    if (isMusicOn) {
      await AudioManager().init();
    } else {
      await AudioManager().toggleMusic(false);
    }

    setState(() {});
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music', isMusicOn);
    await prefs.setString('playerName', _nameController.text);
    await prefs.setInt('numberOfWords', numberOfWords);
    await prefs.setString('difficulty', difficulty);

    setState(() {
      playerName = _nameController.text;
    });

    await AudioManager().toggleMusic(isMusicOn);
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
                onChanged: (value) async {
                  setState(() {
                    isMusicOn = value;
                  });
                  await saveSettings();
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
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Number of Words:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  value: numberOfWords,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        numberOfWords = value;
                      });
                    }
                  },
                  items: wordCountOptions
                      .map((val) => DropdownMenuItem(
                            value: val,
                            child: Text(val.toString()),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Difficulty:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 20),
                DropdownButton<String>(
                  value: difficulty,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        difficulty = value;
                      });
                    }
                  },
                  items: difficultyOptions
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await saveSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings saved')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
