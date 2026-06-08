// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_House _$HouseFromJson(Map<String, dynamic> json) => _House(
  id: json['id'] as String,
  nome: json['nome'] as String,
  membri:
      (json['membri'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  leaderboardMonth: json['leaderboardMonth'] as String? ?? '',
);

Map<String, dynamic> _$HouseToJson(_House instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'membri': instance.membri,
  'leaderboardMonth': instance.leaderboardMonth,
};
