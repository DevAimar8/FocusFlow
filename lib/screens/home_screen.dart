import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../providers/timer_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final timer = Stream.periodic(const Duration(seconds: 1), (_) {
    final now = DateTime.now();
    return DateFormat.Hm().format(now);
  });

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);

    const pastelBackground = Color(0xFFFFF5E4);
    const pastelAccent = Color(0xFFCAF7E3);
    const pastelHighlight = Color(0xFFD8B4F8);

    return Scaffold(
      backgroundColor: pastelBackground,
      appBar: AppBar(
        backgroundColor: pastelAccent,
        elevation: 0,
        title: Text(
          "FocusFlow",
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              await Provider.of<TimerProvider>(context, listen: false).reloadSettings();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/stats'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<String>(
                stream: timer,
                builder: (context, snapshot) => Text(
                  "🕒 ${snapshot.data ?? ''}",
                  style: GoogleFonts.fredoka(fontSize: 20, color: Colors.brown),
                ),
              ),
              const SizedBox(height: 24),
              CircularPercentIndicator(
                radius: 130.0,
                lineWidth: 15.0,
                percent: timerProvider.progress.clamp(0.0, 1.0),
                center: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Text(
                    timerProvider.formattedTime,
                    key: ValueKey(timerProvider.formattedTime),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade700,
                    ),
                  ),
                ),
                backgroundColor: pastelAccent.withOpacity(0.3),
                progressColor: pastelHighlight,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
              ),
              const SizedBox(height: 24),
              Text(
                timerProvider.sessionLabel,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Pomodoros completados: ${timerProvider.completedPomodoros}",
                style: GoogleFonts.fredoka(fontSize: 16),
              ),
              if (timerProvider.goalAchieved)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "🎯 ¡Meta diaria alcanzada!",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildButton(
                    label: "Start",
                    icon: Icons.play_arrow,
                    onPressed: timerProvider.isRunning
                        ? null
                        : timerProvider.startTimer,
                    color: pastelAccent,
                  ),
                  _buildButton(
                    label: "Pause",
                    icon: Icons.pause,
                    onPressed: timerProvider.isRunning
                        ? timerProvider.pauseTimer
                        : null,
                    color: pastelHighlight,
                  ),
                  _buildButton(
                    label: "Reset",
                    icon: Icons.refresh,
                    onPressed: timerProvider.resetTimer,
                    color: Colors.orange.shade200,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.brown),
      label: Text(
        label,
        style: GoogleFonts.fredoka(
          fontWeight: FontWeight.w600,
          color: Colors.brown.shade800,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 2,
      ),
    );
  }
}
