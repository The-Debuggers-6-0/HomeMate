import 'package:flutter/foundation.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/auth_repository.dart';

/// ViewModel per la schermata di configurazione profilo.
class SetupProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _profileSaved = false;

  SetupProfileViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  })  : _userRepository = userRepository,
        _authRepository = authRepository;

  // --- Getters pubblici ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get profileSaved => _profileSaved;

  /// Salva il profilo utente su Firestore.
  /// Restituisce true se il salvataggio ha successo.
  Future<bool> saveProfile({
    required String name,
    required String surname,
    String bio = '',
  }) async {
    if (name.isEmpty || surname.isEmpty) {
      _errorMessage = 'Nome e Cognome sono obbligatori.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _authRepository.currentFirebaseUser;
      if (user == null) {
        _errorMessage = 'Nessun utente autenticato.';
        notifyListeners();
        return false;
      }

      await _userRepository.saveProfile(
        uid: user.uid,
        name: name,
        surname: surname,
        bio: bio,
      );

      _profileSaved = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Errore durante il salvataggio: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
