import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class UserProgressScreen extends StatefulWidget {
  const UserProgressScreen({super.key});

  @override
  State<UserProgressScreen> createState() => _UserProgressScreenState();
}

class _UserProgressScreenState extends State<UserProgressScreen> {
  int _highestLevel = 1;
  List<int> _performanceData = []; // List of levels completed or scores per session

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  Future<void> _loadUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highestLevel = prefs.getInt('highestLevel') ?? 1;
      _performanceData = prefs.getStringList('performanceData')?.map((e) => int.tryParse(e) ?? 0).toList() ?? [];
    });
  }

  Widget _buildGraph() {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
         bottomTitles: AxisTitles(
        sideTitles: SideTitles(
            showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) => Text('L${value.toInt()}'),
          ),
          ),
           leftTitles: AxisTitles(
         sideTitles: SideTitles(
         showTitles: true,
          getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
            ),
           ),
           topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
          ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
          ),
          ),

        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: _performanceData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
            belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.2)),
            dotData: FlDotData(show: true),
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Highest Level Reached: $_highestLevel", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("Performance Graph", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            SizedBox(height: 200, child: _performanceData.isNotEmpty ? _buildGraph() : const Center(child: Text("No data yet"))),
          ],
        ),
      ),
    );
  }
}
