import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/house.dart';
import '../../../data/repositories/organize_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/house_repository.dart';
import '../../../data/services/notification_service.dart';
import '../../../domain/models/cleaning_task.dart';
import '../../../domain/models/shopping_item.dart';
import '../../../domain/models/house_event.dart';
import '../../../domain/models/sticky_note.dart';
import '../../../domain/models/house_rule.dart';
import '../../../data/repositories/auth_repository.dart';

class OrganizzaViewModel extends ChangeNotifier {
  final OrganizeRepository organizeRepository;
  final AuthRepository authRepository;
  final HouseRepository houseRepository;

  bool _isLoading = true;
  bool _isResettingLeaderboard = false; // <-- Lucchetto per evitare i loop infiniti
  String? _houseId;

  StreamSubscription<List<CleaningTask>>? _cleaningSub;
  StreamSubscription<List<ShoppingItem>>? _shoppingSub;
  StreamSubscription<List<HouseEvent>>? _eventsSub;
  StreamSubscription<List<StickyNote>>? _notesSub;
  StreamSubscription<List<HouseRule>>? _rulesSub;
  StreamSubscription<Map<String, String>>? _recyclingSub;
  StreamSubscription<House?>? _houseSub;
  StreamSubscription<List<AppUser>>? _houseMembersSub;
  StreamSubscription<List<String>>? _choreRoomsSub;
  StreamSubscription<Map<String, dynamic>>? _wasteResponsibleSub;
  StreamSubscription<Map<String, dynamic>>? _wasteConfirmationSub;

  List<CleaningTask> _cleaning = [];
  List<ShoppingItem> _shopping = [];
  List<HouseEvent> _events = [];
  List<StickyNote> _notes = [];
  List<HouseRule> _rules = [];
  Map<String, String> _recyclingSchedule = {};
  bool _tomorrowWasteTakenOut = false;
  List<String> _houseMembers = [];
  List<AppUser> _houseMemberUsers = [];
  List<String> _choreRooms = ['Cucina', 'Bagno', 'Salotto'];
  Map<String, dynamic> _wasteResponsibleData = {};
  Map<String, dynamic> _wasteConfirmations = {};

  // Flag per evitare race condition: seed solo quando entrambi gli stream sono pronti
  bool _cleaningLoaded = false;
  bool _choreRoomsLoaded = false;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;
  bool _disposed = false;

  // --- Servizio notifiche ---
  final NotificationService _notificationService = NotificationService();

  // --- Tracking notifiche: ID già noti ---
  Set<String> _knownCleaningIds = {};
  Set<String> _knownShoppingIds = {};
  Set<String> _knownEventIds = {};
  bool _cleaningInitialLoadDone = false;
  bool _shoppingInitialLoadDone = false;
  bool _eventsInitialLoadDone = false;
  String? _lastWasteResponsibleUid;

  OrganizzaViewModel({
    required this.organizeRepository,
    required this.authRepository,
    required this.houseRepository,
    required UserRepository userRepository,
  }) {
    _userRepository = userRepository;
    _init();
  }

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  bool get tomorrowWasteTakenOut => _tomorrowWasteTakenOut;
  List<CleaningTask> get cleaning => List.unmodifiable(_cleaning);
  List<String> get choreRooms => List.unmodifiable(_choreRooms);
  
  List<CleaningTask> get currentWeekCleaningTasks => List.unmodifiable(
        _cleaning.where((task) => _isCurrentWeek(task.weekStart)).toList(),
      );

  List<CleaningTask> get pendingCleaningTasks => List.unmodifiable(
        currentWeekCleaningTasks.where((task) => !task.completed).toList(),
      );

  List<CleaningTask> get completedCleaningTasks => List.unmodifiable(
        _cleaning.where((task) => task.completed).toList(),
      );

  int get completedCleaningTasksCount => completedCleaningTasks.length;

  List<CleaningTask> get futureCleaningTasks {
    final currentWeekStart = _currentWeekStart();
    return List.unmodifiable(
      _cleaning.where((task) {
        return task.weekStart.isAfter(currentWeekStart.add(const Duration(days: 6)));
      }).toList()
        ..sort((a, b) => a.weekStart.compareTo(b.weekStart)),
    );
  }

  List<String> get houseMembers => List.unmodifiable(_houseMembers);

  /// Controlla se la spazzatura di oggi è stata confermata
  bool get todayWasteTakenOut {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return _wasteConfirmations.containsKey(dateKey);
  }

  List<ShoppingItem> get shopping => List.unmodifiable(_shopping);

  List<ShoppingItem> get pendingShoppingItems => List.unmodifiable(
        _shopping.where((item) => !item.bought).toList(),
      );

  List<ShoppingItem> get boughtShoppingItems => List.unmodifiable(
        _shopping.where((item) => item.bought).toList(),
      );

