import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/timer_provider.dart';
import 'utils/notifications.dart'; // <- Asegúrate de este import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar notificaciones
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: const FocusFlowApp(),
    ),
  );
}
