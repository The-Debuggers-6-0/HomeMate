import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/app_user.dart';

/// ViewModel per la schermata Profilo.
/// Ascolta lo stream dei dati utente in tempo reale.
class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  AppUser? _userProfile;
  bool _isLoading = true;
  StreamSubscription<AppUser?>? _profileSubscription;

  ProfileViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  })  : _userRepository = userRepository,
        _authRepository = authRepository {
    _init();
  }

  // --- Getters pubblici ---
  AppUser? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get displayName => _userProfile?.name ?? 'Utente';
  String get fullName =>
      '${_userProfile?.name ?? ''} ${_userProfile?.surname ?? ''}'.trim();
  String get bio => _userProfile?.bio ?? _userProfile?.email ?? '';

  void _init() {
    final user = _authRepository.currentFirebaseUser;
    if (user != null) {
      _profileSubscription =
          _userRepository.getUserProfileStream(user.uid).listen((profile) {
        _userProfile = profile;
        _isLoading = false;
        notifyListeners();
      });
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Esegue il logout.
  Future<void> logout() async {
    await _authRepository.logout();
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
