import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../config/app_config.dart';

/// Service che gestisce tutte le operazioni di autenticazione Firebase.
/// Questo è l'unico punto di contatto con FirebaseAuth.
class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Utente Firebase corrente.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream dei cambiamenti di stato di autenticazione.
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  /// Login con email e password.
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registrazione con email e password.
  Future<UserCredential> registerWithEmail(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Login con Google.
  Future<UserCredential> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleServerClientId,
    );

    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential =
        GoogleAuthProvider.credential(idToken: googleAuth.idToken);

    return _firebaseAuth.signInWithCredential(credential);
  }

  /// Invia email di verifica all'utente corrente.
  Future<void> sendEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  /// Invia email di reset password.
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Ricarica i dati dell'utente corrente (per controllare emailVerified).
  Future<void> reloadCurrentUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  /// Logout.
  Future<void> signOut() => _firebaseAuth.signOut();
}
