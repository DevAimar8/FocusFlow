import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/preferences.dart';
import '../utils/notifications.dart';

enum TimerSessionType { pomodoro, shortBreak, longBreak }

class TimerProvider with ChangeNotifier {
  int pomodoroDuration = 25 * 60;
  int shortBreakDuration = 5 * 60;
  int longBreakDuration = 15 * 60;
  int sessionsBeforeLongBreak = 4;

  late int _remainingSeconds;
  TimerSessionType _currentSession = TimerSessionType.pomodoro;
  int _completedPomodoros = 0;
  Timer? _timer;
  bool _isRunning = false;
  int _dailyGoal = 4;

  TimerProvider() {
    _loadInitialSettings();
  }

  Future<void> _loadInitialSettings() async {
    final settings = await Preferences.loadSettings();
    pomodoroDuration = settings['pomodoro']! * 60;
    shortBreakDuration = settings['shortBreak']! * 60;
    longBreakDuration = settings['longBreak']! * 60;
    sessionsBeforeLongBreak = settings['sessionsBeforeLong']!;
    _dailyGoal = await Preferences.loadDailyGoal();
    _remainingSeconds = _getSessionDuration(_currentSession);
    notifyListeners();
  }

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  TimerSessionType get currentSession => _currentSession;
  int get completedPomodoros => _completedPomodoros;
  int get dailyGoal => _dailyGoal;
  bool get goalAchieved => _completedPomodoros >= _dailyGoal;

  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  double get progress {
    final total = _getSessionDuration(_currentSession);
    return 1 - (_remainingSeconds / total);
  }

  String get sessionLabel {
    switch (_currentSession) {
      case TimerSessionType.pomodoro:
        return "Pomodoro";
      case TimerSessionType.shortBreak:
        return "Descanso corto";
      case TimerSessionType.longBreak:
        return "Descanso largo";
    }
  }

  void startTimer() {
    if (_isRunning || _timer != null) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
      } else {
        _onSessionCompleted();
      }
      notifyListeners();
    });

    notifyListeners();
  }

  void pauseTimer() {
    _stopTimer();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _stopTimer();
    _isRunning = false;
    _remainingSeconds = _getSessionDuration(_currentSession);
    notifyListeners();
  }

  void _onSessionCompleted() {
    _stopTimer();
    _isRunning = false;

    NotificationService.showNotification(
      title: "¡Sesión completada!",
      body: "$sessionLabel finalizado. ¿Listo para continuar?",
    );

    if (_currentSession == TimerSessionType.pomodoro) {
      _completedPomodoros++;
      _saveSessionToHistory();
    }

    final nextSession = _currentSession == TimerSessionType.pomodoro
        ? (_completedPomodoros % sessionsBeforeLongBreak == 0
            ? TimerSessionType.longBreak
            : TimerSessionType.shortBreak)
        : TimerSessionType.pomodoro;

    _switchSession(nextSession);
    startTimer();
  }

  void _switchSession(TimerSessionType type) {
    _currentSession = type;
    _remainingSeconds = _getSessionDuration(type);
    notifyListeners();
  }

  int _getSessionDuration(TimerSessionType type) {
    switch (type) {
      case TimerSessionType.pomodoro:
        return pomodoroDuration;
      case TimerSessionType.shortBreak:
        return shortBreakDuration;
      case TimerSessionType.longBreak:
        return longBreakDuration;
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> reloadSettings() async {
    final settings = await Preferences.loadSettings();
    pomodoroDuration = settings['pomodoro']! * 60;
    shortBreakDuration = settings['shortBreak']! * 60;
    longBreakDuration = settings['longBreak']! * 60;
    sessionsBeforeLongBreak = settings['sessionsBeforeLong']!;
    _dailyGoal = await Preferences.loadDailyGoal();
    resetTimer();
  }

  Future<void> _saveSessionToHistory() async {
    final prefs = await Preferences.getRawPrefs();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = 'history_$today';
    int currentCount = prefs.getInt(key) ?? 0;
    prefs.setInt(key, currentCount + 1);
  }
}
