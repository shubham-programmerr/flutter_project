import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int sessionWordsGuessed = 0;
  List<String> sessionTimes = [];

  @override
  void initState() {
    super.initState();
    _clickPlayer = AudioPlayer();
    loadNewWord();
  }

  Future<void> playClickSound() async {
    try {
      await _clickPlayer.setSource(AssetSource('button-click-289742.wav'));
      await _clickPlayer.resume();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> loadNewWord() async {
    _timer?.cancel();
    setState(() {
      isLoading = true;
      feedback = "";
      _controller.clear();
      hint = "";
      timeLeft = 30;
    });

    try {
      originalWord = await fetchRandomWord(level);

      if (originalWord.isEmpty) {
        originalWord = "fallback";
        print('Using fallback word');
      }

      setState(() {
        jumbledWord = jumbleWord(originalWord);
        isLoading = false;
      });

      startTimer();
    } catch (e) {
      print('Error in loadNewWord: $e');
      setState(() {
        feedback = "Error fetching word. Please check your connection.";
        isLoading = false;
      });
    }
  }

  Future<String> fetchRandomWord(int level) async {
    final int wordLength = 3 + level;
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://random-word-api.vercel.app/api?words=1&length=$wordLength',
            ),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) return data[0];
      }
      throw Exception('Invalid response');
    } catch (_) {
      return "";
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

      sessionWordsGuessed++;
      sessionTimes.add((30 - timeLeft).toString());

      Future.delayed(const Duration(seconds: 1), () async {
        level++;
        await _saveSessionStats();
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
        _showGameLostDialog();
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

    if (level > 4 && hint.length < 3) {
      hint = originalWord.substring(0, 3);
    } else if (level > 3 && hint.length < 4) {
      hint = originalWord.substring(0, 4);
    } else if (hint.isEmpty) {
      hint = originalWord.substring(0, 2);
    }

    setState(() {});
  }

  Future<void> _saveSessionStats() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('score', score);
    prefs.setInt('level', level);
    prefs.setInt('sessionWordsGuessed', sessionWordsGuessed);
    prefs.setStringList('sessionTimes', sessionTimes);
  }

  void _showGameLostDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Game Over'),
            content: const Text("You ran out of time. Game Lost!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  setState(() {
                    score = 0;
                    level = 1;
                    hint = "";
                    feedback = "";
                    sessionWordsGuessed = 0;
                    sessionTimes.clear();
                  });
                  loadNewWord(); // Restart the game
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _clickPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 243, 243),
      appBar: AppBar(
        title: const Text('Jumble Word Game'),
        backgroundColor: Colors.deepPurple,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
              : Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://media.gettyimages.com/id/1171564349/video/retro-land.jpg?s=640x640&k=20&c=UytoK5VuR3nXezFTIryRH6D4mHUE846zUBZhlIJA5cw=',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.all(16),
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
                    Text(
                      'Level: $level',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Score: $score',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    if (hint.isNotEmpty)
                      Text(
                        'Hint: $hint',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter the correct word",
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      feedback,
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            feedback == "Correct!"
                                ? const Color.fromARGB(255, 9, 244, 17)
                                : const Color.fromARGB(255, 243, 27, 11),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Time left: $timeLeft',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
