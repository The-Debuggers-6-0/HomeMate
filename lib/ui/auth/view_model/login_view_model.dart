import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';

/// ViewModel per la schermata di login.
/// Gestisce lo stato di caricamento, errori e le azioni di login.
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  LoginViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // --- Getters pubblici ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Effettua il login con email e password.
  /// Restituisce true se il login ha successo.
  Future<bool> loginWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Per favore, compila tutti i campi.';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      await _authRepository.login(email, password);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _mapAuthError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Effettua il login con Google.
  /// Restituisce true se il login ha successo.
  Future<bool> loginWithGoogle() async {
    _setLoading(true);

    try {
      await _authRepository.loginWithGoogle();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Errore Google Sign-In.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Pulisce il messaggio di errore.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapAuthError(dynamic e) {
    if (e.toString().contains('user-not-found')) {
      return 'Nessun utente trovato.';
    } else if (e.toString().contains('wrong-password')) {
      return 'Password errata.';
    }
    return 'Errore durante il login.';
  }
}
