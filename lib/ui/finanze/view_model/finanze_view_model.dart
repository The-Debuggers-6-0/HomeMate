import 'package:flutter/foundation.dart';

/// Classe che rappresenta una transazione finanziaria.
class Transaction {
  final String title;
  final String subtitle;
  final String amount;
  final String amountLabel;
  final bool isCredit;
  final String? imageUrl;

  const Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountLabel,
    required this.isCredit,
    this.imageUrl,
  });
}

/// ViewModel per la schermata Finanze.
/// Attualmente fornisce dati mock, pronto per collegamento futuro a Firestore.
class FinanzeViewModel extends ChangeNotifier {
  final bool _isLoading = false;

  // Dati mock per la sezione debiti
  final String _debtSummary = 'Ti bastano €25,00 a Giulia\nper saldare tutto';
  final double _debtProgress = 0.75;
  final String _debtProgressLabel = 'Mese quasi saldato';

  // Dati mock per budget
  final String _budgetAmount = '€342,00';
  final String _budgetPercentage = '64%';
  final String _savingsAmount = '€128,40';

  // Transazioni mock
  final List<Transaction> _transactions = const [
    Transaction(
      title: 'Spesa Carrefour',
      subtitle: 'Pagato da Giulia • 2 ore fa',
      amount: '€12,50',
      amountLabel: 'LA TUA QUOTA',
      isCredit: false,
      imageUrl: 'https://i.pravatar.cc/150?img=5',
    ),
    Transaction(
      title: 'Bolletta Luce',
      subtitle: 'Pagato da Marco • Ieri',
      amount: '€45,80',
      amountLabel: 'LA TUA QUOTA',
      isCredit: false,
      imageUrl: 'https://i.pravatar.cc/150?img=11',
    ),
    Transaction(
      title: 'Netflix Premium',
      subtitle: 'Pagato da Te • 3 giorni fa',
      amount: '€4,50',
      amountLabel: 'DA RICEVERE',
      isCredit: true,
    ),
  ];

  // --- Getters pubblici ---
  bool get isLoading => _isLoading;
  String get debtSummary => _debtSummary;
  double get debtProgress => _debtProgress;
  String get debtProgressLabel => _debtProgressLabel;
  String get budgetAmount => _budgetAmount;
  String get budgetPercentage => _budgetPercentage;
  String get savingsAmount => _savingsAmount;
  List<Transaction> get transactions => _transactions;
}
