import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_badge.dart'; // <--- Ricordati di importare il file del badge!

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
    @Default(0) int points,
    
    // --- NUOVI CAMPI PER I BADGE ---
    // Usiamo @Default per dire a Freezed che se mancano da Firebase, partono vuoti
    @Default({}) Map<String, UserBadge> unlockedBadges,
    @Default([]) List<String> featuredBadges,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  /// Factory per creare un AppUser da un documento Firestore.
  /// Gestisce i campi mancanti con valori di default.
  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    
    // 1. Decodifica la mappa dei badge sbloccati
    Map<String, UserBadge> parsedBadges = {};
    if (data['unlockedBadges'] != null) {
      final badgesMap = data['unlockedBadges'] as Map<String, dynamic>;
      badgesMap.forEach((key, value) {
        parsedBadges[key] = UserBadge.fromJson(value as Map<String, dynamic>);
      });
    }

    // 2. Decodifica i badge in vetrina (evita errori se non esiste il campo)
    List<String> parsedFeatured = [];
    if (data['featuredBadges'] != null) {
      parsedFeatured = List<String>.from(data['featuredBadges']);
    }

    return AppUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      surname: data['surname'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      profileCompleted: data['profileCompleted'] as bool? ?? false,
      homeId: data['homeId'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      points: data['points'] as int? ?? 0,
      unlockedBadges: parsedBadges,
      featuredBadges: parsedFeatured,
    );
  }
}