import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/house_repository.dart';
import '../../../data/repositories/finance_repository.dart';
import '../../../data/repositories/organize_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/cleaning_task.dart';
import '../../../domain/models/shopping_item.dart';
import '../../../domain/models/house_event.dart';
import '../../../domain/models/sticky_note.dart';
import '../../../domain/models/transaction.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final HouseRepository _houseRepository;
  final FinanceRepository _financeRepository;
  final OrganizeRepository _organizeRepository;
  final UserRepository _userRepository;

  bool _isLoading = true;
  String _userName = '';
  String? _houseId;

  // Dati reali
  double _balance = 0.0;
  bool _isInCredit = true;

  String _choreToday = 'Nessuna faccenda';
  String _personToday = '-';

  List<StickyNote> _stickyNotes = [];
  List<ShoppingItem> _shoppingList = [];
  List<HouseEvent> _events = [];

  StreamSubscription? _userSub;
  StreamSubscription? _financeSub;
  StreamSubscription? _cleaningSub;
  StreamSubscription? _shoppingSub;
  StreamSubscription? _eventSub;
  StreamSubscription? _stickySub;

  HomeViewModel({
    required AuthRepository authRepository,
    required HouseRepository houseRepository,
    required FinanceRepository financeRepository,
    required OrganizeRepository organizeRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _houseRepository = houseRepository,
        _financeRepository = financeRepository,
        _organizeRepository = organizeRepository,
        _userRepository = userRepository {
    _init();
  }

  Future<void> _init() async {
    final user = _authRepository.currentFirebaseUser;
    if (user != null) {
      // Recupero iniziale del profilo per il nome
      final appUser = await _userRepository.getUserProfile(user.uid);
      _userName = appUser?.name ?? 'Utente';

      // Ascolta il profilo utente per intercettare il cambio o l'assegnazione della casa (homeId)
      _userSub = _userRepository.getUserProfileStream(user.uid).listen((updatedUser) {
        if (updatedUser != null && updatedUser.homeId.isNotEmpty) {
          if (_houseId != updatedUser.homeId) {
            _houseId = updatedUser.homeId;
            _subscribeToHouseData(updatedUser.homeId);
          }
        } else {
          _isLoading = false;
          _houseId = null;
          notifyListeners();
        }
      });
    }
  }

  void _subscribeToHouseData(String houseId) {
    _isLoading = true;
    notifyListeners();

    // 1. Bilancio
    _financeSub?.cancel();
    _financeSub = _financeRepository.getTransactionsStream(houseId).listen((transactions) {
      _calculateBalance(transactions);
      notifyListeners();
    });

    // 2. Faccende
    _cleaningSub?.cancel();
    _cleaningSub = _organizeRepository.getCleaningTasksStream(houseId).listen((List<CleaningTask> tasks) {
      if (tasks.isNotEmpty) {
        final activeTask = tasks.firstWhere((t) => !t.completed, orElse: () => tasks.first);
        _choreToday = activeTask.title;
        _fetchAssigneeName(activeTask.assigneeUid);
      }
      notifyListeners();
    });

    // 3. Post-it
    _stickySub?.cancel();
    _stickySub = _organizeRepository.getStickyNotesStream(houseId).listen((notes) {
      _stickyNotes = notes;
      notifyListeners();
    });

    // 4. Shopping
    _shoppingSub?.cancel();
    _shoppingSub = _organizeRepository.getShoppingListStream(houseId).listen((items) {
      // Filtriamo quelli non comprati
      final filtered = items.where((i) => !i.bought).toList();

      // Ordiniamo per data decrescente: i più recenti (data più grande) per primi
      filtered.sort((a, b) => b.addedAt.compareTo(a.addedAt));

      _shoppingList = filtered;
      notifyListeners();
    });

    // 5. Eventi
    _eventSub?.cancel();
    _eventSub = _organizeRepository.getEventsStream(houseId).listen((events) {
      _events = events.where((e) => e.start.isAfter(DateTime.now())).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _fetchAssigneeName(String uid) async {
    final userProfile = await _userRepository.getUserProfile(uid);
    if (userProfile != null) {
      _personToday = userProfile.name;
      notifyListeners();
    }
  }

  void _calculateBalance(List<AppTransaction> transactions) {
    final currentUserId = _authRepository.currentFirebaseUser?.uid;
    if (currentUserId == null) return;

    double total = 0.0;
    for (var tx in transactions) {
      if (tx.payerId == currentUserId) {
        if (tx.involvedUsers != null && tx.involvedUsers!.isNotEmpty) {
          double othersShare = tx.amount * (1 - (1 / tx.involvedUsers!.length));
          total += othersShare;
        }
      } else if (tx.involvedUsers?.contains(currentUserId) ?? false) {
        double myShare = tx.amount / (tx.involvedUsers!.length);
        total -= myShare;
      }
    }
    _balance = total;
    _isInCredit = _balance >= 0;
  }

  /// Crea una nuova Sticky Note (Post-it) condivisa tra tutti i membri della casa
  Future<void> addStickyNote(String content) async {
    if (_houseId == null || content.trim().isEmpty) return;
    
    final currentUid = _authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return;

    final note = StickyNote(
      id: '', // Sarà generato da Firestore
      content: content.trim(),
      authorUid: currentUid,
      createdAt: DateTime.now(),
    );

    await _organizeRepository.addStickyNote(_houseId!, note);
  }

  /// Elimina una Sticky Note (Post-it)
  Future<void> deleteStickyNote(String noteId) async {
    if (_houseId == null || noteId.isEmpty) return;
    await _organizeRepository.deleteStickyNote(_houseId!, noteId);
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _financeSub?.cancel();
    _cleaningSub?.cancel();
    _shoppingSub?.cancel();
    _eventSub?.cancel();
    _stickySub?.cancel();
    super.dispose();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get userName => _userName;
  double get balance => _balance.abs();
  bool get isInCredit => _isInCredit;
  String get choreToday => _choreToday;
  String get personToday => _personToday;
  List<StickyNote> get stickyNotes => _stickyNotes;
  List<ShoppingItem> get shoppingList => _shoppingList;
  List<HouseEvent> get events => _events;

  String get balanceFormatted => '€ ${balance.toStringAsFixed(2).replaceAll('.', ',')}';
  String get balanceStatus => _isInCredit ? 'OTTIMO' : 'ATTENZIONE';
  String get balanceDescription => _isInCredit ? 'Sei in credito' : 'Sei in debito';
  double get balanceProgress => (balance / 100).clamp(0.0, 1.0);
}