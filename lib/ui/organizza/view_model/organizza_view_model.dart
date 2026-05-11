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

  List<CleaningTask> _cleaning = [];
  List<ShoppingItem> _shopping = [];
  List<HouseEvent> _events = [];
  List<StickyNote> _notes = [];
  List<HouseRule> _rules = [];
  Map<String, String> _recyclingSchedule = {};
  bool _tomorrowWasteTakenOut = false;
  List<String> _houseMembers = [];
  List<AppUser> _houseMemberUsers = [];

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

  List<String> get houseMembers => List.unmodifiable(_houseMembers);

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

  String displayNameFor(String uid) {
    if (uid.isEmpty) return 'Qualcuno';
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (uid == currentUid) return 'Te';

    try {
      final user = _houseMemberUsers.firstWhere((element) => element.uid == uid);
      if (user.name.isNotEmpty) return user.name;
      return user.email;
    } catch (_) {
      return 'Coinquilino';
    }
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

  String get todayWaste => _getWasteForDay(DateTime.now());
  String get tomorrowWaste => _getWasteForDay(DateTime.now().add(const Duration(days: 1)));

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

    _cleaningSub = organizeRepository.getCleaningTasksStream(houseId).listen((list) {
      if (_disposed) return;
      _cleaning = list;
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
      _seedWeeklyCleaningTasksIfNeeded();
    });
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

  Future<void> _seedWeeklyCleaningTasksIfNeeded() async {
    final houseId = _houseId;
    if (houseId == null || _houseMembers.isEmpty) return;

    final currentWeekStart = _currentWeekStart();
    final currentWeekTasks = _cleaning.where((task) => _isCurrentWeek(task.weekStart)).toList();
    final choreTitles = ['Cucina', 'Bagno', 'Salotto'];

    if (currentWeekTasks.length >= choreTitles.length) return;

    final existingTitles = currentWeekTasks.map((task) => task.title).toSet();
    final weekIndex = currentWeekStart.difference(DateTime(2024, 1, 1)).inDays ~/ 7;

    for (var i = 0; i < choreTitles.length; i++) {
      final title = choreTitles[i];
      if (existingTitles.contains(title)) continue;

      final assigneeUid = _houseMembers[(weekIndex + i) % _houseMembers.length];
      await organizeRepository.addOrUpdateCleaningTask(
        houseId,
        CleaningTask(
          id: '',
          title: title,
          assigneeUid: assigneeUid,
          weekStart: currentWeekStart,
        ),
      );
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
        // Restituisce i metadati se ha appena sbloccato il badge, altrimenti null
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

  Future<void> addEvent(String title, DateTime start, {DateTime? end, String? notes}) async {
    if (_houseId == null || title.isEmpty) return;
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return;

    final event = HouseEvent(
      id: '',
      title: title,
      start: start,
      end: end,
      creatorUid: currentUid,
      notes: notes,
    );
    await organizeRepository.addOrUpdateEvent(_houseId!, event);
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
  // OTTENIMENTO BADGE: RACCOLTA DIFFERENZIATA (IL SET È ORA COMPLETO!)
  // ==========================================================
  Future<Map<String, dynamic>?> confirmWasteTakenOut(String wasteType) async {
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return null;

    if (wasteType == 'Plastica') {
      return await _userRepository.updatePlasticCountAndCheckHero(currentUid);
    } else if (wasteType == 'Carta') {
      return await _userRepository.updatePaperCountAndCheckHero(currentUid);
    } else if (wasteType == 'Vetro') {
      return await _userRepository.updateGlassCountAndCheckLord(currentUid);
    } else if (wasteType == 'Umido' || wasteType == 'Organico') { 
      return await _userRepository.updateCompostCountAndCheckKing(currentUid);
    } else if (wasteType == 'Indifferenziata' || wasteType == 'Secco') {
      return await _userRepository.updateUnsortedCountAndCheckKing(currentUid);
    }
    
    return null;
  }

  
}