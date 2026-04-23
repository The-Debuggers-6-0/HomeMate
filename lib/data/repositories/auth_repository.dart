import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

/// Repository che astrae le operazioni di autenticazione per i ViewModel.
/// Riceve AuthService e UserService come dipendenze.
class AuthRepository {
  final AuthService _authService;
  final UserService _userService;

  AuthRepository({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService;

  /// Utente Firebase corrente.
  User? get currentFirebaseUser => _authService.currentUser;

  /// Stream dei cambiamenti di autenticazione.
  Stream<User?> authStateChanges() => _authService.authStateChanges();

  /// Login con email e password.
  Future<UserCredential> login(String email, String password) {
    return _authService.signInWithEmail(email, password);
  }

  /// Login con Google. Aggiorna anche i dati su Firestore.
  Future<UserCredential> loginWithGoogle() async {
    final userCredential = await _authService.signInWithGoogle();
    final user = userCredential.user!;

    await _userService.updateLastLogin(
      user.uid,
      user.email ?? '',
      user.displayName ?? 'Utente Google',
    );

    return userCredential;
  }

  /// Registrazione con email e password.
  /// Crea l'utente su Firebase Auth, invia verifica, e crea il documento Firestore.
  Future<void> register(String email, String password) async {
    final userCredential =
        await _authService.registerWithEmail(email, password);

    await _authService.sendEmailVerification();

    await _userService.createUser(
      uid: userCredential.user!.uid,
      email: email,
    );
  }

  /// Invia email di reset password.
  Future<void> resetPassword(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  /// Ricarica l'utente corrente per verificare lo stato emailVerified.
  Future<void> reloadCurrentUser() {
    return _authService.reloadCurrentUser();
  }

  /// Invia nuovamente l'email di verifica.
  Future<void> resendVerificationEmail() {
    return _authService.sendEmailVerification();
  }

  /// Logout.
  Future<void> logout() => _authService.signOut();
}
