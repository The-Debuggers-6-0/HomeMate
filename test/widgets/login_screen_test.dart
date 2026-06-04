import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homemate/ui/auth/widgets/login_screen.dart';
import 'package:homemate/ui/auth/view_model/login_view_model.dart';
import 'package:homemate/ui/auth/view_model/auth_view_model.dart';
import 'package:homemate/ui/core/ui/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class FakeAuthViewModel extends ChangeNotifier implements AuthViewModel {
  @override
  auth.User? get currentFirebaseUser => null; 
  @override
  Future<String> getNextRoute() async => '/';
  @override
  void debugSignOut() {}
  @override
  Future<void> logout() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLoginViewModel extends ChangeNotifier implements LoginViewModel {
  bool _isLoading = false;
  @override
  bool get isLoading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  @override
  String? get errorMessage => null;
  @override
  Future<bool> login(String email, String password) async => true;
  @override
  Future<bool> loginWithEmail(String email, String password) async => true;
  @override
  Future<bool> loginWithGoogle() async => true;
  @override
  void clearError() {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('LoginScreen Widget Test', () {
    late FakeLoginViewModel fakeLoginViewModel;
    late FakeAuthViewModel fakeAuthViewModel;

    setUp(() {
      fakeLoginViewModel = FakeLoginViewModel();
      fakeAuthViewModel = FakeAuthViewModel();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthViewModel>.value(value: fakeAuthViewModel),
            ChangeNotifierProvider<LoginViewModel>.value(value: fakeLoginViewModel),
          ],
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('mostra indicatore di caricamento nel bottone quando isLoading è true', (WidgetTester tester) async {
      fakeLoginViewModel.setLoading(true);
      await tester.pumpWidget(createWidgetUnderTest());
      // Aspettiamo che termini il controllo auth iniziale (_isCheckingAuth)
      await tester.pumpAndSettle();
      
      // Cerchiamo il ButtonLoadingIndicator specifico dentro il bottone
      expect(find.byType(ButtonLoadingIndicator), findsOneWidget);
    });

    testWidgets('NON mostra caricamento e non mostra LoadingOverlay dopo il boot iniziale', (WidgetTester tester) async {
      fakeLoginViewModel.setLoading(false);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(LoadingOverlay), findsNothing);
    });
  });
}
