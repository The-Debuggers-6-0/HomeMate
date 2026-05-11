// import '../../domain/models/app_user.dart';
// import '../services/user_service.dart';
// import 'dart:io';

// /// Repository che astrae l'accesso ai dati utente per i ViewModel.
// class UserRepository {
//   final UserService _userService;

//   UserRepository({required UserService userService})
//       : _userService = userService;

//   /// Ottiene il profilo utente come singola lettura.
//   Future<AppUser?> getUserProfile(String uid) {
//     return _userService.getUser(uid);
//   }

//   /// Ottiene il profilo utente come stream in tempo reale.
//   Stream<AppUser?> getUserProfileStream(String uid) {
//     return _userService.getUserStream(uid);
//   }

//   /// Salva il profilo completo dell'utente.
//   Future<void> saveProfile({
//     required String uid,
//     required String name,
//     required String surname,
//     String bio = '',
//     File? imageFile,
//   }) {
//     return _userService.saveProfile(
//       uid: uid,
//       name: name,
//       surname: surname,
//       bio: bio,
//       imageFile: imageFile,
//     );
//   }

//   /// Aggiorna il campo homeId dell'utente.
//   Future<void> updateHomeId(String uid, String homeId) {
//     return _userService.updateUser(uid, {'homeId': homeId});
//   }

//   /// Elimina il documento del profilo utente da Firestore.
//   Future<void> deleteProfile(String uid) {
//     return _userService.deleteUser(uid);
//   }

//   /// Recupera l'elenco degli utenti passandogli gli UID salvati nella casa.
//   Stream<List<AppUser>> getRoommatesStream(List<String> memberIds) {
//     return _userService.getRoommatesStream(memberIds);
//   }


//   /// Sblocca un badge specifico per un utente
//   Future<void> unlockBadge(String uid, String badgeId) async {
//     final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

//     // Creiamo la mappa del nuovo badge
//     final newBadgeData = {
//       'templateId': badgeId,
//       'unlockedAt': DateTime.now().toIso8601String(),
//     };

//     // Usiamo SetOptions(merge: true) per AGGIUNGERE il badge 
//     // alla mappa senza cancellare quelli vecchi!
//     await userRef.set({
//       'unlockedBadges': {
//         badgeId: newBadgeData,
//       }
//     }, SetOptions(merge: true));

//     print("🏆 SUCCESS: Badge $badgeId sbloccato per l'utente $uid!");
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/app_user.dart';
import '../services/user_service.dart';
import 'dart:io';

/// Repository che astrae l'accesso ai dati utente per i ViewModel.
class UserRepository {
  final UserService _userService;

  UserRepository({required UserService userService})
      : _userService = userService;

  /// Ottiene il profilo utente come singola lettura.
  Future<AppUser?> getUserProfile(String uid) {
    return _userService.getUser(uid);
  }

  /// Ottiene il profilo utente come stream in tempo reale.
  Stream<AppUser?> getUserProfileStream(String uid) {
    return _userService.getUserStream(uid);
  }

  /// Salva il profilo completo dell'utente.
  Future<void> saveProfile({
    required String uid,
    required String name,
    required String surname,
    String bio = '',
    File? imageFile,
  }) {
    return _userService.saveProfile(
      uid: uid,
      name: name,
      surname: surname,
      bio: bio,
      imageFile: imageFile,
    );
  }

  /// Aggiorna il campo homeId dell'utente.
  Future<void> updateHomeId(String uid, String homeId) {
    return _userService.updateUser(uid, {'homeId': homeId});
  }

  /// Elimina il documento del profilo utente da Firestore.
  Future<void> deleteProfile(String uid) {
    return _userService.deleteUser(uid);
  }

  /// Recupera l'elenco degli utenti passandogli gli UID salvati nella casa.
  Stream<List<AppUser>> getRoommatesStream(List<String> memberIds) {
    return _userService.getRoommatesStream(memberIds);
  }

  // =======================================================
  // MOTORE UNIVERSALE DEI TRAGUARDI E DEI BADGE
  // =======================================================

  /// Sblocca un badge specifico. Se sbloccato con successo, restituisce 
  /// i metadati (titolo, icona, colore) per il popup. Altrimenti null.
  Future<Map<String, dynamic>?> checkAndUnlockBadge(
    String uid, 
    String templateId, {
    int? month, 
    int? year
  }) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    
    // 1. Creiamo l'ID univoco. (es. 'on_fire' o 'top_roommate_monthly_2026_5')
    String badgeInstanceId = templateId;
    if (month != null && year != null) {
      badgeInstanceId = "${templateId}_${year}_$month";
    }

    final snapshot = await userRef.get();
    if (!snapshot.exists) return null;

    final data = snapshot.data() as Map<String, dynamic>;
    final unlocked = data['unlockedBadges'] as Map<String, dynamic>? ?? {};

    // 2. Se l'utente ha già QUESTO specifico badge, non facciamo nulla.
    if (unlocked.containsKey(badgeInstanceId)) return null;

    // 3. Recuperiamo i dettagli dal catalogo per il Popup
    final metaDoc = await FirebaseFirestore.instance.collection('badges_metadata').doc(templateId).get();
    if (!metaDoc.exists) return null;
    final metaData = metaDoc.data()!;

    // 4. Salviamo lo sblocco su Firestore
    final newBadgeEntry = {
      'templateId': templateId,
      'unlockedAt': DateTime.now().toIso8601String(),
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    };

