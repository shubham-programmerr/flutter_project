import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _controller = TextEditingController();
  String originalWord = "";
  String jumbledWord = "";
  String feedback = "";
  bool isLoading = true;
  int score = 0;
  int level = 1;
  int timeLeft = 30;
  Timer? _timer;
  String hint = "";
  late AudioPlayer _clickPlayer;

  @override
  void initState() {
    super.initState();
    _clickPlayer = AudioPlayer();
    loadNewWord();
  }

  Future<void> playClickSound() async {
    try {
      // Set the asset source for the audio file
      await _clickPlayer.setSource(AssetSource('button-click-289742.wav'));
      // Play the sound
      await _clickPlayer.resume();
    } catch (e) {
      // Log the error for debugging purposes
      print('Error playing sound: $e');
    }
  }

  Future<void> loadNewWord() async {
    _timer?.cancel(); // Ensure any active timer is canceled
    setState(() {
      isLoading = true;
      feedback = ""; // Reset feedback message
      _controller.clear(); // Clear the user's input
      hint = ""; // Reset hint
    });

    try {
      originalWord = await fetchRandomWord(
        level,
      ); // Fetch new word based on level
      print('Original Word: $originalWord'); // Debugging log

      // If the API returns an empty response, use fallback
      if (originalWord.isEmpty) {
        originalWord = "fallback";
        print('Using fallback word');
      }

      // Update state with new jumbled word
      setState(() {
        jumbledWord = jumbleWord(originalWord);
        print('Jumbled Word: $jumbledWord'); // Debugging log
        isLoading = false;
      });

      // Start the timer for the new word
      startTimer();
    } catch (e) {
      print('Error in loadNewWord: $e'); // Log any errors
      setState(() {
        feedback = "Error fetching word. Please check your connection.";
        isLoading = false;
      });
    }
  }

  Future<String> fetchRandomWord(int level) async {
    final int wordLength = 3 + level; // Word length increases with level
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://random-word-api.vercel.app/api?words=1&length=$wordLength',
            ),
          )
          .timeout(
            const Duration(seconds: 30),
          ); // Set timeout for slow connections

      print('API Response Status: ${response.statusCode}'); // Debugging log
      print('API Response Body: ${response.body}'); // Debugging log

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data[0];
        }
      }
      throw Exception('Invalid response from API');
    } catch (e) {
      print('Error fetching word: $e'); // Log any API errors
      return ""; // Return empty string if an error occurs
    }
  }

  String jumbleWord(String word) {
    List<String> letters = word.split('');
    letters.shuffle();
    while (letters.join() == word) {
      letters.shuffle();
    }
    return letters.join();
  }

  void checkAnswer() async {
    await playClickSound();
    final userInput = _controller.text.trim().toLowerCase();
    if (userInput == originalWord) {
      setState(() {
        feedback = "Correct!";
        score++;
      });
      Future.delayed(const Duration(seconds: 1), () {
        level++;
        loadNewWord();
      });
    } else {
      setState(() {
        feedback = "Try again!";
      });
    }
  }

  void startTimer() {
    _timer?.cancel();
    setState(() {
      timeLeft = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft == 0) {
        timer.cancel();
        setState(() {
          feedback = "Time's up! The correct word was $originalWord.";
        });
        Future.delayed(const Duration(seconds: 3), () {
          loadNewWord();
        });
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  void getHint() async {
    await playClickSound();
    if (originalWord.isEmpty) return;

    if (level > 3 && hint.length < 4) {
      hint = originalWord.substring(0, 4);
    } else if (level > 4 && hint.length < 3) {
      hint = originalWord.substring(0, 3);
    } else if (hint.isEmpty) {
      hint = originalWord.substring(0, 2);
    }

    setState(() {}); // Refresh UI after updating hint
  }

  @override
  void dispose() {
    _clickPlayer.dispose(); // Dispose the player
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text('Jumble Word Game'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      jumbledWord,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Level: $level', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('Score: $score', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    if (hint.isNotEmpty)
                      Text(
                        'Hint: $hint',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter the correct word",
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: getHint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text(
                        "Hint",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      feedback,
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            feedback == "Correct!" ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Time left: $timeLeft s',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
