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
  }) : _userRepository = userRepository,
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

  /// Inizializza il ViewModel.
  void _init() {
    final user = _authRepository.currentFirebaseUser;
    if (user != null) {
      _profileSubscription = _userRepository
          .getUserProfileStream(user.uid)
          .listen((profile) {
            _userProfile = profile;
            _isLoading = false;
            notifyListeners();
          });
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  //AGGIUNTO RECENTE!
  // Nel tuo ProfileViewModel:
  Future<void> reloadProfile() async {
    final user = _authRepository.currentFirebaseUser;
    if (user != null) {
      _isLoading = true;
      notifyListeners();

      // Mettiamo un try/catch per sicurezza
      try {
        // Usa il tuo metodo che legge una sola volta l'utente
        // (Es. _userRepository.getUser(user.uid) o simile)
        final updatedProfile = await _userRepository.getUserProfile(user.uid);
        _userProfile = updatedProfile;
      } catch (e) {
        debugPrint("Errore nel ricaricare il profilo: $e");
      } finally {
        _isLoading = false;
        notifyListeners(); // Questo farà riapparire la schermata con i nuovi dati!
      }
    }
  }

  /// Esegue il logout.
  Future<void> logout() async {
    await _authRepository.logout();
  }

  /// Elimina definitivamente l'account e tutti i dati associati.
  Future<bool> deleteAccount() async {
    final user = _authRepository.currentFirebaseUser;
    
    if (user != null) {
      _isLoading = true;
      notifyListeners();

      try {
        // 1. STACCHIAMO LA CORRENTE: cancella ogni ascolto al database
        _profileSubscription?.cancel();
        _profileSubscription = null;

        // 2. Eliminiamo i dati da Firestore
        await _userRepository.deleteProfile(user.uid);

        // 3. Eliminiamo l'account da Auth
        await _authRepository.deleteAccount();

        // 4. Puliamo il ViewModel
        _userProfile = null;
        
        return true; // Restituisce true se ha distrutto tutto con successo

      } catch (e) {
        debugPrint("Errore: $e");
        // Se Firebase si lamenta (es. login troppo vecchio), si ferma qui
        return false; 
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
    return false;
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
