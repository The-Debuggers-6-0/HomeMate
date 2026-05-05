import '../../domain/models/house.dart';
import '../services/house_service.dart';
import '../services/user_service.dart';

/// Repository che astrae l'accesso ai dati delle case per i ViewModel.
class HouseRepository {
  final HouseService _houseService;
  final UserService _userService;

  HouseRepository({
    required HouseService houseService,
    required UserService userService,
  })  : _houseService = houseService,
        _userService = userService;

  /// Crea una nuova casa e associa l'utente in modo atomico.
  /// Restituisce il codice della casa creata.
  Future<String> createHouse({
    required String uid,
    required String displayName,
    String? customName,
  }) async {
    final code = _houseService.generateHouseCode();

    await _houseService.createHouseWithAdmin(
      code: code,
      adminUid: uid,
      nome: (customName != null && customName.trim().isNotEmpty)
          ? customName.trim()
          : 'Casa di $displayName',
    );

    return code;
  }

  /// Unisce l'utente a una casa esistente in modo atomico.
  /// Restituisce true se la casa esiste e l'utente è stato aggiunto.
  Future<bool> joinHouse({
    required String uid,
    required String code,
  }) async {
    return await _houseService.joinHouseTransaction(uid: uid, code: code);
  }

  /// Abbandona una casa in modo atomico.
  /// Rimuove l'utente dai membri della casa e cancella l'homeId dal suo profilo.
  Future<void> leaveHouse({
    required String uid,
    required String code,
  }) async {
    await _houseService.leaveHouseTransaction(uid: uid, code: code);
  }

  /// Aggiorna il nome della casa.
  Future<void> updateHouseName({
    required String code,
    required String newName,
  }) async {
    await _houseService.updateHouseName(code, newName);
  }

  /// Ottiene una casa dato il suo codice.
  Future<House?> getHouse(String code) {
    return _houseService.getHouse(code);
  }

  /// Ottiene una casa in tempo reale dato il suo codice.
  Stream<House?> getHouseStream(String code) {
    return _houseService.getHouseStream(code);
  }
}
