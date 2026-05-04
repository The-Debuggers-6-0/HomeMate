import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
abstract class AppTransaction with _$AppTransaction {
  const factory AppTransaction({
    required String id,
    required String title,
    required double amount,
    required DateTime date,
    required String payerId,
    required String category,
    required String type, // 'expense' o 'reimbursement'
    String? receiverId, // ID dell'utente che riceve il rimborso
    List<String>? involvedUsers, // UID degli utenti tra cui è divisa
    Map<String, double>? customShares, // (Nuovo) Mappa UID -> Importo esatto
  }) = _AppTransaction;

  factory AppTransaction.fromJson(Map<String, dynamic> json) => _$AppTransactionFromJson(json);

  /// Factory per creare un'AppTransaction da un documento Firestore.
  factory AppTransaction.fromFirestore(String id, Map<String, dynamic> data) {
    return AppTransaction(
      id: id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: data['date'] != null 
          ? (data['date'] as Timestamp).toDate() 
          : DateTime.now(),
      payerId: data['payerId'] as String? ?? '',
      category: data['category'] as String? ?? '',
      type: data['type'] as String? ?? 'expense',
      receiverId: data['receiverId'] as String?,
      involvedUsers: (data['involvedUsers'] as List<dynamic>?)?.map((e) => e as String).toList(),
      customShares: data['customShares'] != null
          ? (data['customShares'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            )
          : null,
    );
  }
}
