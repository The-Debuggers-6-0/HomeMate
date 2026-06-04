import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homemate/ui/core/ui/custom_bottom_nav_bar.dart';

void main() {
  group('CustomBottomNavBar Widget Test', () {
    testWidgets('restituisce l\'indice corretto per ogni tab e ignora il tap sul tab attivo', (WidgetTester tester) async {
      int? tappedIndex;
      int currentIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack( // Necessario perché CustomBottomNavBar restituisce un Positioned
              children: [
                CustomBottomNavBar(
                  currentIndex: currentIndex,
                  onTap: (index) => tappedIndex = index,
                ),
              ],
            ),
          ),
        ),
      );

      // 1. Test tap su Finanze (Indice 1)
      await tester.tap(find.byIcon(Icons.account_balance_wallet));
      await tester.pump();
      expect(tappedIndex, 1);

      // 2. Test tap su Coinquilini (Indice 3)
      await tester.tap(find.byIcon(Icons.people));
      await tester.pump();
      expect(tappedIndex, 3);

      // 3. Test tap su Home (che è l'attuale selezionato)
      tappedIndex = null; // reset
      await tester.tap(find.byIcon(Icons.home_filled));
      await tester.pump();
      expect(tappedIndex, isNull, reason: 'Non dovrebbe chiamare onTap se l\'indice è lo stesso dell\'attuale');
    });
  });
}
