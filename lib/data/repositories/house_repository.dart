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

  /// Crea una nuova casa e associa l'utente.
  /// Restituisce il codice della casa creata.
  Future<String> createHouse({
    required String uid,
    required String displayName,
    String? customName,
  }) async {
    final code = _houseService.generateHouseCode();

    await _houseService.createHouse(
      code: code,
      adminUid: uid,
      nome: (customName != null && customName.trim().isNotEmpty) ? customName.trim() : 'Casa di $displayName',
    );

    await _userService.updateUser(uid, {'homeId': code});

    return code;
  }

  /// Unisce l'utente a una casa esistente.
  /// Restituisce true se la casa esiste e l'utente è stato aggiunto.
  Future<bool> joinHouse({
    required String uid,
    required String code,
  }) async {
    final house = await _houseService.getHouse(code);
    if (house == null) return false;

    await _houseService.addMember(code, uid);
    await _userService.updateUser(uid, {'homeId': code});

    return true;
  }

  /// Abbandona una casa.
  /// Rimuove l'utente dai membri della casa e cancella l'homeId dal suo profilo.
  Future<void> leaveHouse({
    required String uid,
    required String code,
  }) async {
    await _houseService.removeMember(code, uid);
    await _userService.updateUser(uid, {'homeId': ''});
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
