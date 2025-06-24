import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/preferences.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<int> weeklyStats = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await Preferences.loadWeeklyStats();
    setState(() => weeklyStats = stats);
  }

  @override
  Widget build(BuildContext context) {
    const pastelBackground = Color(0xFFFFF5E4);
    const pastelAccent = Color(0xFFCAF7E3);

    return Scaffold(
      backgroundColor: pastelBackground,
      appBar: AppBar(
        title: Text("Estadísticas", style: GoogleFonts.fredoka()),
        backgroundColor: pastelAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: weeklyStats.isEmpty
            ? const Center(child: Text("No hay datos aún."))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pomodoros esta semana:", style: GoogleFonts.fredoka(fontSize: 20)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                                return Text(
                                  days[value.toInt()],
                                  style: GoogleFonts.fredoka(fontSize: 14),
                                );
                              },
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 2,
                              getTitlesWidget: (value, _) => Text('${value.toInt()}'),
                            ),
                          ),
                        ),
                        barGroups: List.generate(
                          weeklyStats.length,
                          (i) => BarChartGroupData(x: i, barRods: [
                            BarChartRodData(
                              toY: weeklyStats[i].toDouble(),
                              color: Colors.deepPurpleAccent,
                              width: 16,
                              borderRadius: BorderRadius.circular(6),
                            )
                          ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