  List<HouseEvent> get events => List.unmodifiable(_events);
  List<StickyNote> get notes => List.unmodifiable(_notes);
  List<HouseRule> get rules => List.unmodifiable(_rules);
  List<AppUser> get houseMemberUsers => List.unmodifiable(_houseMemberUsers);

  AppUser? appUserFor(String uid) {
    try {
      return _houseMemberUsers.firstWhere((u) => u.uid == uid);
    } catch (_) {
      return null;
    }
  }

  DateTime? absenceEndDateFor(String uid) {
    for (final event in activeAbsences) {
      final notes = event.notes ?? '';
      if (notes.startsWith('absent_uid:')) {
        if (notes.replaceFirst('absent_uid:', '').trim() == uid) return event.end;
      } else {
        final name = event.title.replaceFirst('Assente: ', '').toLowerCase().trim();
        if (name == 'te' && uid == authRepository.currentFirebaseUser?.uid) return event.end;
        try {
          final user = _houseMemberUsers.firstWhere((u) => u.uid == uid);
          final displayName = (user.name.isNotEmpty ? user.name : user.email).toLowerCase();
          if (displayName == name) return event.end;
        } catch (_) {}
      }
    }
    return null;
  }

  AppUser? appUserForAbsenceEvent(HouseEvent event) {
    final name = event.title.replaceFirst('Assente: ', '').toLowerCase().trim();
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (name == 'te' && currentUid != null) return appUserFor(currentUid);
    try {
      return _houseMemberUsers.firstWhere(
        (u) => u.name.toLowerCase() == name || u.email.toLowerCase() == name,
      );
    } catch (_) {
      return null;
    }
  }

  List<HouseEvent> get activeAbsences => List.unmodifiable(
    _events.where((e) {
      if (!e.title.startsWith('Assente:')) return false;
      final now = DateTime.now();
      if (e.end != null) {
        return e.end!.isAfter(now);
      }
      final s = e.start;
      return s.year == now.year && s.month == now.month && s.day == now.day;
    }).toList(),
  );

  static const List<String> wasteTypes = [
    'Nulla',
    'Plastica',
    'Carta',
    'Vetro',
    'Organico',
    'Indifferenziato'
  ];

  static const List<String> weekDays = [
    'Lunedì',
    'Martedì',
    'Mercoledì',
    'Giovedì',
    'Venerdì',
    'Sabato',
    'Domenica'
  ];

  String displayNameFor(String uid, {bool showStatus = false}) {
    if (uid.isEmpty) return 'Qualcuno';
    final currentUid = authRepository.currentFirebaseUser?.uid;
    String name = '';

    try {
      final user = _houseMemberUsers.firstWhere((element) => element.uid == uid);
      name = user.name.isNotEmpty ? user.name : user.email;
    } catch (_) {
      // Fallback: se è l'utente corrente, usiamo i dati da Firebase Auth
      if (uid == currentUid) {
        final firebaseUser = authRepository.currentFirebaseUser;
        name = firebaseUser?.displayName ?? firebaseUser?.email ?? 'Te';
      } else {
        name = 'Coinquilino';
      }
    }

    final isAway = isUserAway(uid);
    String result = uid == currentUid ? 'Te' : name;
    
    if (showStatus && isAway) {
      result += ' (Fuori)';
    }
    
    return result;
  }

  late final UserRepository _userRepository;

  void setTomorrowWasteTakenOut(bool value) {
    _tomorrowWasteTakenOut = value;
    _safeNotify();
  }

  void _init() {
    _authSub = authRepository.authStateChanges().listen((user) {
      if (_disposed) return;

      if (user != null) {
        _isLoading = true;
        _safeNotify();

        _profileSub?.cancel();
        _profileSub = _userRepository.getUserProfileStream(user.uid).listen((profile) {
          if (_disposed) return;

          if (profile != null && profile.homeId.isNotEmpty) {
            if (_houseId != profile.homeId) {
              _houseId = profile.homeId;
              startListening(_houseId!);
              _watchHouseMembers(_houseId!);
            }
          } else {
            _houseId = null;
            _cleaning = [];
            _shopping = [];
            _events = [];
            _notes = [];
            _rules = [];
            _safeNotify();
          }
          _isLoading = false;
          _safeNotify();
        });
      } else {
        _houseId = null;
        _profileSub?.cancel();
        _profileSub = null;
        _houseSub?.cancel();
        _houseSub = null;
        _houseMembers = [];
        _cleaning = [];
        _shopping = [];
        _events = [];
        _notes = [];
        _rules = [];
        _isLoading = false;
        _safeNotify();
      }
    });
  }

  Map<String, String> get recyclingSchedule => Map.unmodifiable(_recyclingSchedule);

