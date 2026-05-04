import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/transaction.dart';

/// Service che gestisce le operazioni CRUD su Firestore per le finanze di una casa.
class FinanceService {
  final FirebaseFirestore _firestore;

  FinanceService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _transactionsCollection(String houseId) =>
      _firestore.collection('houses').doc(houseId).collection('transactions');

  /// Aggiunge una nuova transazione su Firestore.
  Future<void> addTransaction(String houseId, AppTransaction transaction) async {
    // Se la transazione non ha un ID, Firestore ne genererà uno automaticamente
    final docRef = transaction.id.isEmpty 
        ? _transactionsCollection(houseId).doc()
        : _transactionsCollection(houseId).doc(transaction.id);
        
    await docRef.set({
      'title': transaction.title,
      'amount': transaction.amount,
      'date': Timestamp.fromDate(transaction.date),
      'payerId': transaction.payerId,
      'receiverId': transaction.receiverId,
      'involvedUsers': transaction.involvedUsers,
      'customShares': transaction.customShares,
      'category': transaction.category,
      'type': transaction.type,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Recupera lo stream delle transazioni di una casa ordinato per data decrescente.
  Stream<List<AppTransaction>> getTransactionsStream(String houseId) {
    return _transactionsCollection(houseId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppTransaction.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }
}
