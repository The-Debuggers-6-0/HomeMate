import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';

/// ViewModel per la schermata di recupero password.
class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  bool _isSent = false;
  String? _errorMessage;

  ForgotPasswordViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // --- Getters pubblici ---
  bool get isLoading => _isLoading;
  bool get isSent => _isSent;
  String? get errorMessage => _errorMessage;

  /// Invia il link di reset password.
  /// Restituisce true se l'invio ha successo (o simula il successo per sicurezza).
  Future<bool> resetPassword(String email) async {
    if (email.isEmpty) {
      _errorMessage = 'Per favore, inserisci la tua email.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(email);
      _isSent = true;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      // Simuliamo il successo per motivi di sicurezza (evita enumerazione utenti)
      if (e.toString().contains('user-not-found')) {
        _isSent = true;
        notifyListeners();
        return true;
      } else if (e.toString().contains('invalid-email')) {
        _errorMessage = "Il formato dell'email non è valido.";
      } else {
        _errorMessage = "Errore durante l'invio.";
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resetta lo stato per un nuovo tentativo.
  void reset() {
    _isSent = false;
    _errorMessage = null;
    notifyListeners();
  }
}
