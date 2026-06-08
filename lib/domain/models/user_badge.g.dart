// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserBadge _$UserBadgeFromJson(Map<String, dynamic> json) => _UserBadge(
  templateId: json['templateId'] as String? ?? '',
  unlockedAt: const DateTimeConverter().fromJson(json['unlockedAt']),
  month: (json['month'] as num?)?.toInt(),
  year: (json['year'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserBadgeToJson(_UserBadge instance) =>
    <String, dynamic>{
      'templateId': instance.templateId,
      'unlockedAt': const DateTimeConverter().toJson(instance.unlockedAt),
      'month': instance.month,
      'year': instance.year,
    };
