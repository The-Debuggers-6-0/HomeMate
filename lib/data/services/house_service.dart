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

  /// Crea una nuova casa su Firestore.
  Future<void> createHouse({
    required String code,
    required String adminUid,
    required String nome,
  }) {
    return _housesCollection.doc(code).set({
      'admin': adminUid,
      'membri': [adminUid],
      'nome': nome,
      'createdAt': FieldValue.serverTimestamp(),
    });
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

  /// Rimuove un membro dalla casa.
  Future<void> removeMember(String code, String uid) {
    return _housesCollection.doc(code).update({
      'membri': FieldValue.arrayRemove([uid]),
    });
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
