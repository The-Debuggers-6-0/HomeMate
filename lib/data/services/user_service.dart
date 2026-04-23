import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/app_user.dart';
import 'dart:io';
import 'dart:convert';
//import 'package:firebase_storage/firebase_storage.dart';

/// Service che gestisce le operazioni CRUD su Firestore per la collection 'users'.
class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Ottiene il profilo utente come singola lettura.
  Future<AppUser?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromFirestore(uid, doc.data()!);
  }
  
  /// Ottiene il profilo utente come stream in tempo reale.
  Stream<AppUser?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromFirestore(uid, doc.data()!);
    });
  }

  /// Crea un nuovo documento utente su Firestore.
  Future<void> createUser({
    required String uid,
    required String email,
    String name = '',
    String? displayName,
  }) {
    return _usersCollection.doc(uid).set({
      'email': email,
      'name': name.isNotEmpty ? name : (displayName ?? ''),
      'createdAt': FieldValue.serverTimestamp(),
      'profileCompleted': false,
      'homeId': '',
    }, SetOptions(merge: true));
  }

  /// Aggiorna campi specifici del profilo utente.
  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _usersCollection.doc(uid).update(data);
  }

  /// Salva il profilo completo (nome, cognome, bio) e marca come completato.
  Future<void> saveProfile({
    required String uid,
    required String name,
    required String surname,
    String bio = '',
    File? imageFile,
  }) async {
    String? base64Image;

    // TRUCCO BASE64: Trasformiamo il file in un testo lunghissimo!
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      base64Image = base64Encode(bytes); // Ecco la magia
    }

    final Map<String, dynamic> data = {
      'name': name,
      'surname': surname,
      'bio': bio,
      'profileCompleted': true,
    };

    // Salviamo il testo della foto nel database normale
    if (base64Image != null) {
      data['photoUrl'] = base64Image; 
    }

    return _usersCollection.doc(uid).set(data, SetOptions(merge: true));
  }

  /// Aggiorna il campo lastLogin.
  Future<void> updateLastLogin(String uid, String email, String displayName) {
    return _usersCollection.doc(uid).set({
      'email': email,
      'name': displayName,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
