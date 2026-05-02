import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

/// ViewModel che fornisce metodi di utilità per l'autenticazione
/// e la determinazione della prossima schermata da mostrare.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  /// Utente Firebase corrente.
  User? get currentFirebaseUser => _authRepository.currentFirebaseUser;

  /// Determina la prossima schermata in base allo stato dell'utente.
  /// Restituisce: 'login', 'verifyEmail', 'setupProfile', 'addHouse', 'home'
  Future<String> getNextRoute() async {
    final user = _authRepository.currentFirebaseUser;

    if (user == null) {
      return 'login';
    }

    // Ricarica per avere emailVerified aggiornato
    await _authRepository.reloadCurrentUser();
    final refreshedUser = _authRepository.currentFirebaseUser;

    if (refreshedUser == null) {
      return 'login';
    }

    if (!refreshedUser.emailVerified) {
      return 'verifyEmail';
    }

    // Carica il profilo da Firestore (singola lettura)
    try {
      final profile =
          await _userRepository.getUserProfile(refreshedUser.uid);

      if (profile == null ||
          !profile.profileCompleted ||
          profile.name.trim().isEmpty) {
        return 'setupProfile';
      }

      if (profile.homeId.isEmpty) {
        return 'addHouse';
      }

      return 'home';
    } catch (e) {
      return 'setupProfile';
    }
  }

  /// Logout.
  Future<void> logout() => _authRepository.logout();
}
