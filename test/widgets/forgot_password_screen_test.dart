import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homemate/ui/auth/widgets/forgot_password_screen.dart';
import 'package:homemate/ui/auth/view_model/forgot_password_view_model.dart';

class FakeForgotPasswordViewModel extends ChangeNotifier implements ForgotPasswordViewModel {
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSent = false;

  @override
  bool get isLoading => _isLoading;

  @override
  bool get isSent => _isSent;

  @override
  String? get errorMessage => _errorMessage;

  @override
  Future<bool> resetPassword(String email) async {
    if (email.isEmpty) {
      _errorMessage = "Email obbligatoria";
      notifyListeners();
      return false;
    }
    _isSent = true;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  @override
  void reset() {
    _isSent = false;
    _errorMessage = null;
    notifyListeners();
  }
}

void main() {
  group('ForgotPasswordScreen Widget Test', () {
    testWidgets('mostra errore di validazione solo se il campo è vuoto', (WidgetTester tester) async {
      final fakeViewModel = FakeForgotPasswordViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ForgotPasswordViewModel>.value(
            value: fakeViewModel,
            child: const ForgotPasswordScreen(),
          ),
        ),
      );

      // 1. Inizialmente nessun errore
      expect(find.text('Email obbligatoria'), findsNothing);

      // 2. Tap senza inserire nulla -> Errore
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.text('Email obbligatoria'), findsOneWidget);
    });

    testWidgets('non mostra errore se l\'email viene inserita correttamente', (WidgetTester tester) async {
      final fakeViewModel = FakeForgotPasswordViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ForgotPasswordViewModel>.value(
            value: fakeViewModel,
            child: const ForgotPasswordScreen(),
          ),
        ),
      );

      // Inseriamo l'email (ora che abbiamo corretto il TextField col controller)
      await tester.enterText(find.byType(TextField), 'test@test.it');
      
      // Tap sul bottone
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Non deve esserci il messaggio di errore
      expect(find.text('Email obbligatoria'), findsNothing);
    });
  });
}
