import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  final String id;
  final String name;
  final String addedByUid;
  final bool bought;
  final DateTime addedAt;
  final DateTime? boughtAt;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.addedByUid,
    this.bought = false,
    DateTime? addedAt,
    this.boughtAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'addedByUid': addedByUid,
        'bought': bought,
        'addedAt': addedAt.toIso8601String(),
        'boughtAt': boughtAt?.toIso8601String(),
      };

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) => ShoppingItem(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        addedByUid: map['addedByUid'] ?? '',
        bought: map['bought'] ?? false,
        addedAt: _readDate(map['addedAt']) ?? DateTime.now(),
        boughtAt: _readDate(map['boughtAt']),
      );
}
