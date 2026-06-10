import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/house.dart';
import '../../../data/repositories/house_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ViewModel per la schermata Profilo.
/// Ascolta lo stream dei dati utente in tempo reale.
class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final HouseRepository _houseRepository;

  AppUser? _userProfile;
  House? _currentHouse;
  List<AppUser> _roommates = [];

  bool _isLoading = true;
  StreamSubscription<AppUser?>? _profileSubscription;
  StreamSubscription<House?>? _houseSubscription;
  StreamSubscription<List<AppUser>>? _roommatesSubscription;

  StreamSubscription<User?>? _authSubscription;
  bool _disposed = false;

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  /*
  ProfileViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository {
    _init();
  }*/

  ProfileViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required HouseRepository houseRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _houseRepository = houseRepository {
    

    _authSubscription = _authRepository.authStateChanges().listen((user) {
      if (_disposed) return;

      if (user != null) {
        // Utente autenticato: avvia l'ascolto dei dati
        _startListeningToProfile(user.uid);
      } else {
        // Utente disconnesso o eliminato: cancella le iscrizioni
        _cancelAllSubscriptions();
        _userProfile = null;
        _currentHouse = null;
        _roommates = [];
        _safeNotify();
      }
    });
  }

  // --- Getters pubblici ---
  AppUser? get userProfile => _userProfile;
  House? get currentHouse => _currentHouse;
  List<AppUser> get roommates => _roommates;

  bool get isLoading => _isLoading;
  String get displayName => _userProfile?.name ?? 'Utente';
  String get fullName =>
      '${_userProfile?.name ?? ''} ${_userProfile?.surname ?? ''}'.trim();
  String get bio => _userProfile?.bio ?? _userProfile?.email ?? '';

  void _cancelAllSubscriptions() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    _houseSubscription?.cancel();
    _houseSubscription = null;
    _roommatesSubscription?.cancel();
    _roommatesSubscription = null;
  }

  /*
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
  }*/

  /// Avvia l'ascolto in tempo reale del profilo utente da Firestore.
  void _startListeningToProfile(String uid) {
    // Se stiamo già ascoltando, non facciamo nulla per evitare doppioni
    if (_profileSubscription != null) return;

    _isLoading = true;
    _safeNotify();

    _profileSubscription = _userRepository
        .getUserProfileStream(uid)
        .listen((profile) {
          if (_disposed) return;

          final previousHomeId = _userProfile?.homeId;
          _userProfile = profile;
          
          // Se la casa è cambiata o appena arrivata, aggiorniamo l'ascolto
          if (profile != null && profile.homeId.isNotEmpty && profile.homeId != previousHomeId) {
            _startListeningToHouse(profile.homeId);
          } else if (profile?.homeId == null || profile!.homeId.isEmpty) {
            _houseSubscription?.cancel();
            _roommatesSubscription?.cancel();
            _currentHouse = null;
            _roommates = [];
          }

          _isLoading = false;
          _safeNotify();
        });
  }

  void _startListeningToHouse(String homeId) {
    _houseSubscription?.cancel();
    _roommatesSubscription?.cancel();

    _houseSubscription = _houseRepository.getHouseStream(homeId).listen((house) {
      if (_disposed) return;

      _currentHouse = house;
      _safeNotify();

      // Quando riceviamo la casa (o si aggiorna), ascoltiamo tutti i suoi membri
      _roommatesSubscription?.cancel();
      if (house != null && house.membri.isNotEmpty) {
        _roommatesSubscription = _userRepository.getRoommatesStream(house.membri).listen((users) {
          if (_disposed) return;

          _roommates = users;
          _safeNotify();
        });
      } else {
        _roommates = [];
        _safeNotify();
      }
    });
  }



  Future<void> reloadProfile() async {
    final user = _authRepository.currentFirebaseUser;
    if (user != null) {
      _isLoading = true;
      _safeNotify();

      // Mettiamo un try/catch per sicurezza
      try {

        final updatedProfile = await _userRepository.getUserProfile(user.uid);
        _userProfile = updatedProfile;
      } catch (e) {
        debugPrint("Errore nel ricaricare il profilo: $e");
      } finally {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  Future<bool> leaveHouse() async {
    final uid = _userProfile?.uid;
    final code = _currentHouse?.id;
    
    if (uid == null || code == null) return false;

    _isLoading = true;
    _safeNotify();

    try {
      await _houseRepository.leaveHouse(uid: uid, code: code);
      _houseSubscription?.cancel();
      _roommatesSubscription?.cancel();
      _currentHouse = null;
      _roommates = [];
      return true;
    } catch (e) {
      debugPrint("Errore durante l'abbandono della casa: $e");
      return false;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> updateHouseName(String newName) async {
    final code = _currentHouse?.id;
    if (code == null || newName.trim().isEmpty) return false;

    try {
      await _houseRepository.updateHouseName(code: code, newName: newName.trim());
      return true;
    } catch (e) {
      debugPrint("Errore nell'aggiornamento del nome: $e");
      return false;
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
      _safeNotify();

      try {
        // 1. Cancella ogni iscrizione attiva al database
        _cancelAllSubscriptions();

        // 2. Eliminiamo i dati da Firestore
        await _userRepository.deleteProfile(user.uid);

        // 3. Eliminiamo l'account da Auth
        await _authRepository.deleteAccount();

        // 4. Puliamo il ViewModel
        _userProfile = null;
        
        return true; // Restituisce true se ha distrutto tutto con successo

      } catch (e) {
        debugPrint("Errore: $e");

        // In caso di eccezione forziamo il logout
        await logout();

        rethrow;
        
      } finally {
        _isLoading = false;
        _safeNotify();
      }
    }
    return false;
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    _cancelAllSubscriptions();
    super.dispose();
  }
}
