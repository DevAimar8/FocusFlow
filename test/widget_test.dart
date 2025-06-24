import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focusflow/app.dart'; // ← importa app.dart, no main.dart

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FocusFlowApp());

    // Esta prueba no aplica a FocusFlow, puedes comentarla o reemplazarla.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // No hay botón + en nuestra app, esta línea fallará.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
