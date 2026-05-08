import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/house_repository.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/house.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoinquiliniViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final HouseRepository _houseRepository;
  

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

  CoinquiliniViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required HouseRepository houseRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       _houseRepository = houseRepository {
    _init();
  }

  House? get currentHouse => _currentHouse;
  List<AppUser> get roommates => _roommates;
  bool get isLoading => _isLoading;

  void _init() {
    // Invece di controllare una volta sola, usiamo il listener del repository
    // per sapere SEMPRE quando l'utente entra o esce (Login/Logout)
    _authSubscription = _authRepository.authStateChanges().listen((user) {
      if (_disposed) return;

      // Ogni volta che lo stato Auth cambia, puliamo tutto!
      _cancelAllSubscriptions();

      if (user != null) {
        _startListeningToProfile(user.uid);
      } else {
        _isLoading = false;
        _currentHouse = null;
        _roommates = [];
        _safeNotify();
      }
    });
  }

  void _startListeningToProfile(String uid) {
    // 1. Evita di creare sottoscrizioni multiple (doppioni)
    if (_profileSubscription != null) return;

    // Prima di tutto, mettiamoci in modalità "caricamento" finché non abbiamo i dati
    _isLoading = true;
    _safeNotify();

    // 2. Ascolta il profilo dell'utente per ottenere l'ID della casa
    _profileSubscription = _userRepository.getUserProfileStream(uid).listen((profile) {
      if (_disposed) return;

      final previousHomeId = _currentHouse?.id;

    // 3. Se l'ID della casa è cambiato, aggiorna l'ascolto della casa
      if (profile != null && profile.homeId.isNotEmpty) {
        // Se la casa è nuova o cambiata, ascoltiamo i nuovi dati
        if (profile.homeId != previousHomeId) {
          _startListeningToHouse(profile.homeId);
        }
      } else {
        // L'utente non ha una casa: stacchiamo i sensori specifici della casa
        _houseSubscription?.cancel();
        _houseSubscription = null;
        _roommatesSubscription?.cancel();
        _roommatesSubscription = null;
        _currentHouse = null;
        _roommates = [];
      }

      // In ogni caso, abbiamo finito di caricare i dati del profilo
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
      _isLoading = false;
      _safeNotify();

      _roommatesSubscription?.cancel();

      if (house != null) {
        // Ascolta i coinquilini
        if (house.membri.isNotEmpty) {
          _roommatesSubscription = _userRepository.getRoommatesStream(house.membri).listen((users) {
            if (_disposed) return;
            _roommates = users;
            _safeNotify();
          });
        }
      } else {
        _roommates = [];
        _safeNotify();
      }
    });
  }

  void _cancelAllSubscriptions() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    _houseSubscription?.cancel();
    _houseSubscription = null;
    _roommatesSubscription?.cancel();
    _roommatesSubscription = null;
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

  Future<bool> leaveHouse() async {
    final user = _authRepository.currentFirebaseUser;
    final code = _currentHouse?.id;
    
    if (user == null || code == null) return false;

    _isLoading = true;
    _safeNotify();

    try {
      await _houseRepository.leaveHouse(uid: user.uid, code: code);
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

  @override
  void dispose() {
    _disposed = true;
    _profileSubscription?.cancel();
    _houseSubscription?.cancel();
    _roommatesSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}