    await userRef.set({
      'unlockedBadges': {
        badgeInstanceId: newBadgeEntry,
      }
    }, SetOptions(merge: true));

    print("🏆 SUCCESS: Badge $badgeInstanceId sbloccato per l'utente $uid!");
    
    // 5. Restituiamo i metadati per far esplodere il popup
    return metaData; 
  }

  /// Controlla e aggiorna la serie di pulizie per il badge "On Fire"
  /// Restituisce i dati del badge se sbloccato, altrimenti null.
  Future<Map<String, dynamic>?> updateCleaningStreakAndCheckFire(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userRef.get();
    
    if (!snapshot.exists) return null;
    final data = snapshot.data() as Map<String, dynamic>;

    // Leggiamo il contatore attuale e aumentiamo
    int currentStreak = data['cleaningStreak'] ?? 0;
    currentStreak += 1;

    // Salviamo il nuovo contatore su Firestore
    await userRef.update({'cleaningStreak': currentStreak});
    print("🧹 Cleaning streak aggiornata a: $currentStreak");

    // TRAGUARDO RAGGIUNTO! Se arriva a 8, proviamo a sbloccare il badge.
    if (currentStreak >= 8) {
      return await checkAndUnlockBadge(uid, 'on_fire');
    }
    
    return null; // Niente badge per ora
  }


  /// Aggiorna il contatore della plastica e controlla il badge "Plastic Hero"
  /// Restituisce i dati del badge se sbloccato, altrimenti null.
  Future<Map<String, dynamic>?> updatePlasticCountAndCheckHero(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userRef.get();
    
    if (!snapshot.exists) return null;
    final data = snapshot.data() as Map<String, dynamic>;

    // 1. Incrementiamo il contatore specifico per la plastica
    int plasticCount = data['plasticCount'] ?? 0;
    plasticCount += 1;

    await userRef.update({'plasticCount': plasticCount});
    print("♻️ Contatore plastica: $plasticCount");

    // 2. Se arriva a 20, sblocchiamo il badge
    if (plasticCount >= 20) {
      return await checkAndUnlockBadge(uid, 'plastic_hero');
    }
    
    return null;
  }

  /// Aggiorna il contatore della carta e controlla il badge "Eroe della Carta"
  /// Restituisce i dati del badge se sbloccato, altrimenti null.
  Future<Map<String, dynamic>?> updatePaperCountAndCheckHero(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userRef.get();
    
    if (!snapshot.exists) return null;
    final data = snapshot.data() as Map<String, dynamic>;

    // 1. Incrementiamo il contatore specifico per la carta
    int paperCount = data['paperCount'] ?? 0;
    paperCount += 1;

    await userRef.update({'paperCount': paperCount});
    print("📄 Contatore carta: $paperCount");

    // 2. Se arriva a 3, sblocchiamo il badge
    if (paperCount >= 20) {
      return await checkAndUnlockBadge(uid, 'paper_hero');
    }
    
    return null;
  }


  /// Contatore Vetro -> Signore del Vetro
  Future<Map<String, dynamic>?> updateGlassCountAndCheckLord(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userRef.get();
    if (!snapshot.exists) return null;
    
    final data = snapshot.data() as Map<String, dynamic>;
    int glassCount = data['glassCount'] ?? 0;
    glassCount += 1;

    await userRef.update({'glassCount': glassCount});
    print("🍷 Contatore vetro: $glassCount");

    if (glassCount >= 20) return await checkAndUnlockBadge(uid, 'glass_lord');
    return null;
  }

  /// Contatore Umido -> Re del Compost
  Future<Map<String, dynamic>?> updateCompostCountAndCheckKing(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userRef.get();
    if (!snapshot.exists) return null;
    
    final data = snapshot.data() as Map<String, dynamic>;
    int compostCount = data['organicCount'] ?? 0;
    compostCount += 1;

    await userRef.update({'organicCount': compostCount});
    print("🌱 Contatore organico: $compostCount");

    if (compostCount >= 20) return await checkAndUnlockBadge(uid, 'organic_king');
    return null;
  }

  /// Contatore Indifferenziata -> Re del Secco
  Future<Map<String, dynamic>?> updateUnsortedCountAndCheckKing(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userRef.get();
    if (!snapshot.exists) return null;
    
    final data = snapshot.data() as Map<String, dynamic>;
    int unsortedCount = data['unsortedCount'] ?? 0;
    unsortedCount += 1;

    await userRef.update({'unsortedCount': unsortedCount});
    print("🗑️ Contatore indifferenziata: $unsortedCount");

    if (unsortedCount >= 20) return await checkAndUnlockBadge(uid, 'unsorted_king');
    return null;
  }

  /// Aggiorna il contatore dei pagamenti e controlla il badge "Fast Payer"
  /// Restituisce i dati del badge se sbloccato, altrimenti null.
  Future<Map<String, dynamic>?> updateFastPayerCountAndCheckBadge(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userRef.get();
    
    if (!snapshot.exists) return null;
    final data = snapshot.data() as Map<String, dynamic>;

    // 1. Incrementiamo il contatore dei pagamenti
    int fastPayerCount = data['fastPayerCount'] ?? 0;
    fastPayerCount += 1;

    await userRef.update({'fastPayerCount': fastPayerCount});
    print("💸 Contatore pagamenti: $fastPayerCount");

    // 2. Se arriva a 10 ,sblocchiamo il badge
    if (fastPayerCount >= 10) {
      return await checkAndUnlockBadge(uid, 'fast_payer');
    }
    
    return null;
  }

  

}