  /// Verifica se un utente è attualmente "Fuori Casa" o in "Vacanza".
  /// Controlla gli eventi nel calendario cercando il prefisso 'absent_uid:' 
  /// o parole chiave nel titolo/note (logica legacy).
  bool isUserAway(String uid) {
    final now = DateTime.now();

    return _events.any((event) {
      final notes = event.notes ?? '';

      // LOGICA ASSENZA: Cerca eventi che contengono l'UID dell'utente nelle note
      // Formato nuovo: absent_uid:UID (affidabile, UID diretto)
      if (notes.startsWith('absent_uid:')) {
        final absentUid = notes.replaceFirst('absent_uid:', '').trim();
        if (absentUid != uid) return false;
        return _isEventActive(event, now);
      }

      // LOGICA LEGACY: Se non c'è l'UID, cerca parole chiave come "vacanza" o "assente"
      // e prova a matchare il nome dell'utente nel titolo dell'evento.
      final title = event.title.toLowerCase();
      final notesLower = notes.toLowerCase();
      final keywords = ['vacanza', 'fuori', 'assente', 'ferie', 'viaggio'];
      final isAbsenceType = keywords.any((k) => title.contains(k) || notesLower.contains(k));
      if (!isAbsenceType) return false;

      String userName = '';
      try {
        userName = _houseMemberUsers.firstWhere((u) => u.uid == uid).name.toLowerCase();
      } catch (_) {}

      final currentUid = authRepository.currentFirebaseUser?.uid;
      final isCurrentUser = uid == currentUid;
      final isTargetUser = isCurrentUser
          ? (event.creatorUid == uid || title.contains('te'))
          : (userName.isNotEmpty && title.contains(userName));

      if (!isTargetUser) return false;
      return _isEventActive(event, now);
    });
  }

  bool _isEventActive(HouseEvent event, DateTime now) {
    if (event.end != null) {
      return now.isAfter(event.start) && now.isBefore(event.end!);
    }
    return now.year == event.start.year &&
        now.month == event.start.month &&
        now.day == event.start.day;
  }

  /// Calcola chi è il responsabile della spazzatura per la settimana corrente.
  /// Implementa la logica di rotazione e gestione sostituzioni per vacanze.
  String? get currentWasteResponsibleUid {
    // 1. Se abbiamo un responsabile già salvato su Firestore per questa settimana, usiamo quello
    if (_wasteResponsibleData.isNotEmpty) {
      final storedWeekStart = _wasteResponsibleData['weekStart'] as String?;
      if (storedWeekStart != null) {
        final storedDate = DateTime.tryParse(storedWeekStart);
        if (storedDate != null && _isCurrentWeek(storedDate)) {
          return _wasteResponsibleData['uid'] as String?;
        }
      }
    }

    // 2. Se non c'è o è scaduto, calcoliamo il nuovo responsabile
    if (_houseMembers.isEmpty) return null;
    final weekIndex = _currentWeekStart().difference(DateTime(2024, 1, 1)).inDays ~/ 7;

    String? responsibleUid;
    // ROTAZIONE + GESTIONE VACANZE:
    // Cicliamo tra i membri partendo dal responsabile teorico di questa settimana.
    // Se il primo della lista è in vacanza (isUserAway), passiamo al successivo.
    for (int i = 0; i < _houseMembers.length; i++) {
      final candidateUid = _houseMembers[(weekIndex + 2 + i) % _houseMembers.length];
      if (!isUserAway(candidateUid)) {
        responsibleUid = candidateUid;
        break;
      }
    }

    // Fallback: se sono tutti in vacanza, assegniamo comunque al responsabile teorico
    responsibleUid ??= _houseMembers[(weekIndex + 2) % _houseMembers.length];

    // 3. Salviamo la scelta su Firestore in modo che sia consistente per tutti per tutta la settimana
    if (_houseId != null) {
      organizeRepository.updateWasteResponsible(_houseId!, responsibleUid, _currentWeekStart());
    }

    return responsibleUid;
  }

  String get todayWaste => _getWasteForDay(DateTime.now());
  String get tomorrowWaste => _getWasteForDay(DateTime.now().add(const Duration(days: 1)));

  bool get isUserResponsibleForTodayWaste {
    final currentUid = authRepository.currentFirebaseUser?.uid;
    return currentUid != null && currentWasteResponsibleUid == currentUid;
  }

  String getWasteTitle(String wasteType) {
    return wasteType == 'Nulla' ? 'Nessuna raccolta' : wasteType;
  }

  String getWasteSubtitle(String wasteType, bool isToday) {
    if (wasteType == 'Nulla') {
      return isToday ? 'Goditi il relax' : '';
    }
    return isToday ? 'Non dimenticare!' : 'Ricordati di portare fuori il sacco!';
  }

  String _getWasteForDay(DateTime date) {
    final dayName = _weekdayToString(date.weekday);
    return _recyclingSchedule[dayName] ?? 'Nulla';
  }

  String _weekdayToString(int weekday) {
    switch (weekday) {
      case 1: return 'Lunedì';
      case 2: return 'Martedì';
      case 3: return 'Mercoledì';
      case 4: return 'Giovedì';
      case 5: return 'Venerdì';
      case 6: return 'Sabato';
      case 7: return 'Domenica';
      default: return '';
    }
  }

