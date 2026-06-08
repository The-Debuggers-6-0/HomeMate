import 'package:freezed_annotation/freezed_annotation.dart';
import 'json_converters.dart';

part 'sticky_note.freezed.dart';
part 'sticky_note.g.dart';

/// Modello di dominio per una nota della bacheca (Post-it).
@freezed
abstract class StickyNote with _$StickyNote {
  const factory StickyNote({
    @Default('') String id,
    @Default('') String content,
    @Default('') String authorUid,
    @Default('') String authorName,
    @Default('') String authorPhotoUrl,
    @DateTimeConverter() required DateTime createdAt,
  }) = _StickyNote;

  factory StickyNote.fromJson(Map<String, dynamic> json) =>
      _$StickyNoteFromJson(json);
}
