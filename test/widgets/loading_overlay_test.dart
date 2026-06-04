import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homemate/ui/core/ui/loading_overlay.dart';

void main() {
  group('LoadingOverlay Widget Test', () {
    testWidgets('mostra il CircularProgressIndicator con il colore corretto', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingOverlay(color: customColor),
        ),
      );

      // Verifica presenza indicatore
      final progressIndicatorFinder = find.byType(CircularProgressIndicator);
      expect(progressIndicatorFinder, findsOneWidget);

      // Verifica che il colore sia quello passato (evita falsi positivi su widget hardcoded)
      final CircularProgressIndicator widget = tester.widget(progressIndicatorFinder);
      expect(widget.color, customColor);
    });
  });
}
