import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  int totalWords = 0;
  double avgTime = 0;
  double xpPercent = 0;
  int streak = 0;

  List<Map<String, dynamic>> recentSessions = [];

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalWords = prefs.getInt('totalWords') ?? 0;
      avgTime = prefs.getDouble('avgTime') ?? 0.0;
      xpPercent = prefs.getDouble('xpPercent') ?? 0.0;
      streak = prefs.getInt('streak') ?? 0;

      final sessionData = prefs.getStringList('recentSessions') ?? [];
      recentSessions =
          sessionData.map((str) {
            final parts = str.split('|');
            return {
              "date": parts[0],
              "words": int.tryParse(parts[1]) ?? 0,
              "avg": double.tryParse(parts[2]) ?? 0.0,
            };
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text("Performance Dashboard"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Achievements",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildStatCard(
                    "Total Words",
                    "$totalWords",
                    Icons.text_fields,
                    Colors.teal,
                  ),
                  _buildStatCard(
                    "Avg Time",
                    "${avgTime.toStringAsFixed(1)}s",
                    Icons.timer,
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  animation: true,
                  percent: xpPercent.clamp(0.0, 1.0),
                  center: Text(
                    "XP ${(xpPercent * 100).toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  footer: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Progress to next level",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.deepPurple,
                  backgroundColor: Colors.deepPurple.shade100,
                ),
              ),
              const SizedBox(height: 40),

              const Text(
                "Recent Sessions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 180,
                  child:
                      recentSessions.isEmpty
                          ? const Center(
                            child: Text("No sessions yet. Start playing!"),
                          )
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recentSessions.length,
                            itemBuilder: (context, index) {
                              final session = recentSessions[index];
                              return _buildSessionCard(
                                session["date"],
                                "Words: ${session["words"]}",
                                "Avg: ${session["avg"]}s",
                                Colors.purple,
                              );
                            },
                          ),
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Streak Progress",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              LinearPercentIndicator(
                animation: true,
                lineHeight: 20.0,
                animationDuration: 1200,
                percent: (streak / 7).clamp(0.0, 1.0),
                center: Text("$streak-day streak!"),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Colors.redAccent,
                backgroundColor: Colors.red.shade100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String data, IconData icon, Color color) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.7), color]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white70)),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  data,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    String date,
    String words,
    String avgTime,
    Color color,
  ) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(words, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(avgTime, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
