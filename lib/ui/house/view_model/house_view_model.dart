import 'package:flutter/foundation.dart';
import '../../../data/repositories/house_repository.dart';
import '../../../data/repositories/auth_repository.dart';

/// ViewModel per la schermata di creazione/unione casa.
class HouseViewModel extends ChangeNotifier {
  final HouseRepository _houseRepository;
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _createdCode;
  bool _joinedSuccessfully = false;

  HouseViewModel({
    required HouseRepository houseRepository,
    required AuthRepository authRepository,
  })  : _houseRepository = houseRepository,
        _authRepository = authRepository;

  // --- Getters pubblici ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get createdCode => _createdCode;
  bool get joinedSuccessfully => _joinedSuccessfully;

  /// Crea una nuova casa.
  /// Restituisce true se la creazione ha successo.
  Future<bool> createHouse() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _authRepository.currentFirebaseUser;
      if (user == null) return false;

      _createdCode = await _houseRepository.createHouse(
        uid: user.uid,
        displayName: user.displayName ?? 'Nuovo Utente',
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante la creazione: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Unisciti a una casa esistente tramite codice.
  /// Restituisce true se l'operazione ha successo.
  Future<bool> joinHouse(String code) async {
    final trimmedCode = code.trim().toUpperCase();

    if (trimmedCode.isEmpty) {
      _errorMessage = 'Inserisci un codice valido.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _authRepository.currentFirebaseUser;
      if (user == null) return false;

      final success = await _houseRepository.joinHouse(
        uid: user.uid,
        code: trimmedCode,
      );

      if (success) {
        _joinedSuccessfully = true;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Codice casa non trovato.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Errore: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
