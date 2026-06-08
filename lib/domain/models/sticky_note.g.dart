// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticky_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StickyNote _$StickyNoteFromJson(Map<String, dynamic> json) => _StickyNote(
  id: json['id'] as String? ?? '',
  content: json['content'] as String? ?? '',
  authorUid: json['authorUid'] as String? ?? '',
  authorName: json['authorName'] as String? ?? '',
  authorPhotoUrl: json['authorPhotoUrl'] as String? ?? '',
  createdAt: const DateTimeConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$StickyNoteToJson(_StickyNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'authorUid': instance.authorUid,
      'authorName': instance.authorName,
      'authorPhotoUrl': instance.authorPhotoUrl,
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
    };
