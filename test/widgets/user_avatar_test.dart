import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homemate/ui/core/ui/user_avatar.dart';
import 'package:homemate/domain/models/app_user.dart';

void main() {
  group('UserAvatar Widget Test', () {
    const user = AppUser(uid: '123', email: 'mario@test.com', name: 'Mario Rossi');

    testWidgets('mostra le iniziali quando photoUrl è nullo', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(user: user, photoUrl: null),
          ),
        ),
      );

      // Verifica che le iniziali 'M' siano visibili
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('NON mostra le iniziali quando photoUrl è presente (base64)', (WidgetTester tester) async {
      // Una stringa base64 valida minima per un pixel trasparente
      const String base64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(user: user, photoUrl: base64Image),
          ),
        ),
      );
      expect(find.text('M'), findsNothing);
    });
  });
}
