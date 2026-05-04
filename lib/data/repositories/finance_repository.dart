import '../../domain/models/transaction.dart';
import '../services/finance_service.dart';

/// Repository per gestire l'accesso ai dati delle finanze.
class FinanceRepository {
  final FinanceService _financeService;

  FinanceRepository({required FinanceService financeService})
      : _financeService = financeService;

  Future<void> addTransaction(String houseId, AppTransaction transaction) {
    return _financeService.addTransaction(houseId, transaction);
  }

  Stream<List<AppTransaction>> getTransactionsStream(String houseId) {
    return _financeService.getTransactionsStream(houseId);
  }
}
