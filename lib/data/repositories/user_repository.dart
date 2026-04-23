import '../../domain/models/app_user.dart';
import '../services/user_service.dart';
import 'dart:io';

/// Repository che astrae l'accesso ai dati utente per i ViewModel.
class UserRepository {
  final UserService _userService;

  UserRepository({required UserService userService})
      : _userService = userService;

  /// Ottiene il profilo utente come singola lettura.
  Future<AppUser?> getUserProfile(String uid) {
    return _userService.getUser(uid);
  }

  /// Ottiene il profilo utente come stream in tempo reale.
  Stream<AppUser?> getUserProfileStream(String uid) {
    return _userService.getUserStream(uid);
  }

  /// Salva il profilo completo dell'utente.
  Future<void> saveProfile({
    required String uid,
    required String name,
    required String surname,
    String bio = '',
    File? imageFile,
  }) {
    return _userService.saveProfile(
      uid: uid,
      name: name,
      surname: surname,
      bio: bio,
      imageFile: imageFile,
    );
  }

  /// Aggiorna il campo homeId dell'utente.
  Future<void> updateHomeId(String uid, String homeId) {
    return _userService.updateUser(uid, {'homeId': homeId});
  }
}
