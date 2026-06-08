import 'package:freezed_annotation/freezed_annotation.dart';
import 'json_converters.dart';

part 'user_badge.freezed.dart';
part 'user_badge.g.dart';

/// Modello di dominio per un badge/achievement sbloccato da un utente.
@freezed
abstract class UserBadge with _$UserBadge {
  const factory UserBadge({
    @Default('') String templateId,
    @DateTimeConverter() required DateTime unlockedAt,
    int? month,
    int? year,
  }) = _UserBadge;

  factory UserBadge.fromJson(Map<String, dynamic> json) =>
      _$UserBadgeFromJson(json);
}
