import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  // Configuración por defecto
  static const _defaultSettings = {
    'pomodoro': 25,
    'shortBreak': 5,
    'longBreak': 15,
    'sessionsBeforeLong': 4,
  };

  // Guardar configuración
  static Future<void> saveSettings({
    required int pomodoro,
    required int shortBreak,
    required int longBreak,
    required int sessionsBeforeLong,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pomodoro', pomodoro);
    await prefs.setInt('shortBreak', shortBreak);
    await prefs.setInt('longBreak', longBreak);
    await prefs.setInt('sessionsBeforeLong', sessionsBeforeLong);
  }

  // Cargar configuración
  static Future<Map<String, int>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'pomodoro': prefs.getInt('pomodoro') ?? _defaultSettings['pomodoro']!,
      'shortBreak': prefs.getInt('shortBreak') ?? _defaultSettings['shortBreak']!,
      'longBreak': prefs.getInt('longBreak') ?? _defaultSettings['longBreak']!,
      'sessionsBeforeLong':
          prefs.getInt('sessionsBeforeLong') ?? _defaultSettings['sessionsBeforeLong']!,
    };
  }

  // Meta diaria
  static Future<void> saveDailyGoal(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', value);
  }

  static Future<int> loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('dailyGoal') ?? 8;
  }

  // === ESTADÍSTICAS SEMANALES ===

  // Incrementar el contador de hoy
  static Future<void> incrementTodayStat() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekday = (now.weekday + 6) % 7; // convierte 1-7 (lun-dom) a 0-6
    final key = 'stat_$weekday';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  // Obtener todos los stats de la semana (lunes a domingo)
  static Future<List<int>> loadWeeklyStats() async {
    final prefs = await SharedPreferences.getInstance();
    return List.generate(7, (i) => prefs.getInt('stat_$i') ?? 0);
  }

  // Reiniciar todos los días (opcional si quieres resetear manualmente)
  static Future<void> resetWeeklyStats() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 7; i++) {
      await prefs.setInt('stat_$i', 0);
    }
  }

  // Obtener instancia (por compatibilidad si se necesita raw access)
  static Future<SharedPreferences> getRawPrefs() async {
    return SharedPreferences.getInstance();
  }
}
