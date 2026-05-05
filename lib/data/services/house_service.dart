import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/house.dart';

/// Service che gestisce le operazioni CRUD su Firestore per la collection 'houses'.
class HouseService {
  final FirebaseFirestore _firestore;

  HouseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _housesCollection =>
      _firestore.collection('houses');

  /// Genera un codice casa univoco di 6 caratteri alfanumerici.
  String generateHouseCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Crea una nuova casa su Firestore e aggiorna l'utente in un'unica operazione atomica.
  Future<void> createHouseWithAdmin({
    required String code,
    required String adminUid,
    required String nome,
  }) async {
    final batch = _firestore.batch();
    
    final houseDoc = _housesCollection.doc(code);
    batch.set(houseDoc, {
      'admin': adminUid,
      'membri': [adminUid],
      'nome': nome,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    final userDoc = _firestore.collection('users').doc(adminUid);
    batch.update(userDoc, {'homeId': code});
    
    await batch.commit();
  }

  /// Unisce un utente a una casa esistente in modo atomico tramite transazione.
  Future<bool> joinHouseTransaction({
    required String uid,
    required String code,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        final houseDoc = _housesCollection.doc(code);
        final houseSnapshot = await transaction.get(houseDoc);

        if (!houseSnapshot.exists) return false;

        transaction.update(houseDoc, {
          'membri': FieldValue.arrayUnion([uid]),
        });

        final userDoc = _firestore.collection('users').doc(uid);
        transaction.update(userDoc, {'homeId': code});

        return true;
      });
    } catch (e) {
      return false;
    }
  }

  /// Ottiene una casa dato il suo codice.
  Future<House?> getHouse(String code) async {
    final doc = await _housesCollection.doc(code).get();
    if (!doc.exists || doc.data() == null) return null;
    return House.fromFirestore(code, doc.data()!);
  }

  /// Aggiunge un membro alla casa.
  Future<void> addMember(String code, String uid) {
    return _housesCollection.doc(code).update({
      'membri': FieldValue.arrayUnion([uid]),
    });
  }

  /// Abbandona una casa in modo atomico.
  Future<void> leaveHouseTransaction({
    required String uid,
    required String code,
  }) async {
    final batch = _firestore.batch();

    final houseDoc = _housesCollection.doc(code);
    batch.update(houseDoc, {
      'membri': FieldValue.arrayRemove([uid]),
    });

    final userDoc = _firestore.collection('users').doc(uid);
    batch.update(userDoc, {'homeId': ''});

    await batch.commit();
  }

  /// Aggiorna il nome della casa.
  Future<void> updateHouseName(String code, String newName) {
    return _housesCollection.doc(code).update({
      'nome': newName,
    });
  }

  /// Recupera lo stream di una casa dato il suo codice.
  Stream<House?> getHouseStream(String code) {
    return _housesCollection.doc(code).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return House.fromFirestore(code, snapshot.data()!);
    });
  }

  /// Recupera lo stream dei membri di una casa dato il suo codice.
  Stream<List<dynamic>> getMemberIdsByHomeIdStream(String homeId) {
    return _housesCollection
        .doc(homeId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) return [];
          return snapshot.data()!['membri'] as List<dynamic>;
        });
  }
}