  void startListening(String houseId) {
    _houseId = houseId;
    _cleaningSub?.cancel();
    _shoppingSub?.cancel();
    _eventsSub?.cancel();
    _notesSub?.cancel();
    _rulesSub?.cancel();
    _recyclingSub?.cancel();
    _choreRoomsSub?.cancel();
    _wasteResponsibleSub?.cancel();
    _wasteConfirmationSub?.cancel();

    // Reset flag per il seed
    _cleaningLoaded = false;
    _choreRoomsLoaded = false;

    // Reset tracking notifiche per la nuova casa
    _cleaningInitialLoadDone = false;
    _shoppingInitialLoadDone = false;
    _eventsInitialLoadDone = false;
    _knownCleaningIds = {};
    _knownShoppingIds = {};
    _knownEventIds = {};
    _lastWasteResponsibleUid = null;

    _cleaningSub = organizeRepository.getCleaningTasksStream(houseId).listen((list) {
      if (_disposed) return;

      // --- Notifiche per nuovi task di pulizia assegnati a me ---
      final currentUid = authRepository.currentFirebaseUser?.uid;
      final currentIds = list.map((t) => t.id).toSet();
      if (!_cleaningInitialLoadDone) {
        _knownCleaningIds = currentIds;
        _cleaningInitialLoadDone = true;
      } else if (currentUid != null) {
        final newIds = currentIds.difference(_knownCleaningIds);
        for (final id in newIds) {
          final task = list.firstWhere((t) => t.id == id);
          if (task.assigneeUid == currentUid && !task.completed) {
            _notificationService.showChoreNotification(
              id: NotificationService.generateId(task.id),
              choreName: task.title,
              dueDate: task.weekStart.add(const Duration(days: 6)),
            );
            // Programma reminder per fine settimana (sabato alle 10:00)
            final reminderDate = task.weekStart.add(const Duration(days: 5, hours: 10));
            if (reminderDate.isAfter(DateTime.now())) {
              _notificationService.schedule(
                id: NotificationService.generateId('reminder_${task.id}'),
                title: '⏰ Reminder pulizia',
                body: 'Ricordati di completare: ${task.title}',
                scheduledDate: reminderDate,
              );
            }
          }
        }
        _knownCleaningIds = currentIds;
      }

      _cleaning = list;
      _cleaningLoaded = true;
      _trySeed();
      _safeNotify();
    });

    _shoppingSub = organizeRepository.getShoppingListStream(houseId).listen((list) {
      if (_disposed) return;

      // --- Notifiche per nuovi articoli nella lista della spesa ---
      final currentUid = authRepository.currentFirebaseUser?.uid;
      final currentIds = list.map((i) => i.id).toSet();
      if (!_shoppingInitialLoadDone) {
        _knownShoppingIds = currentIds;
        _shoppingInitialLoadDone = true;
      } else if (currentUid != null) {
        final newIds = currentIds.difference(_knownShoppingIds);
        for (final id in newIds) {
          final item = list.firstWhere((i) => i.id == id);
          if (item.addedByUid != currentUid) {
            _notificationService.show(
              id: NotificationService.generateId(item.id),
              title: '🛒 Lista della spesa',
              body: 'Aggiunto: ${item.name}${item.quantity.isNotEmpty ? ' (${item.quantity})' : ''}',
            );
          }
        }
        _knownShoppingIds = currentIds;
      }

      _shopping = list;
      _safeNotify();
    });

    _eventsSub = organizeRepository.getEventsStream(houseId).listen((list) {
      if (_disposed) return;

      final currentUid = authRepository.currentFirebaseUser?.uid;
      final currentIds = list.map((e) => e.id).toSet();

      if (!_eventsInitialLoadDone) {
        _knownEventIds = currentIds;
        _eventsInitialLoadDone = true;
      } else if (currentUid != null) {
        final newIds = currentIds.difference(_knownEventIds);
        for (final id in newIds) {
          final evt = list.firstWhere((e) => e.id == id);
          if (evt.creatorUid != currentUid) {
            String creatorName = displayNameFor(evt.creatorUid);
            _notificationService.showEventNotification(
              id: NotificationService.generateId(evt.id),
              creatorName: creatorName,
              eventName: evt.title,
              eventDate: evt.start,
            );
          }
        }
        _knownEventIds = currentIds;
      }

      _events = list;
      // Quando cambiano gli eventi (es. aggiunta vacanza), ricalcoliamo i task se necessario
      _trySeed();
      _safeNotify();
    });

    _notesSub = organizeRepository.getStickyNotesStream(houseId).listen((list) {
      if (_disposed) return;
      _notes = list;
      _safeNotify();
    });

    _rulesSub = organizeRepository.getHouseRulesStream(houseId).listen((list) {
      if (_disposed) return;
      _rules = list;
      _safeNotify();
    });

    _recyclingSub = organizeRepository.getRecyclingScheduleStream(houseId).listen((map) {
      if (_disposed) return;
      _recyclingSchedule = map;
      _safeNotify();
    });

    _choreRoomsSub = organizeRepository.getChoreRoomsStream(houseId).listen((rooms) {
      if (_disposed) return;
      _choreRooms = rooms;
      _choreRoomsLoaded = true;
      _trySeed();
      _safeNotify();
    });

    _wasteResponsibleSub = organizeRepository.getWasteResponsibleStream(houseId).listen((data) {
      if (_disposed) return;
      _wasteResponsibleData = data;

      // --- Notifica se la responsabilità spazzatura è passata a me ---
      final currentUid = authRepository.currentFirebaseUser?.uid;
      final newResponsibleUid = data['uid'] as String?;
      if (currentUid != null &&
          newResponsibleUid == currentUid &&
          _lastWasteResponsibleUid != null &&
          _lastWasteResponsibleUid != currentUid) {
        final endOfWeek = _currentWeekStart().add(const Duration(days: 6));
        _notificationService.showChoreNotification(
          id: NotificationService.generateId('waste_$houseId'),
          choreName: 'Turno spazzatura settimana',
          dueDate: endOfWeek,
        );
      }
      _lastWasteResponsibleUid = newResponsibleUid;

      _safeNotify();
    });

    _wasteConfirmationSub = organizeRepository.getWasteConfirmationStream(houseId).listen((data) {
      if (_disposed) return;
      _wasteConfirmations = data;
      _safeNotify();
    });
  }

