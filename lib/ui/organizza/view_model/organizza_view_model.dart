import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/house.dart';
import '../../../data/repositories/organize_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/house_repository.dart';
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

  bool isUserAway(String uid) {
    final now = DateTime.now();

    return _events.any((event) {
      final notes = event.notes ?? '';

      // Formato nuovo: absent_uid:UID (affidabile, UID diretto)
      if (notes.startsWith('absent_uid:')) {
        final absentUid = notes.replaceFirst('absent_uid:', '').trim();
        if (absentUid != uid) return false;
        return _isEventActive(event, now);
      }

      // Formato legacy: keyword matching sul titolo
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

  String? get currentWasteResponsibleUid {
    // Se abbiamo un responsabile persistito per questa settimana, usiamo quello
    if (_wasteResponsibleData.isNotEmpty) {
      final storedWeekStart = _wasteResponsibleData['weekStart'] as String?;
      if (storedWeekStart != null) {
        final storedDate = DateTime.tryParse(storedWeekStart);
        if (storedDate != null && _isCurrentWeek(storedDate)) {
          return _wasteResponsibleData['uid'] as String?;
        }
      }
    }

    // Altrimenti calcoliamo e persistiamo
    if (_houseMembers.isEmpty) return null;
    final weekIndex = _currentWeekStart().difference(DateTime(2024, 1, 1)).inDays ~/ 7;
    
    String? responsibleUid;
    for (int i = 0; i < _houseMembers.length; i++) {
      final candidateUid = _houseMembers[(weekIndex + 2 + i) % _houseMembers.length];
      if (!isUserAway(candidateUid)) {
        responsibleUid = candidateUid;
        break;
      }
    }
    responsibleUid ??= _houseMembers[(weekIndex + 2) % _houseMembers.length];

    // Persisti su Firestore
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
    return isToday ? 'Non dimenticare!' : 'Ricordati di uscire il sacco!';
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

    _cleaningSub = organizeRepository.getCleaningTasksStream(houseId).listen((list) {
      if (_disposed) return;
      _cleaning = list;
      _cleaningLoaded = true;
      _trySeed();
      _safeNotify();
    });

    _shoppingSub = organizeRepository.getShoppingListStream(houseId).listen((list) {
      if (_disposed) return;
      _shopping = list;
      _safeNotify();
    });

    _eventsSub = organizeRepository.getEventsStream(houseId).listen((list) {
      if (_disposed) return;
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

    // =========================================================================
    // --- (Round Robin Continuo) ---
    // =========================================================================
    
    // 1. Creiamo una lista di coinquilini DISPONIBILI per questa settimana
    List<String> availableMembers = _houseMembers.where((uid) => !isUserAway(uid)).toList();
    
    // Fallback di sicurezza: se per qualche motivo risultano tutti in vacanza, usiamo tutti i membri
    if (availableMembers.isEmpty) {
      availableMembers = List.from(_houseMembers);
    }

    // Se la casa è completamente vuota, interrompiamo
    if (availableMembers.isEmpty) return;

    // Ricalcoliamo/Creiamo i task per ogni stanza
    for (var i = 0; i < choreTitles.length; i++) {
      final title = choreTitles[i];

      // 2. La formula magica della rotazione!
      final globalTaskIndex = (weekIndex * choreTitles.length) + i;
      final assigneeIndex = globalTaskIndex % availableMembers.length;
      
      final idealAssignee = availableMembers[assigneeIndex];

      // Trova se c'è già un task per questa stanza
      final existingTask = currentWeekTasks.where((t) => t.title == title).firstOrNull;

      if (existingTask == null) {
        // Se non esiste, lo creiamo
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
        // Riassegna solo se l'assegnatario corrente è assente o non è più in casa.
        // Non sovrascrivere le riassegnazioni manuali fatte dall'utente.
        final assigneeIsAway = isUserAway(existingTask.assigneeUid);
        final assigneeLeftHouse = !_houseMembers.contains(existingTask.assigneeUid);
        if (assigneeIsAway || assigneeLeftHouse) {
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

  // ==========================================================
  // OTTENIMENTO BADGE (Restituisce Map con i dati del Badge)
  // ==========================================================
  Future<Map<String, dynamic>?> toggleTaskCompleted(String taskId, bool completed) async {
    if (_houseId == null) return null;

    // 1. Salva la pulizia nel database
    await organizeRepository.toggleCleaningTaskCompleted(_houseId!, taskId, completed);

    // 2. Se ha completato il task, avvia il motore dei badge
    if (completed) {
      final currentUid = authRepository.currentFirebaseUser?.uid;
      if (currentUid != null) {
        return await _userRepository.updateCleaningStreakAndCheckFire(currentUid);
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
  }

  Future<void> removeShoppingItem(String itemId) async {
    if (_houseId == null) return;
    await organizeRepository.deleteShoppingItem(_houseId!, itemId);
  }

  // Cambiamo da Future<void> a Future<Map<String, dynamic>?> per restituire il badge
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

    // ==========================================================
    // BADGE: PARTY PLANNER
    // ==========================================================
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

  // ==========================================================
  // GESTIONE STANZE PERSONALIZZABILI
  // ==========================================================
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

  // ==========================================================
  // CONFERMA IMMONDIZIA OGGI + BADGE
  // ==========================================================
  Future<Map<String, dynamic>?> confirmWasteTakenOut(String wasteType) async {
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return null;

    // Persisti la conferma su Firestore
    if (_houseId != null) {
      await organizeRepository.confirmWasteTakenOutToday(_houseId!, currentUid, wasteType);
    }

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

    // 2. Controlla SEMPRE la Streak "Eroe Green" a prescindere da quale bidone ha buttato!
    Map<String, dynamic>? streakBadge = await _userRepository.updateGreenHeroStreak(currentUid);
    
    // Se ha sbloccato il badge del bidone specifico mostra quello, altrimenti mostra l'Eroe Green
    return specificBadge ?? streakBadge;
  }

  
}