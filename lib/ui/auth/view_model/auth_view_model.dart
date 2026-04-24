import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/app_user.dart';

/// Enum che rappresenta lo stato globale di autenticazione dell'app.
enum AuthStatus {
  unknown,
  unauthenticated,
  emailNotVerified,
  profileIncomplete,
  noHouse,
  authenticated,
}

/// ViewModel globale che gestisce lo stato di autenticazione dell'app.
/// Ascolta authStateChanges() e determina quale schermata mostrare.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthStatus _status = AuthStatus.unknown;
  User? _firebaseUser;
  AppUser? _userProfile;
  bool _isLoading = true;
  StreamSubscription<User?>? _authSubscription;

  AuthViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository {
    _init();
  }

  // --- Getters pubblici (stato esposto alla UI) ---
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  AppUser? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  void _init() {
    _authSubscription = _authRepository.authStateChanges().listen(
      (user) => _onAuthStateChanged(user),
    );
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _isLoading = true;
    notifyListeners();

    if (user == null) {
      _firebaseUser = null;
      _userProfile = null;
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _firebaseUser = user;

    if (!user.emailVerified) {
      _status = AuthStatus.emailNotVerified;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Carica il profilo utente da Firestore
    await _loadUserProfile(user.uid);

    _isLoading = false;
    notifyListeners();
  }
  

  Future<void> _loadUserProfile(String uid) async {
    try {
      _userProfile = await _userRepository.getUserProfile(uid);

      if (_userProfile == null || !_userProfile!.profileCompleted) {
        _status = AuthStatus.profileIncomplete;
      } else if (_userProfile!.homeId.isEmpty) {
        _status = AuthStatus.noHouse;
      } else {
        _status = AuthStatus.authenticated;
      }
    } catch (e) {
      _status = AuthStatus.profileIncomplete;
    }
  }

  /// Forza il ricaricamento dello stato (es. dopo aver completato il profilo).
  Future<void> refreshAuthState() async {
    final user = _authRepository.currentFirebaseUser;
    if (user != null) {
      await _authRepository.reloadCurrentUser();
      await _onAuthStateChanged(_authRepository.currentFirebaseUser);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