  void _watchHouseMembers(String houseId) {
    _houseSub?.cancel();
    _houseMembersSub?.cancel();
    _houseSub = houseRepository.getHouseStream(houseId).listen((house) {
      if (_disposed) return;
      _houseMembers = house?.membri ?? [];
      _houseMembersSub?.cancel();
      if (_houseMembers.isNotEmpty) {
        _houseMembersSub = _userRepository.getRoommatesStream(_houseMembers).listen((users) {
          if (_disposed) return;
          _houseMemberUsers = users;
          _safeNotify();

          // Se abbiamo sia la casa che gli utenti, facciamo il controllo!
          if (house != null) {
            checkAndResetMonthlyLeaderboard(house, users);
          }

        });
      } else {
        _houseMemberUsers = [];
      }
      _trySeed();
    });
  }

  /// Seed solo quando cleaning + choreRooms sono entrambi caricati
  void _trySeed() {
    if (_cleaningLoaded && _choreRoomsLoaded) {
      _seedWeeklyCleaningTasksIfNeeded();
    }
  }

  DateTime _currentWeekStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  bool _isCurrentWeek(DateTime weekStart) {
    final current = _currentWeekStart();
    return weekStart.year == current.year &&
        weekStart.month == current.month &&
        weekStart.day == current.day;
  }

  bool _seeding = false;
  bool _pendingReSeed = false;

  Future<void> _seedWeeklyCleaningTasksIfNeeded() async {
    final houseId = _houseId;
    if (houseId == null || _houseMembers.isEmpty) return;
    if (_seeding) {
      _pendingReSeed = true;
      return;
    }
    _seeding = true;
    try {
      do {
        _pendingReSeed = false;
        await _doSeed(houseId);
      } while (_pendingReSeed);
    } finally {
      _seeding = false;
    }
  }

