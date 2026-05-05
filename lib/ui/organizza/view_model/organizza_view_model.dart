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
  StreamSubscription<House?>? _houseSub;
  StreamSubscription<List<AppUser>>? _houseMembersSub;

  List<CleaningTask> _cleaning = [];
  List<ShoppingItem> _shopping = [];
  List<HouseEvent> _events = [];
  List<StickyNote> _notes = [];
  List<HouseRule> _rules = [];
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
  List<CleaningTask> get cleaning => List.unmodifiable(_cleaning);
  List<CleaningTask> get currentWeekCleaningTasks => List.unmodifiable(
        _cleaning.where((task) => _isCurrentWeek(task.weekStart)).toList(),
      );
  List<ShoppingItem> get shopping => List.unmodifiable(_shopping);
  List<HouseEvent> get events => List.unmodifiable(_events);
  List<StickyNote> get notes => List.unmodifiable(_notes);
  List<HouseRule> get rules => List.unmodifiable(_rules);

  String displayNameFor(String uid) {
    try {
      final user = _houseMemberUsers.firstWhere((element) => element.uid == uid);
      if (user.name.isNotEmpty) return user.name;
      return user.email;
    } catch (_) {
      return 'Coinquilino';
    }
  }

  late final UserRepository _userRepository;

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
            // user has no house
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
        // user logged out
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

  void startListening(String houseId) {
    _houseId = houseId;
    _cleaningSub?.cancel();
    _shoppingSub?.cancel();
    _eventsSub?.cancel();
    _notesSub?.cancel();
    _rulesSub?.cancel();

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

  // Azioni di esempio
  Future<void> toggleTaskCompleted(String taskId, bool completed) async {
    if (_houseId == null) return;
    await organizeRepository.toggleCleaningTaskCompleted(_houseId!, taskId, completed);
  }

  Future<void> addShoppingItem(ShoppingItem item) async {
    if (_houseId == null) return;
    await organizeRepository.addShoppingItem(_houseId!, item);
  }

  Future<bool> addShoppingItemByName(String name) async {
    if (_houseId == null) return false;

    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null || name.trim().isEmpty) return false;

    final item = ShoppingItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
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
    await organizeRepository.markItemBought(_houseId!, itemId, bought);
  }
}
