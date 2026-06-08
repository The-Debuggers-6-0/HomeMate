// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShoppingItem _$ShoppingItemFromJson(Map<String, dynamic> json) =>
    _ShoppingItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as String? ?? '',
      addedByUid: json['addedByUid'] as String? ?? '',
      boughtByUid: json['boughtByUid'] as String?,
      bought: json['bought'] as bool? ?? false,
      addedAt: const DateTimeConverter().fromJson(json['addedAt']),
      boughtAt: const NullableDateTimeConverter().fromJson(json['boughtAt']),
    );

Map<String, dynamic> _$ShoppingItemToJson(_ShoppingItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'addedByUid': instance.addedByUid,
      'boughtByUid': instance.boughtByUid,
      'bought': instance.bought,
      'addedAt': const DateTimeConverter().toJson(instance.addedAt),
      'boughtAt': const NullableDateTimeConverter().toJson(instance.boughtAt),
    };