  Future<void> _doSeed(String houseId) async {
    final currentWeekStart = _currentWeekStart();
    var currentWeekTasks = _cleaning.where((task) => _isCurrentWeek(task.weekStart)).toList();
    // Usa le stanze personalizzabili da Firestore
    final choreTitles = _choreRooms;

    // Auto-correzione: se ci sono task assegnati a utenti non più presenti in casa, riassegnali
    for (final task in _cleaning) {
      if (!_houseMembers.contains(task.assigneeUid)) {
        final newAssignee = _houseMembers.isNotEmpty ? _houseMembers.first : authRepository.currentFirebaseUser?.uid;
        if (newAssignee != null) {
          await organizeRepository.addOrUpdateCleaningTask(houseId, task.copyWith(assigneeUid: newAssignee));
        }
      }
    }

    // Rimuovi duplicati: se ci sono più task con lo stesso titolo nella stessa settimana, teniamo solo il primo
    final seenTitles = <String>{};
    for (final task in currentWeekTasks) {
      if (seenTitles.contains(task.title)) {
        // Duplicato — eliminiamo
        await organizeRepository.deleteCleaningTask(houseId, task.id);
      } else {
        seenTitles.add(task.title);
      }
    }
    // Dopo la pulizia, ricalcoliamo
    currentWeekTasks = currentWeekTasks.where((t) => seenTitles.contains(t.title)).toList();
    // Ricalcola senza duplicati
    final uniqueTasks = <String, CleaningTask>{};
    for (final task in currentWeekTasks) {
      uniqueTasks.putIfAbsent(task.title, () => task);
    }
    currentWeekTasks = uniqueTasks.values.toList();

    final weekIndex = currentWeekStart.difference(DateTime(2024, 1, 1)).inDays ~/ 7;
    
    // 1. ESCLUSIONE VACANZE: Creiamo una lista di coinquilini DISPONIBILI per questa settimana.
    // Gli utenti che hanno un evento "Assente" nel calendario vengono saltati.
    List<String> availableMembers = _houseMembers.where((uid) => !isUserAway(uid)).toList();
    
    // Fallback di sicurezza: se per qualche motivo risultano tutti in vacanza, usiamo tutti i membri.
    if (availableMembers.isEmpty) {
      availableMembers = List.from(_houseMembers);
    }

    // Se la casa è completamente vuota, interrompiamo.
    if (availableMembers.isEmpty) return;

    // Ricalcoliamo/Creiamo i task per ogni stanza definita.
    for (var i = 0; i < choreTitles.length; i++) {
      final title = choreTitles[i];

      // 2. FORMULA ROTAZIONE: Determina l'assegnatario in base alla settimana solare.
      // Assicura che ogni settimana l'assegnamento "scali" di una posizione.
      final globalTaskIndex = (weekIndex * choreTitles.length) + i;
      final assigneeIndex = globalTaskIndex % availableMembers.length;
      
      final idealAssignee = availableMembers[assigneeIndex];

      // Trova se c'è già un task per questa stanza nella settimana corrente.
      final existingTask = currentWeekTasks.where((t) => t.title == title).firstOrNull;

      if (existingTask == null) {
        // Se non esiste, lo creiamo da zero.
        await organizeRepository.addOrUpdateCleaningTask(
          houseId,
          CleaningTask(
            id: '',
            title: title,
            assigneeUid: idealAssignee,
            weekStart: currentWeekStart,
          ),
        );
      } else if (!existingTask.completed) {
        // 3. RIASSEGNAMENTO DINAMICO: Se il task esiste ma non è finito, 
        // controlliamo se l'assegnatario è andato in vacanza DOPO la creazione del task,
        // se ha lasciato la casa, o se la composizione della casa è cambiata (nuovo ingresso).
        final assigneeIsAway = isUserAway(existingTask.assigneeUid);
        final assigneeLeftHouse = !_houseMembers.contains(existingTask.assigneeUid);
        final needsRebalance = existingTask.assigneeUid != idealAssignee;

        if (assigneeIsAway || assigneeLeftHouse || needsRebalance) {
          await organizeRepository.addOrUpdateCleaningTask(
            houseId,
            existingTask.copyWith(assigneeUid: idealAssignee),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cleaningSub?.cancel();
    _shoppingSub?.cancel();
    _eventsSub?.cancel();
    _notesSub?.cancel();
    _rulesSub?.cancel();
    _authSub?.cancel();
    _profileSub?.cancel();
    _houseSub?.cancel();
    _houseMembersSub?.cancel();
    _choreRoomsSub?.cancel();
    _wasteResponsibleSub?.cancel();
    _wasteConfirmationSub?.cancel();
    super.dispose();
  }

  // OTTENIMENTO BADGE (Restituisce Map con i dati del Badge)
  Future<Map<String, dynamic>?> toggleTaskCompleted(String taskId, bool completed) async {
    if (_houseId == null) return null;

    // 1. Salva la pulizia nel database
    await organizeRepository.toggleCleaningTaskCompleted(_houseId!, taskId, completed);

    // 2. Se ha completato il task, avvia il motore dei badge e assegna punti
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid != null) {
      if (completed) {
        await _userRepository.addPoints(currentUid, 10);
        
        // Salviamo l'eventuale badge sbloccato in una variabile
        final unlockedBadge = await _userRepository.updateCleaningStreakAndCheckFire(currentUid);
        
        // ASSEGNAZIONE JOLLY SE HA SBLOCCATO IL BADGE
        if (unlockedBadge != null) {
          final userRef = FirebaseFirestore.instance.collection('users').doc(currentUid);
          await userRef.update({'jollies': FieldValue.increment(1)});
          
          _notificationService.showAchievementNotification(
            id: NotificationService.generateId('jolly_clean_${DateTime.now().millisecondsSinceEpoch}'),
            title: '🃏 Jolly Bonus Ottenuto!',
            body: 'Hai sbloccato un nuovo traguardo di pulizia e guadagnato 1 Jolly extra!',
          );
        }
        
        return unlockedBadge; // Ritorna il badge per mostrare il popup a schermo
      } else {
        await _userRepository.addPoints(currentUid, -10);
      }
    }
    return null;
  }

  Future<void> addCleaningTask(String title, String assigneeUid) async {
    if (_houseId == null || title.isEmpty) return;
    final task = CleaningTask(
      id: '',
      title: title,
      assigneeUid: assigneeUid,
      weekStart: _currentWeekStart(),
    );
    await organizeRepository.addOrUpdateCleaningTask(_houseId!, task);
  }

  Future<void> removeCleaningTask(String taskId) async {
    if (_houseId == null) return;
    await organizeRepository.deleteCleaningTask(_houseId!, taskId);
  }

  Future<void> reassignCleaningTask(String taskId, String newAssigneeUid) async {
    if (_houseId == null) return;
    final task = _cleaning.firstWhere((t) => t.id == taskId);
    await organizeRepository.addOrUpdateCleaningTask(
      _houseId!,
      task.copyWith(assigneeUid: newAssigneeUid),
    );
  }

  Future<void> addShoppingItem(ShoppingItem item) async {
    if (_houseId == null) return;
    await organizeRepository.addShoppingItem(_houseId!, item);
  }

  Future<bool> addShoppingItemByName(String name, {String quantity = ''}) async {
    if (_houseId == null) return false;

    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null || name.trim().isEmpty) return false;

    final item = ShoppingItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      quantity: quantity.trim(),
      addedByUid: currentUid,
      addedAt: DateTime.now(),
    );

    try {
      await organizeRepository.addShoppingItem(_houseId!, item);
      return true;
    } on FirebaseException catch (e) {
      debugPrint('Firestore shopping write failed: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Shopping item add failed: $e');
      return false;
    }
  }

  Future<void> markItemBought(String itemId, bool bought) async {
    if (_houseId == null) return;
    
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return;

    await organizeRepository.markItemBought(_houseId!, itemId, bought, currentUid);

    // Assegna o rimuovi i punti per lo shopping
    if (bought) {
      await _userRepository.addPoints(currentUid, 2);
    } else {
      await _userRepository.addPoints(currentUid, -2);
    }
  }

  Future<void> removeShoppingItem(String itemId) async {
    if (_houseId == null) return;
    await organizeRepository.deleteShoppingItem(_houseId!, itemId);
  }

  Future<Map<String, dynamic>?> addEvent(String title, DateTime start, {DateTime? end, String? notes}) async {
    if (_houseId == null || title.isEmpty) return null;
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return null;

    final event = HouseEvent(
      id: '',
      title: title,
      start: start,
      end: end,
      creatorUid: currentUid,
      notes: notes,
    );
    await organizeRepository.addOrUpdateEvent(_houseId!, event);

    // BADGE: PARTY PLANNER
    return await _userRepository.updateEventCountAndCheckPlanner(currentUid);
  }

  Future<void> addAbsenceEvent(String uid, DateTime until) async {
    if (_houseId == null) return;
    final userName = displayNameFor(uid);
    await addEvent(
      'Assente: $userName',
      DateTime.now(),
      end: until.add(const Duration(hours: 23, minutes: 59)),
      notes: 'absent_uid:$uid',
    );
  }

  Future<void> removeEvent(String eventId) async {
    if (_houseId == null) return;
    await organizeRepository.deleteEvent(_houseId!, eventId);
  }

  Future<void> updateRecyclingSchedule(Map<String, String> schedule) async {
    if (_houseId == null) return;
    await organizeRepository.updateRecyclingSchedule(_houseId!, schedule);
  }

  // GESTIONE STANZE PERSONALIZZABILI
  Future<void> addChoreRoom(String roomName) async {
    if (_houseId == null || roomName.trim().isEmpty) return;
    final trimmed = roomName.trim();
    if (_choreRooms.contains(trimmed)) return; // Già esiste
    final updated = [..._choreRooms, trimmed];
    await organizeRepository.updateChoreRooms(_houseId!, updated);
  }

  Future<void> removeChoreRoom(String roomName) async {
    if (_houseId == null) return;
    final updated = _choreRooms.where((r) => r != roomName).toList();
    if (updated.isEmpty) return; // Non svuotare la lista
    await organizeRepository.updateChoreRooms(_houseId!, updated);
  }

  // CONFERMA IMMONDIZIA OGGI + BADGE
  Future<Map<String, dynamic>?> confirmWasteTakenOut(String wasteType) async {
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return null;

    // Persisti la conferma su Firestore
    if (_houseId != null) {
      await organizeRepository.confirmWasteTakenOutToday(_houseId!, currentUid, wasteType);
    }
    
    // Aggiungi punti per aver buttato la spazzatura
    await _userRepository.addPoints(currentUid, 5);

    Map<String, dynamic>? specificBadge;

    // 1. Controlla i badge dei singoli bidoni
    if (wasteType == 'Plastica') {
      specificBadge = await _userRepository.updatePlasticCountAndCheckHero(currentUid);
    } else if (wasteType == 'Carta') {
      specificBadge = await _userRepository.updatePaperCountAndCheckHero(currentUid);
    } else if (wasteType == 'Vetro') {
      specificBadge = await _userRepository.updateGlassCountAndCheckLord(currentUid);
    } else if (wasteType == 'Umido' || wasteType == 'Organico') { 
      specificBadge = await _userRepository.updateCompostCountAndCheckKing(currentUid);
    } else if (wasteType == 'Indifferenziato' || wasteType == 'Indifferenziata' || wasteType == 'Secco') {
      specificBadge = await _userRepository.updateUnsortedCountAndCheckKing(currentUid);
    }

    // 2. Controlla SEMPRE la Streak "Eroe Green" a prescindere da quale bidone ha buttato
    Map<String, dynamic>? streakBadge = await _userRepository.updateGreenHeroStreak(currentUid);
    
    // 3. Uniamo il risultato per vedere se almeno un badge è stato sbloccato
    final unlockedBadge = specificBadge ?? streakBadge;
    
    if (unlockedBadge != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUid);
      await userRef.update({'jollies': FieldValue.increment(1)});
      
      _notificationService.showAchievementNotification(
        id: NotificationService.generateId('jolly_waste_${DateTime.now().millisecondsSinceEpoch}'),
        title: '🃏 Jolly Bonus Ottenuto!',
        body: 'Hai sbloccato un nuovo traguardo per la spazzatura e guadagnato 1 Jolly extra!',
      );
    }

    // Ritorna il badge per mostrarlo a schermo
    return unlockedBadge;
  }

  
  // GESTIONE JOLLY
  
