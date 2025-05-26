import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LevelSettingsScreen extends StatefulWidget {
  const LevelSettingsScreen({super.key});

  @override
  State<LevelSettingsScreen> createState() => _LevelSettingsScreenState();
}

class _LevelSettingsScreenState extends State<LevelSettingsScreen> {
  String selectedDifficulty = 'Easy';
  int numberOfWords = 5;

  final List<String> difficultyLevels = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    loadLevelSettings();
  }

  Future<void> loadLevelSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDifficulty = prefs.getString('difficulty') ?? 'Easy';
      numberOfWords = prefs.getInt('numWords') ?? 5;
    });
  }

  Future<void> saveLevelSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('difficulty', selectedDifficulty);
    await prefs.setInt('numWords', numberOfWords);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Level settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Level Settings"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.deepPurple[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Select Difficulty",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedDifficulty,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: difficultyLevels.map((level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Number of Words",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Slider(
              min: 3,
              max: 20,
              divisions: 17,
              label: numberOfWords.toString(),
              value: numberOfWords.toDouble(),
              onChanged: (value) {
                setState(() {
                  numberOfWords = value.toInt();
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveLevelSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                "Save Settings",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
