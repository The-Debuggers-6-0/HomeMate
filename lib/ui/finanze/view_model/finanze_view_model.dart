import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../domain/models/transaction.dart' as dm;
import '../../../domain/models/app_user.dart';
import '../../../data/repositories/finance_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/house_repository.dart';
import '../../../data/services/notification_service.dart';

class Transaction {
  final String title;
  final String subtitle;
  final String amount;
  final String amountLabel;
  final bool isCredit;
  final String? imageUrl;
  final String? category;
  final AppUser? payer;

  const Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountLabel,
    required this.isCredit,
    this.imageUrl,
    this.category,
    this.payer,
  });
}

class RoommateBalance {
  final AppUser user;
  final double balance; // > 0: they owe me, < 0: I owe them.

  const RoommateBalance({
    required this.user,
    required this.balance,
  });
}

class FinanzeViewModel extends ChangeNotifier {
  final FinanceRepository financeRepository;
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final HouseRepository houseRepository;

  bool _isLoading = true;
  String? _houseId;
  
  StreamSubscription? _houseSub;
  StreamSubscription? _roommatesSub;
  StreamSubscription? _transactionsSub;
  
  StreamSubscription? _authSub;
  StreamSubscription? _profileSub;
  bool _disposed = false;

  List<AppUser> _roommates = [];
  List<dm.AppTransaction> _appTransactions = [];

  // --- Servizio notifiche ---
  final NotificationService _notificationService = NotificationService();
  Set<String> _knownTransactionIds = {};
  bool _transactionsInitialLoadDone = false;

  void _safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  FinanzeViewModel({
    required this.financeRepository,
    required this.authRepository,
    required this.userRepository,
    required this.houseRepository,
  }) {
    _authSub = authRepository.authStateChanges().listen((user) {
      if (_disposed) return;

      if (user != null) {
        _isLoading = true;
        _safeNotify();
        
        // Ascolta il profilo utente per ottenere l'homeId sempre aggiornato
        _profileSub?.cancel();
        _profileSub = userRepository.getUserProfileStream(user.uid).listen((profile) {
          if (_disposed) return;

          if (profile != null && profile.homeId.isNotEmpty) {
            if (_houseId != profile.homeId) {
              _houseId = profile.homeId;
              _listenToHouseAndTransactions();
            }
          }
          _isLoading = false;
          _safeNotify();
        });
      } else {
        // Utente uscito: spegni tutto
        _houseId = null;
        _roommates = [];
        _appTransactions = [];
        _profileSub?.cancel();
        _houseSub?.cancel();
        _roommatesSub?.cancel();
        _transactionsSub?.cancel();
        _safeNotify();
      }
    });
  }