  /// Usa un Jolly per saltare un turno di pulizie
  Future<bool> useJollyForCleaningTask(String taskId) async {
    final currentUser = authRepository.currentFirebaseUser;
    if (currentUser == null || _houseId == null) return false;

    final userProfile = appUserFor(currentUser.uid);
    if (userProfile == null || userProfile.jollies <= 0) return false;

    // 1. Consuma il jolly
    await _userRepository.consumeJolly(currentUser.uid);

    // 2. Segna il task come completato
    await organizeRepository.toggleCleaningTaskCompleted(_houseId!, taskId, true);
    
    return true; // Jolly usato con successo
  }

  /// Usa un Jolly per saltare il turno della spazzatura
  Future<bool> useJollyForWaste() async {
    final currentUser = authRepository.currentFirebaseUser;
    if (currentUser == null || _houseId == null) return false;

    final userProfile = appUserFor(currentUser.uid);
    if (userProfile == null || userProfile.jollies <= 0) return false;

    // 1. Consuma il jolly
    await _userRepository.consumeJolly(currentUser.uid);

    // 2. Trova il prossimo utente disponibile per la spazzatura
    String? nextUserUid;
    final currentIndex = _houseMembers.indexOf(currentUser.uid);
    if (currentIndex != -1) {
      for (int i = 1; i < _houseMembers.length; i++) {
        final candidateUid = _houseMembers[(currentIndex + i) % _houseMembers.length];
        if (!isUserAway(candidateUid)) {
          nextUserUid = candidateUid;
          break;
        }
      }
    }

    // 3. Riassegna la spazzatura forzatamente su Firestore per questa settimana
    if (nextUserUid != null) {
      await organizeRepository.updateWasteResponsible(_houseId!, nextUserUid, _currentWeekStart());
    }

    return true;
  }

