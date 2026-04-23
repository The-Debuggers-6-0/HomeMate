import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Modello di dominio per l'utente dell'app.
/// Utilizzato sia dal layer data che dal layer UI.
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    @Default('') String name,
    @Default('') String surname,
    @Default('') String bio,
    @Default(false) bool profileCompleted,
    @Default('') String homeId,
    String? photoUrl,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  /// Factory per creare un AppUser da un documento Firestore.
  /// Gestisce i campi mancanti con valori di default.
  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      surname: data['surname'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      profileCompleted: data['profileCompleted'] as bool? ?? false,
      homeId: data['homeId'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?, // <--- 2. AGGIUNTO QUI PER LEGGERLO DA FIREBASE
    );
  }
}