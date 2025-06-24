import 'package:flutter/material.dart';
import '../utils/preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(5, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await Preferences.loadSettings();
    final goal = await Preferences.loadDailyGoal();
    setState(() {
      _controllers[0].text = settings['pomodoro'].toString();
      _controllers[1].text = settings['shortBreak'].toString();
      _controllers[2].text = settings['longBreak'].toString();
      _controllers[3].text = settings['sessionsBeforeLong'].toString();
      _controllers[4].text = goal.toString();
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      await Preferences.saveSettings(
        pomodoro: int.parse(_controllers[0].text),
        shortBreak: int.parse(_controllers[1].text),
        longBreak: int.parse(_controllers[2].text),
        sessionsBeforeLong: int.parse(_controllers[3].text),
      );
      await Preferences.saveDailyGoal(int.parse(_controllers[4].text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Configuración guardada 🎉")),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pastelGreen = Color(0xFFCAF7E3);
    const pastelBackground = Color(0xFFFFF5E4);

    return Scaffold(
      backgroundColor: pastelBackground,
      appBar: AppBar(
        title: Text("Configuración", style: GoogleFonts.fredoka()),
        backgroundColor: pastelGreen,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ..._buildFields(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text("Guardar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelGreen,
                  foregroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields() {
    final labels = [
      "Duración Pomodoro (min)",
      "Descanso corto (min)",
      "Descanso largo (min)",
      "Pomodoros antes de largo",
      "Meta diaria (Pomodoros)"
    ];

    return List.generate(labels.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: _controllers[i],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: labels[i],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: GoogleFonts.fredoka(),
          validator: (value) {
            if (value == null || value.isEmpty || int.tryParse(value) == null) {
              return "Introduce un número válido";
            }
            return null;
          },
        ),
      );
    });
  }
}
