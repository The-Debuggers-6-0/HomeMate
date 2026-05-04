// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppTransaction _$AppTransactionFromJson(Map<String, dynamic> json) =>
    _AppTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      payerId: json['payerId'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
      receiverId: json['receiverId'] as String?,
      involvedUsers: (json['involvedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      customShares: (json['customShares'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$AppTransactionToJson(_AppTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'payerId': instance.payerId,
      'category': instance.category,
      'type': instance.type,
      'receiverId': instance.receiverId,
      'involvedUsers': instance.involvedUsers,
      'customShares': instance.customShares,
    };