  // RESET MENSILE DELLA CLASSIFICA + ASSEGNAZIONE JOLLY

  Future<void> checkAndResetMonthlyLeaderboard(House house, List<AppUser> roommates) async {
    final now = DateTime.now();
    final currentMonthString = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    if (house.leaderboardMonth != currentMonthString && !_isResettingLeaderboard) {
      
      _isResettingLeaderboard = true; // Lucchetto di sicurezza chiuso

      AppUser? winner;
      int maxPoints = -1;
      for (var user in roommates) {
        if (user.points > maxPoints) { 
          maxPoints = user.points;
          winner = user;
        }
      }

      final batch = FirebaseFirestore.instance.batch();
      final currentUid = authRepository.currentFirebaseUser?.uid;

      // 1. Assegna il Jolly al vincitore (se ha fatto almeno 1 punto)
      if (winner != null && maxPoints > 0) {
        final winnerRef = FirebaseFirestore.instance.collection('users').doc(winner.uid);
        batch.update(winnerRef, {'jollies': FieldValue.increment(1)});
      }

      // 2. Azzera i punti di tutti
      for (var user in roommates) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        batch.update(userRef, {'points': 0});
      }

      // 3. Aggiorna il mese della casa
      final houseRef = FirebaseFirestore.instance.collection('houses').doc(house.id);
      batch.update(houseRef, {'leaderboardMonth': currentMonthString});

      // 4. Invia tutto a Firebase
      try {
        await batch.commit();

        // 5. Se sei tu il vincitore, mostra e salva la notifica
        if (winner != null && winner.uid == currentUid && maxPoints > 0) {
          _notificationService.showAchievementNotification(
            id: NotificationService.generateId('monthly_winner_$currentMonthString'),
            title: '🏆 Campione del Mese!',
            body: 'Complimenti! Hai vinto la classifica del mese scorso e hai guadagnato 1 Jolly! 🃏',
          );
        }
      } catch (e) {
        debugPrint("Errore durante il reset mensile: $e");
      }
    }
  }
  
}