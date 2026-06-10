import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/cleaning_task.dart';
import '../../domain/models/shopping_item.dart';
import '../../domain/models/house_event.dart';
import '../../domain/models/sticky_note.dart';
import '../../domain/models/house_rule.dart';
import 'organize_repository.dart';

/// Implementazione concreta di OrganizeRepository che utilizza Firebase Firestore
/// per le operazioni di lettura e scrittura relative all'organizzazione della casa.
class OrganizeFirestoreRepository implements OrganizeRepository {
  final FirebaseFirestore _firestore;
  static const Duration _shoppingItemExpiry = Duration(days: 1);
  static const Duration _cleaningTaskExpiry = Duration(days: 1);

  OrganizeFirestoreRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _houseCollection(String houseId, String sub) =>
      _firestore.collection('houses').doc(houseId).collection(sub);

  // --- Turni di pulizia ---
  
  /// Recupera lo stream dei turni di pulizia, eliminando in automatico quelli scaduti.
  @override
  Stream<List<CleaningTask>> getCleaningTasksStream(String houseId) {
    return _houseCollection(houseId, 'cleaning_tasks')
        .orderBy('weekStart', descending: false)
        .snapshots()
        .asyncMap((snap) async {
      final tasks = <CleaningTask>[];
      final now = DateTime.now();

      for (final d in snap.docs) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        final task = CleaningTask.fromJson(data);

        final isExpired = task.completed && task.completedAt != null && now.difference(task.completedAt!) >= _cleaningTaskExpiry;
        if (isExpired) {
          await d.reference.delete();
          continue;
        }

        tasks.add(task);
      }

      return tasks;
    });
  }

  /// Aggiunge un nuovo turno di pulizia o ne aggiorna uno esistente su Firestore.
  @override
  Future<void> addOrUpdateCleaningTask(String houseId, CleaningTask task) async {
    final col = _houseCollection(houseId, 'cleaning_tasks');
    final doc = task.id.isEmpty ? col.doc() : col.doc(task.id);
    await doc.set({
      'title': task.title,
      'assigneeUid': task.assigneeUid,
      'weekStart': task.weekStart.toIso8601String(),
      'completed': task.completed,
      'completedAt': task.completedAt?.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Segna un turno di pulizia come completato o da fare, registrando l'orario.
  @override
  Future<void> toggleCleaningTaskCompleted(String houseId, String taskId, bool completed) async {
    final doc = _houseCollection(houseId, 'cleaning_tasks').doc(taskId);
    await doc.update({
      'completed': completed,
      'completedAt': completed ? FieldValue.serverTimestamp() : null,
    });
  }

  @override
  Future<void> deleteCleaningTask(String houseId, String taskId) async {
    await _houseCollection(houseId, 'cleaning_tasks').doc(taskId).delete();
  }

  // --- Lista della spesa ---
  
  /// Recupera lo stream della lista della spesa, eliminando in automatico gli articoli già comprati e scaduti.
  @override
  Stream<List<ShoppingItem>> getShoppingListStream(String houseId) {
    return _houseCollection(houseId, 'shopping_list')
        .orderBy('addedAt', descending: false)
        .snapshots()
        .asyncMap((snap) async {
      final items = <ShoppingItem>[];
      final now = DateTime.now();

      for (final d in snap.docs) {
        final data = Map<String, dynamic>.from(d.data());
        data['id'] = d.id;
        final item = ShoppingItem.fromJson(data);

        final boughtAt = item.boughtAt;
        final isExpired = item.bought && boughtAt != null && now.difference(boughtAt) >= _shoppingItemExpiry;
        if (isExpired) {
          await d.reference.delete();
          continue;
        }

        items.add(item);
      }

      return items;
    });
  }

  /// Aggiunge un nuovo articolo alla lista della spesa.
  @override
  Future<bool> addShoppingItem(String houseId, ShoppingItem item) async {
    final col = _houseCollection(houseId, 'shopping_list');
    final doc = item.id.isEmpty ? col.doc() : col.doc(item.id);
    await doc.set({
      'name': item.name,
      'quantity': item.quantity,
      'addedByUid': item.addedByUid,
      'bought': item.bought,
      'addedAt': item.addedAt.toIso8601String(),
      'boughtAt': item.boughtAt?.toIso8601String(),
    });
    return true;
  }

  /// Segna un articolo come acquistato (o non acquistato), salvando chi lo ha comprato.
  @override
  Future<void> markItemBought(String houseId, String itemId, bool bought, String userUid) async {
    final doc = _houseCollection(houseId, 'shopping_list').doc(itemId);
    await doc.update({
      'bought': bought,
      'boughtAt': bought ? FieldValue.serverTimestamp() : null,
      'boughtByUid': bought ? userUid : null,
    });
  }

  @override
  Future<void> deleteShoppingItem(String houseId, String itemId) async {
    await _houseCollection(houseId, 'shopping_list').doc(itemId).delete();
  }

  // --- Eventi ---
  
  /// Recupera lo stream degli eventi (calendario) ordinati per data di inizio.
  @override
  Stream<List<HouseEvent>> getEventsStream(String houseId) {
    return _houseCollection(houseId, 'events')
        .orderBy('start', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['id'] = d.id;
              return HouseEvent.fromJson(data);
            }).toList());
  }

  /// Aggiunge un nuovo evento al calendario di casa o ne aggiorna uno esistente.
  @override
  Future<void> addOrUpdateEvent(String houseId, HouseEvent event) async {
    final col = _houseCollection(houseId, 'events');
    final doc = event.id.isEmpty ? col.doc() : col.doc(event.id);
    await doc.set({
      'title': event.title,
      'start': event.start.toIso8601String(),
      'end': event.end?.toIso8601String(),
      'creatorUid': event.creatorUid,
      'notes': event.notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteEvent(String houseId, String eventId) async {
    await _houseCollection(houseId, 'events').doc(eventId).delete();
  }

  // Sticky notes
  @override
  Stream<List<StickyNote>> getStickyNotesStream(String houseId) {
    return _houseCollection(houseId, 'sticky_notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['id'] = d.id;
              return StickyNote.fromJson(data);
            }).toList());
  }

  @override
  Future<void> addStickyNote(String houseId, StickyNote note) async {
    final col = _houseCollection(houseId, 'sticky_notes');
    final doc = note.id.isEmpty ? col.doc() : col.doc(note.id);
    await doc.set({
      'content': note.content,
      'authorUid': note.authorUid,
      'authorName': note.authorName,
      'authorPhotoUrl': note.authorPhotoUrl,
      'createdAt': note.createdAt.toIso8601String(),
    });
  }

  @override
  Future<void> deleteStickyNote(String houseId, String noteId) async {
    await _houseCollection(houseId, 'sticky_notes').doc(noteId).delete();
  }

  // Rules
  @override
  Stream<List<HouseRule>> getHouseRulesStream(String houseId) {
    return _houseCollection(houseId, 'rules')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = Map<String, dynamic>.from(d.data());
              data['id'] = d.id;
              return HouseRule.fromJson(data);
            }).toList());
  }

  @override
  Future<void> updateHouseRules(String houseId, List<HouseRule> rules) async {
    final col = _houseCollection(houseId, 'rules');
    final batch = _firestore.batch();
    for (var r in rules) {
      final doc = r.id.isEmpty ? col.doc() : col.doc(r.id);
      batch.set(doc, {'title': r.title, 'description': r.description});
    }
    await batch.commit();
  }

  // Recycling
  @override
  Stream<Map<String, String>> getRecyclingScheduleStream(String houseId) {
    return _firestore.collection('houses').doc(houseId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return {};
      final data = snapshot.data()!;
      if (data['recyclingSchedule'] == null) return {};
      return Map<String, String>.from(data['recyclingSchedule'] as Map);
    });
  }

  @override
  Future<void> updateRecyclingSchedule(String houseId, Map<String, String> schedule) async {
    await _firestore.collection('houses').doc(houseId).update({
      'recyclingSchedule': schedule,
    });
  }

  // Chore rooms (stanze personalizzabili)
  @override
  Stream<List<String>> getChoreRoomsStream(String houseId) {
    return _firestore.collection('houses').doc(houseId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return <String>['Cucina', 'Bagno', 'Salotto'];
      final data = snapshot.data()!;
      if (data['choreRooms'] == null) return <String>['Cucina', 'Bagno', 'Salotto'];
      return List<String>.from(data['choreRooms'] as List);
    });
  }

  @override
  Future<void> updateChoreRooms(String houseId, List<String> rooms) async {
    await _firestore.collection('houses').doc(houseId).update({
      'choreRooms': rooms,
    });
  }

  // Waste responsible (turno immondizia persistente)
  @override
  Stream<Map<String, dynamic>> getWasteResponsibleStream(String houseId) {
    return _firestore.collection('houses').doc(houseId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return <String, dynamic>{};
      final data = snapshot.data()!;
      if (data['wasteResponsible'] == null) return <String, dynamic>{};
      return Map<String, dynamic>.from(data['wasteResponsible'] as Map);
    });
  }

  @override
  Future<void> updateWasteResponsible(String houseId, String uid, DateTime weekStart) async {
    await _firestore.collection('houses').doc(houseId).update({
      'wasteResponsible': {
        'uid': uid,
        'weekStart': weekStart.toIso8601String(),
      },
    });
  }

  @override
  Future<void> confirmWasteTakenOutToday(String houseId, String uid, String wasteType) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    await _firestore.collection('houses').doc(houseId).update({
      'wasteConfirmations.$dateKey': {
        'uid': uid,
        'wasteType': wasteType,
        'confirmedAt': FieldValue.serverTimestamp(),
      },
    });
  }

  @override
  Stream<Map<String, dynamic>> getWasteConfirmationStream(String houseId) {
    return _firestore.collection('houses').doc(houseId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return <String, dynamic>{};
      final data = snapshot.data()!;
      if (data['wasteConfirmations'] == null) return <String, dynamic>{};
      return Map<String, dynamic>.from(data['wasteConfirmations'] as Map);
    });
  }
}
