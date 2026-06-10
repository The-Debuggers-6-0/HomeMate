import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/house_repository.dart';
import '../../../data/repositories/finance_repository.dart';
import '../../../data/repositories/organize_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/notification_service.dart';
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

  // Servizio notifiche (singleton)
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = true;
  String _userName = '';
  String _userPhotoUrl = '';
  String? _houseId;

  // Dati reali
  double _balance = 0.0;
  bool _isInCredit = true;
  // Mappa bilancio netto verso ogni altro membro (positivo = loro ti devono, negativo = tu devi a loro)
  final Map<String, double> _perPersonNet = {};

  String _choreToday = 'Nessuna faccenda';
  String _personToday = '-';
  bool _hasChoreForMe = false;

  List<StickyNote> _stickyNotes = [];
  List<ShoppingItem> _shoppingList = [];
  List<HouseEvent> _events = [];

  StreamSubscription? _userSub;
  StreamSubscription? _financeSub;
  StreamSubscription? _cleaningSub;
  StreamSubscription? _shoppingSub;
  StreamSubscription? _eventSub;
  StreamSubscription? _stickySub;

  // --- Tracking notifiche: ID già noti per ogni tipo di dato ---
  Set<String> _knownTransactionIds = {};
  Set<String> _knownShoppingIds = {};
  Set<String> _knownEventIds = {};
  Set<String> _knownNoteIds = {};
  bool _initialLoadComplete = false;
  int _initialLoadCount = 0; // Conta quanti stream hanno emesso il primo dato
  static const int _totalStreams = 4; // transactions, shopping, events, notes

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

  /// Segna un caricamento iniziale completato. Quando tutti gli stream hanno
  /// emesso almeno un dato, abilita le notifiche per i dati successivi.
  void _markInitialLoad() {
    if (_initialLoadComplete) return;
    _initialLoadCount++;
    if (_initialLoadCount >= _totalStreams) {
      _initialLoadComplete = true;
      debugPrint('[HomeViewModel] Caricamento iniziale completato — notifiche attive');
    }
  }

  Future<void> _init() async {
    final user = _authRepository.currentFirebaseUser;
    if (user != null) {
      // Ascolta il profilo utente per intercettare il cambio o l'assegnazione della casa (homeId)
      // e per aggiornare il nome in tempo reale
      _userSub = _userRepository.getUserProfileStream(user.uid).listen((updatedUser) {
        if (updatedUser != null) {
          _userName = updatedUser.name.isNotEmpty ? updatedUser.name : 'Utente';
          _userPhotoUrl = updatedUser.photoUrl ?? '';
          
          if (updatedUser.homeId.isNotEmpty) {
            if (_houseId != updatedUser.homeId) {
              _houseId = updatedUser.homeId;
              // Reset notifiche per la nuova casa
              _initialLoadComplete = false;
              _initialLoadCount = 0;
              _knownTransactionIds = {};
              _knownShoppingIds = {};
              _knownEventIds = {};
              _knownNoteIds = {};
              _subscribeToHouseData(updatedUser.homeId);
            }
          } else {
            _isLoading = false;
            _houseId = null;
          }
        } else {
          _isLoading = false;
          _houseId = null;
        }
        notifyListeners();
      });
    }
  }

  void _subscribeToHouseData(String houseId) {
    // Non resettiamo isLoading a true se avevamo già dei dati, per evitare flickering
    if (_houseId == null) _isLoading = true;
    notifyListeners();

    final currentUserId = _authRepository.currentFirebaseUser?.uid;

    // 1. Bilancio
    _financeSub?.cancel();
    _financeSub = _financeRepository.getTransactionsStream(houseId).listen((transactions) {
      // --- Notifiche per nuove transazioni ---
      final currentIds = transactions.map((t) => t.id).toSet();
      if (!_initialLoadComplete) {
        _knownTransactionIds = currentIds;
        _markInitialLoad();
      } else {
        final newIds = currentIds.difference(_knownTransactionIds);
        for (final id in newIds) {
          final tx = transactions.firstWhere((t) => t.id == id);
          // Notifica solo se non è stata creata dall'utente corrente
          if (tx.payerId != currentUserId) {
            _notificationService.show(
              id: NotificationService.generateId(tx.id),
              title: '💰 Nuova spesa',
              body: '${tx.title} — €${tx.amount.toStringAsFixed(2)}',
            );
          }
        }
        _knownTransactionIds = currentIds;
      }

      _calculateBalance(transactions);
      _isLoading = false; // Caricato almeno un modulo importante
      notifyListeners();
    });

    // 2. Faccende (Sincronizzato con la logica di Organizza)
    _cleaningSub?.cancel();
    _cleaningSub = _organizeRepository.getCleaningTasksStream(houseId).listen((List<CleaningTask> tasks) {
      final now = DateTime.now();
      final currentWeekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));

      // Prendiamo solo i task della settimana corrente
      final currentTasks = tasks.where((t) {
        return t.weekStart.year == currentWeekStart.year &&
               t.weekStart.month == currentWeekStart.month &&
               t.weekStart.day == currentWeekStart.day;
      }).toList();

      if (currentTasks.isNotEmpty && currentUserId != null) {
        // Troviamo tutte le faccende non completate assegnate a questo utente
        final myTasks = currentTasks.where((t) => !t.completed && t.assigneeUid == currentUserId).toList();
        if (myTasks.isNotEmpty) {
          _hasChoreForMe = true;
          // Uniamo i titoli per mostrare cosa deve fare l'utente
          _choreToday = myTasks.map((t) => t.title).join(', ');
        } else {
          // Non ho faccende questa settimana per l'utente
          _hasChoreForMe = false;
          _choreToday = 'Nessuna faccenda';
        }
      } else {
        _choreToday = 'Nessuna faccenda';
        _personToday = '-';
        _hasChoreForMe = false;
      }
      notifyListeners();
    });

    _stickySub?.cancel();
    _stickySub = _organizeRepository.getStickyNotesStream(houseId).listen((notes) {
      // --- Notifiche per nuove ---
      final currentIds = notes.map((n) => n.id).toSet();
      if (!_initialLoadComplete) {
        _knownNoteIds = currentIds;
        _markInitialLoad();
      } else {
        final newIds = currentIds.difference(_knownNoteIds);
        for (final id in newIds) {
          final note = notes.firstWhere((n) => n.id == id);
          if (note.authorUid != currentUserId) {
            _notificationService.show(
              id: NotificationService.generateId(note.id),
              title: '📝 Nuovo post-it',
              body: '${note.authorName}: ${note.content}',
            );
          }
        }
        _knownNoteIds = currentIds;
      }

      _stickyNotes = notes;
      notifyListeners();
    });

    // 4. Shopping
    _shoppingSub?.cancel();
    _shoppingSub = _organizeRepository.getShoppingListStream(houseId).listen((items) {
      // --- Notifiche per nuovi articoli nella lista della spesa ---
      final currentIds = items.map((i) => i.id).toSet();
      if (!_initialLoadComplete) {
        _knownShoppingIds = currentIds;
        _markInitialLoad();
      } else {
        final newIds = currentIds.difference(_knownShoppingIds);
        for (final id in newIds) {
          final item = items.firstWhere((i) => i.id == id);
          if (item.addedByUid != currentUserId) {
            _notificationService.show(
              id: NotificationService.generateId(item.id),
              title: '🛒 Lista della spesa',
              body: 'Aggiunto: ${item.name}${item.quantity.isNotEmpty ? ' (${item.quantity})' : ''}',
            );
          }
        }
        _knownShoppingIds = currentIds;
      }

      final filtered = items.where((i) => !i.bought).toList();
      filtered.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      _shoppingList = filtered;
      notifyListeners();
    });

    // 5. Eventi (Inclusi quelli di oggi)
    _eventSub?.cancel();
    _eventSub = _organizeRepository.getEventsStream(houseId).listen((events) {
      // --- Notifiche per nuovi eventi ---
      final currentIds = events.map((e) => e.id).toSet();
      if (!_initialLoadComplete) {
        _knownEventIds = currentIds;
        _markInitialLoad();
      } else {
        final newIds = currentIds.difference(_knownEventIds);
        for (final id in newIds) {
          final event = events.firstWhere((e) => e.id == id);
          if (event.creatorUid != currentUserId) {
            _notificationService.show(
              id: NotificationService.generateId(event.id),
              title: '📅 Nuovo evento',
              body: event.title,
            );
          }
        }
        _knownEventIds = currentIds;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      _events = events.where((e) {
        final eventDate = DateTime(e.start.year, e.start.month, e.start.day);
        return eventDate.isAtSameMomentAs(today) || e.start.isAfter(today);
      }).toList();
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

    _perPersonNet.clear();

    for (var tx in transactions) {
      if (tx.type == 'expense') {
        if (tx.customShares != null && tx.customShares!.isNotEmpty) {
          // --- DIVISIONE PERSONALIZZATA ---
          if (tx.payerId == currentUserId) {
            // Ho pagato io. Gli altri mi devono la loro quota specifica.
            tx.customShares!.forEach((uid, share) {
              if (uid != currentUserId) {
                _perPersonNet[uid] = (_perPersonNet[uid] ?? 0.0) + share;
              }
            });
          } else if (tx.customShares!.containsKey(currentUserId)) {
            // Ha pagato qualcun altro. Io gli devo la MIA quota specifica.
            final myShare = tx.customShares![currentUserId]!;
            _perPersonNet[tx.payerId] = (_perPersonNet[tx.payerId] ?? 0.0) - myShare;
          }
        } else {
          // --- DIVISIONE IN PARTI UGUALI ---
          final involved = tx.involvedUsers ?? [];
          if (involved.isEmpty) continue;
          if (!involved.contains(currentUserId) && tx.payerId != currentUserId) continue;

          double share = tx.amount / involved.length;
          if (tx.payerId == currentUserId) {
            // Ho pagato io. Tutti gli altri coinvolti mi devono 'share'.
            for (var uid in involved) {
              if (uid != currentUserId) {
                _perPersonNet[uid] = (_perPersonNet[uid] ?? 0.0) + share;
              }
            }
          } else if (involved.contains(currentUserId)) {
            // Ha pagato qualcun altro. Io gli devo la mia parte.
            _perPersonNet[tx.payerId] = (_perPersonNet[tx.payerId] ?? 0.0) - share;
          }
        }
      } else if (tx.type == 'reimbursement') {
        // --- RIMBORSI ---
        if (tx.payerId == currentUserId && tx.receiverId != null) {
          // Ho inviato un rimborso (riduco il mio debito)
          _perPersonNet[tx.receiverId!] = (_perPersonNet[tx.receiverId!] ?? 0.0) + tx.amount;
        } else if (tx.receiverId == currentUserId) {
          // Ho ricevuto un rimborso (riduco il mio credito)
          _perPersonNet[tx.payerId] = (_perPersonNet[tx.payerId] ?? 0.0) - tx.amount;
        }
      }
    }

    // Il saldo totale è la somma algebrica dei rapporti con ogni coinquilino
    _balance = _perPersonNet.values.fold(0.0, (sum, val) => sum + val);
    _isInCredit = _balance >= -0.01; // Tolleranza per arrotondamenti
  }

  /// Totale dei soldi che gli altri devono a te
  double get totalCredit => _perPersonNet.values.where((v) => v > 0.01).fold(0.0, (sum, v) => sum + v);

  /// Totale dei soldi che tu devi agli altri
  double get totalDebt => _perPersonNet.values.where((v) => v < -0.01).fold(0.0, (sum, v) => sum + v.abs());

  /// Numero di persone a cui devi soldi (sei in debito con loro)
  int get numPeopleYouOwe => _perPersonNet.values.where((v) => v < -0.01).length;

  /// Numero di persone che ti devono soldi
  int get numPeopleWhoOweYou => _perPersonNet.values.where((v) => v > 0.01).length;

  /// Crea una nuova Sticky Note (Post-it) condivisa tra tutti i membri della casa
  Future<void> addStickyNote(String content) async {
    if (_houseId == null || content.trim().isEmpty) return;
    
    final currentUid = _authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return;

    final note = StickyNote(
      id: '', // Sarà generato da Firestore
      content: content.trim(),
      authorUid: currentUid,
      authorName: _userName.isNotEmpty ? _userName : 'Coinquilino',
      authorPhotoUrl: _userPhotoUrl,
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
  bool get hasChoreForMe => _hasChoreForMe;
  List<StickyNote> get stickyNotes => _stickyNotes;
  List<ShoppingItem> get shoppingList => _shoppingList;
  List<HouseEvent> get events => _events;

  String get balanceFormatted => '€ ${balance.toStringAsFixed(2).replaceAll('.', ',')}';
  String get balanceStatus => _isInCredit ? 'OTTIMO' : 'ATTENZIONE';
  String get balanceDescription => _isInCredit ? 'Sei in credito' : 'Sei in debito';
  double get balanceProgress => (balance / 100).clamp(0.0, 1.0);
}