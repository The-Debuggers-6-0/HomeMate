import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';

/// ViewModel per la schermata di registrazione.
class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _registrationSuccess = false;

  RegisterViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // --- Getters pubblici ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get registrationSuccess => _registrationSuccess;

  /// Effettua la registrazione con email e password.
  /// Restituisce true se la registrazione ha successo.
  Future<bool> register(
      String email, String password, String confirmPassword) async {
    // Validazione
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = 'Per favore, compila tutti i campi.';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Le password non coincidono.';
      notifyListeners();
      return false;
    }

    if (password.length < 8) {
      _errorMessage = 'La password deve avere almeno 8 caratteri.';
      notifyListeners();
      return false;
    }

    _setLoading(true);

    try {
      await _authRepository.register(email, password);
      _errorMessage = null;
      _registrationSuccess = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _mapRegistrationError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapRegistrationError(dynamic e) {
    if (e.toString().contains('weak-password')) {
      return 'La password è troppo debole.';
    } else if (e.toString().contains('email-already-in-use')) {
      return 'Email già in uso.';
    }
    return 'Errore durante la registrazione.';
  }
}
