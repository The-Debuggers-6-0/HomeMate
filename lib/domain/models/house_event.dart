import 'package:freezed_annotation/freezed_annotation.dart';
import 'json_converters.dart';

part 'house_event.freezed.dart';
part 'house_event.g.dart';

/// Modello di dominio per un evento del calendario di casa.
@freezed
abstract class HouseEvent with _$HouseEvent {
  const factory HouseEvent({
    @Default('') String id,
    @Default('') String title,
    @DateTimeConverter() required DateTime start,
    @NullableDateTimeConverter() DateTime? end,
    @Default('') String creatorUid,
    String? notes,
  }) = _HouseEvent;

  factory HouseEvent.fromJson(Map<String, dynamic> json) =>
      _$HouseEventFromJson(json);
}
