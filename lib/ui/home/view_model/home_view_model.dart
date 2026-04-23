import 'package:flutter/foundation.dart';

/// Classe che rappresenta un task della dashboard.
class HomeTask {
  final String title;
  final String subtitle;
  final String iconName;

  const HomeTask({
    required this.title,
    required this.subtitle,
    required this.iconName,
  });
}

/// ViewModel per la schermata Home (dashboard).
/// Attualmente fornisce dati mock, pronto per collegamento futuro a Firestore.
class HomeViewModel extends ChangeNotifier {
  final bool _isLoading = false;

  // Dati mock per la dashboard
  final String _userName = 'Marco';
  final double _balance = 42.50;
  final double _balanceProgress = 0.7;
  final bool _isInCredit = true;

  final List<HomeTask> _tasks = const [
    HomeTask(
      title: 'Pulizia del corridoio',
      subtitle: 'Scade alle 18:00',
      iconName: 'cleaning_services',
    ),
    HomeTask(
      title: 'Uscire la spazzatura',
      subtitle: 'Umido e Plastica',
      iconName: 'delete_outline',
    ),
  ];

  // --- Getters pubblici ---
  bool get isLoading => _isLoading;
  String get userName => _userName;
  double get balance => _balance;
  double get balanceProgress => _balanceProgress;
  bool get isInCredit => _isInCredit;
  List<HomeTask> get tasks => _tasks;

  String get balanceFormatted => '€ ${_balance.toStringAsFixed(2).replaceAll('.', ',')}';
  String get balanceStatus => _isInCredit ? 'OTTIMO' : 'ATTENZIONE';
  String get balanceDescription => _isInCredit ? 'Sei in credito' : 'Sei in debito';
}