  void _listenToHouseAndTransactions() {
    if (_houseId == null) return;
    
    _transactionsSub?.cancel();
    // Reset tracker notifiche
    _transactionsInitialLoadDone = false;
    _knownTransactionIds = {};

    _transactionsSub = financeRepository.getTransactionsStream(_houseId!).listen((transactions) {
      if (_disposed) return;

      final currentUid = authRepository.currentFirebaseUser?.uid;
      final currentIds = transactions.map((t) => t.id).toSet();

      if (!_transactionsInitialLoadDone) {
        _knownTransactionIds = currentIds;
        _transactionsInitialLoadDone = true;
      } else if (currentUid != null) {
        final newIds = currentIds.difference(_knownTransactionIds);
        for (final id in newIds) {
          final t = transactions.firstWhere((tx) => tx.id == id);
          if (t.payerId != currentUid) {
            bool isReimbursement = t.type == 'rimborso' || t.category.toLowerCase() == 'rimborso';
            
            // Per le spese, notifica solo se il currentUid è incluso
            bool inInvolvedUsers = t.involvedUsers != null && t.involvedUsers!.contains(currentUid);
            // Per i rimborsi, la logica è che se non è il payer (è un coinquilino a pagare te)
            bool isGettingReimbursed = isReimbursement && t.receiverId == currentUid;

            // Se receiverId non esiste nel modello, proviamo con involvedUsers
            if (isReimbursement || inInvolvedUsers) {
              String payerName = 'Qualcuno';
              try {
                payerName = _roommates.firstWhere((r) => r.uid == t.payerId).name;
              } catch (_) {}
              
              _notificationService.showPaymentNotification(
                id: NotificationService.generateId(t.id),
                userOrCreatorName: payerName,
                amount: t.amount,
                description: t.title,
                isReimbursement: isReimbursement,
              );
            }
          }
        }
        _knownTransactionIds = currentIds;
      }

      _appTransactions = transactions;
      _safeNotify();
    });

    // Ascolta i coinquilini
    _houseSub = houseRepository.getHouseStream(_houseId!).listen((house) {
      if (_disposed) return;

      if (house != null && house.membri.isNotEmpty) {
        _roommatesSub?.cancel();
        _roommatesSub = userRepository.getRoommatesStream(house.membri).listen((users) {
          if (_disposed) return;

          _roommates = users;
          _safeNotify();
        });
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _authSub?.cancel();
    _profileSub?.cancel();
    _houseSub?.cancel();
    _roommatesSub?.cancel();
    _transactionsSub?.cancel();
    super.dispose();
  }

  // --- Funzioni ---
  Future<void> addExpense(
    String title, 
    double amount, 
    String category, 
    {List<String>? involvedUsers, Map<String, double>? customShares}
  ) async {
    if (_houseId == null) return;
    
    // Check di sicurezza: non salvare se non ci sono coinquilini caricati
    if (_roommates.isEmpty) return;

    final uid = authRepository.currentFirebaseUser?.uid ?? '';
    
    // Se involvedUsers non è passato, di default coinvolge tutti
    final usersToInvolve = involvedUsers ?? _roommates.map((r) => r.uid).toList();

    final newTransaction = dm.AppTransaction(
      id: '',
      title: title,
      amount: amount,
      date: DateTime.now(),
      payerId: uid,
      category: category,
      type: 'expense',
      involvedUsers: usersToInvolve,
      customShares: customShares,
    );
    await financeRepository.addTransaction(_houseId!, newTransaction);
  }

  Future<Map<String, dynamic>?> addReimbursement(String receiverId, double amount) async {
    if (_houseId == null) return null;
    final uid = authRepository.currentFirebaseUser?.uid ?? '';
    
    // --- 1. FOTOGRAFIA DEL DEBITO PRE-PAGAMENTO ---
    double debitoAttuale = 0.0;
    try {
      // roommateBalances ci dice i saldi. Se balance è negativo, vuol dire che IO devo soldi a LUI.
      final balanceObj = roommateBalances.firstWhere((b) => b.user.uid == receiverId);
      if (balanceObj.balance < 0) {
        debitoAttuale = balanceObj.balance.abs(); // lo facciamo diventare positivo per confrontarlo
      }
    } catch (_) {}

    // --- 2. SALVATAGGIO DELLA TRANSAZIONE ---
    final receiver = _roommates.firstWhere((r) => r.uid == receiverId);
    final newTransaction = dm.AppTransaction(
      id: '',
      title: 'Rimborso a ${receiver.name}',
      amount: amount,
      date: DateTime.now(),
      payerId: uid,
      category: 'Rimborso',
      type: 'reimbursement',
      receiverId: receiverId,
    );
    await financeRepository.addTransaction(_houseId!, newTransaction);

    // --- 3. GRILLETTO "SALDATORE SERIALE" (A prova di truffa!) ---
    // Il contatore scatta SOLO SE:
    // - C'era un debito vero (maggiore di 0.50€)
    // - L'importo pagato è maggiore o uguale al debito (usiamo -0.01 per tollerare gli arrotondamenti dei centesimi)
    if (uid.isNotEmpty && debitoAttuale > 0.5 && amount >= (debitoAttuale - 0.01)) {
      return await userRepository.updateFastPayerCountAndCheckBadge(uid);
    }

    return null;
  }

  // --- Getters per la UI ---
  bool get isLoading => _isLoading;

  // --- Totale Spese Mese Corrente ---
  String get currentMonthExpenses {
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return '€0.00';

    final now = DateTime.now();
    double total = 0.0;

    for (var t in _appTransactions) {
      if (t.type == 'expense' && t.date.year == now.year && t.date.month == now.month) {
        if (t.customShares != null && t.customShares!.isNotEmpty) {
           if (t.customShares!.containsKey(currentUid)) {
             total += t.customShares![currentUid]!;
           }
        } else {
           final involved = t.involvedUsers ?? _roommates.map((e) => e.uid).toList();
           if (involved.contains(currentUid)) {
             total += t.amount / involved.length;
           }
        }
      }
    }
    return '€${total.toStringAsFixed(2)}';
  }

  Map<String, double> get categoryDistribution {
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return {};

    final now = DateTime.now();
    Map<String, double> distribution = {};

    for (var t in _appTransactions) {
      if (t.type == 'expense' && t.date.year == now.year && t.date.month == now.month) {
        double myShare = 0.0;
        if (t.customShares != null && t.customShares!.isNotEmpty) {
          if (t.customShares!.containsKey(currentUid)) {
            myShare = t.customShares![currentUid]!;
          }
        } else {
          final involved = t.involvedUsers ?? _roommates.map((e) => e.uid).toList();
          if (involved.contains(currentUid)) {
            myShare = t.amount / involved.length;
          }
        }

        if (myShare > 0) {
          distribution[t.category] = (distribution[t.category] ?? 0.0) + myShare;
        }
      }
    }
    return distribution;
  }

  Map<int, double> get monthlyTrend {
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null) return {};

    final now = DateTime.now();
    Map<int, double> trend = {};
    
    // Inizializza gli ultimi 6 mesi
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      trend[date.month] = 0.0;
    }

    for (var t in _appTransactions) {
      if (t.type == 'expense') {
        final tDate = t.date;
        final monthKey = tDate.month;
        
        if (trend.containsKey(monthKey)) {
          double myShare = 0.0;
          if (t.customShares != null && t.customShares!.isNotEmpty) {
            if (t.customShares!.containsKey(currentUid)) {
              myShare = t.customShares![currentUid]!;
            }
          } else {
            final involved = t.involvedUsers ?? _roommates.map((e) => e.uid).toList();
            if (involved.contains(currentUid)) {
              myShare = t.amount / involved.length;
            }
          }
          trend[monthKey] = (trend[monthKey] ?? 0.0) + myShare;
        }
      }
    }
    return trend;
  }

  // Ritorna gli altri coinquilini
  List<AppUser> get roommates => _roommates.where((r) => r.uid != authRepository.currentFirebaseUser?.uid).toList();
  
  // Ritorna TUTTI i coinquilini (incluso l'utente corrente) per poter dividere la spesa
  List<AppUser> get allRoommates => List.unmodifiable(_roommates);

  List<RoommateBalance> get roommateBalances {
    final currentUid = authRepository.currentFirebaseUser?.uid;
    if (currentUid == null || _roommates.isEmpty) return [];

    Map<String, double> balances = {};
    for (var r in _roommates) {
      if (r.uid != currentUid) balances[r.uid] = 0.0;
    }

    for (var t in _appTransactions) {
      if (t.type == 'expense') {
        if (t.customShares != null && t.customShares!.isNotEmpty) {
          // --- DIVISIONE PERSONALIZZATA ---
          if (!t.customShares!.containsKey(currentUid) && t.payerId != currentUid) continue;

          if (t.payerId == currentUid) {
            // Ho pagato io. Gli altri mi devono la loro quota personalizzata.
            for (var entry in t.customShares!.entries) {
              final uid = entry.key;
              final share = entry.value;
              if (uid != currentUid && balances.containsKey(uid)) {
                balances[uid] = (balances[uid] ?? 0.0) + share;
              }
            }
          } else {
            // Ha pagato qualcun altro. Io gli devo la MIA quota personalizzata.
            if (t.customShares!.containsKey(currentUid)) {
              final myShare = t.customShares![currentUid]!;
              if (balances.containsKey(t.payerId)) {
                balances[t.payerId] = (balances[t.payerId] ?? 0.0) - myShare;
              }
            }
          }
        } else {
          // --- DIVISIONE IN PARTI UGUALI ---
          final involved = t.involvedUsers ?? _roommates.map((e) => e.uid).toList();
          if (!involved.contains(currentUid)) continue;

          double share = t.amount / involved.length;
          if (t.payerId == currentUid) {
            // Ho pagato io, gli altri (se presenti in balances) mi devono la loro quota
            for (var uid in involved) {
              if (uid != currentUid && balances.containsKey(uid)) {
                balances[uid] = (balances[uid] ?? 0.0) + share;
              }
            }
          } else {
            // Ha pagato qualcun altro, io gli devo la mia quota
            if (balances.containsKey(t.payerId)) {
              balances[t.payerId] = (balances[t.payerId] ?? 0.0) - share;
            }
          }
        }
      } else if (t.type == 'reimbursement') {
        if (t.payerId == currentUid && t.receiverId != null) {
          // Ho inviato io un rimborso, il mio debito diminuisce (ovvero il mio saldo sale)
          if (balances.containsKey(t.receiverId)) {
            balances[t.receiverId!] = (balances[t.receiverId!] ?? 0.0) + t.amount;
          }
        } else if (t.receiverId == currentUid) {
          // Ho ricevuto io un rimborso, il credito diminuisce (saldo scende)
          if (balances.containsKey(t.payerId)) {
            balances[t.payerId] = (balances[t.payerId] ?? 0.0) - t.amount;
          }
        }
      }
    }

    return balances.entries.map((e) {
      final user = _roommates.firstWhere((r) => r.uid == e.key);
      return RoommateBalance(user: user, balance: e.value);
    }).toList();
  }

  List<Transaction> get transactions {
    final currentUid = authRepository.currentFirebaseUser?.uid;
    
    // Mostriamo solo le transazioni che coinvolgono l'utente corrente
    final myTransactions = _appTransactions.where((t) {
      if (t.type == 'expense') {
        final involved = t.involvedUsers ?? _roommates.map((e) => e.uid).toList();
        return involved.contains(currentUid);
      } else if (t.type == 'reimbursement') {
        return t.payerId == currentUid || t.receiverId == currentUid;
      }
      return false;
    }).toList();

    return myTransactions.map((t) {
      final isMine = t.payerId == currentUid;
      final isReimbursement = t.type == 'reimbursement';
      
      String label;
      if (isReimbursement) {
        label = isMine ? 'INVIATO' : 'RICEVUTO';
      } else {
        label = isMine ? 'HAI PAGATO TU' : 'LA TUA QUOTA';
      }

      AppUser? payer;
      try {
        payer = _roommates.firstWhere((r) => r.uid == t.payerId);
      } catch (_) {
        // Se non lo troviamo nei coinquilini, potrebbe essere l'utente stesso
        if (t.payerId == currentUid) {
          // In teoria potremmo recuperare l'AppUser dell'utente corrente se necessario
        }
      }

      return Transaction(
        title: t.title,
        subtitle: '${t.date.day}/${t.date.month}/${t.date.year}',
        amount: '€${t.amount.toStringAsFixed(2)}',
        amountLabel: label,
        isCredit: isMine,
        category: t.category,
        payer: payer,
      );
    }).toList();
  }
}
