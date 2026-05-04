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

      // Ogni volta che lo stato Auth cambia, puliamo tutto!
      _cancelAllSubscriptions();

      if (user != null) {
        _startListeningToProfile(user.uid);
      } else {
        _isLoading = false;
        _currentHouse = null;
        _roommates = [];
        notifyListeners();
      }
    });
  }

  void _startListeningToProfile(String uid) {
    // 1. Evita di creare sottoscrizioni multiple (doppioni)
    if (_profileSubscription != null) return;

    // Prima di tutto, mettiamoci in modalità "caricamento" finché non abbiamo i dati
    _isLoading = true;
    notifyListeners();

    // 2. Ascolta il profilo dell'utente per ottenere l'ID della casa
    _profileSubscription = _userRepository.getUserProfileStream(uid).listen((profile) {
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
      notifyListeners();
    });
  }


  void _startListeningToHouse(String homeId) {
    _houseSubscription?.cancel();
    _roommatesSubscription?.cancel();

    _houseSubscription = _houseRepository.getHouseStream(homeId).listen((house) {
      _currentHouse = house;
      _isLoading = false;
      notifyListeners();

      _roommatesSubscription?.cancel();
      if (house != null && house.membri.isNotEmpty) {
        _roommatesSubscription = _userRepository.getRoommatesStream(house.membri).listen((users) {
          _roommates = _roommates = users;
          notifyListeners();
        });
      } else {
        _roommates = [];
        notifyListeners();
      }
    });
  }

  void _cancelAllSubscriptions() {
    _profileSubscription?.cancel();
    _profileSubscription = null; // Fondamentale per sbloccare l'if successivo
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
    notifyListeners();

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
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _houseSubscription?.cancel();
    _roommatesSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}