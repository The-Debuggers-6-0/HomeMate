// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HouseRule _$HouseRuleFromJson(Map<String, dynamic> json) => _HouseRule(
  id: json['id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$HouseRuleToJson(_HouseRule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
    };
