// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HouseEvent _$HouseEventFromJson(Map<String, dynamic> json) => _HouseEvent(
  id: json['id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  start: const DateTimeConverter().fromJson(json['start']),
  end: const NullableDateTimeConverter().fromJson(json['end']),
  creatorUid: json['creatorUid'] as String? ?? '',
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$HouseEventToJson(_HouseEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'start': const DateTimeConverter().toJson(instance.start),
      'end': const NullableDateTimeConverter().toJson(instance.end),
      'creatorUid': instance.creatorUid,
      'notes': instance.notes,
    };
