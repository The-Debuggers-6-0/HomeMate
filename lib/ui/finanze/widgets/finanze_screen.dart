import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/app_user.dart' as dm_user;
import '../view_model/finanze_view_model.dart';
import '../../core/themes/app_colors.dart';
import 'add_expense_screen.dart';
import 'settle_debt_screen.dart';
import '../../core/ui/custom_user_header.dart';
import '../../core/ui/user_avatar.dart';
import '../../core/ui/badge_popup.dart';
import '../../core/ui/clickable_user_avatar.dart';
import '../../main_layout/widgets/main_layout.dart';

/// Schermata Finanze. View pura che legge i dati da [FinanzeViewModel].
class FinanzeScreen extends StatefulWidget {
  final TabChangeNotifier tabNotifier;
  final int tabIndex;

  const FinanzeScreen({
    super.key,
    required this.tabNotifier,
    required this.tabIndex,
  });

  @override
  State<FinanzeScreen> createState() => _FinanzeScreenState();
}

class _FinanzeScreenState extends State<FinanzeScreen> {
  bool _showAllTransactions = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.tabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.tabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (widget.tabNotifier.currentTab == widget.tabIndex) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinanzeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.finanzeBackground,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 80.0,
        ), // Alza il pulsante sopra la bottom bar
        child: FloatingActionButton(
          backgroundColor: AppColors.primaryGreen,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                const CustomUserHeader(greetingText: 'LE TUE SPESE'),
                const SizedBox(height: 24),

                // --- CARD DEBITI (ORA SALDI COINQUILINI) ---
                const Text(
                  'I tuoi Saldi',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (viewModel.isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  )
                else if (viewModel.roommateBalances.isEmpty)
                  const Text(
                    'Nessun coinquilino trovato o nessun saldo.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ...viewModel.roommateBalances.map((rb) {
                    final isCredit = rb.balance > 0;
                    final isZero = rb.balance == 0;
                    final color = isZero
                        ? Colors.grey
                        : (isCredit ? AppColors.primaryGreen : Colors.red);
                    final prefix = isZero ? '' : (isCredit ? '+' : '');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClickableUserAvatar(
                            user: rb.user,
                            radius: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              rb.user.name.isNotEmpty
                                  ? rb.user.name
                                  : rb.user.email,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isCredit && !isZero) ...[
                            ElevatedButton(
                              onPressed: () async {
                                // <--- Aggiunto async
                                // 1. Aspetta il risultato (il badge) dalla pagina di pagamento
                                final newBadge = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettleDebtScreen(
                                      roommateUid: rb.user.uid,
                                      roommateName: rb.user.name.isNotEmpty
                                          ? rb.user.name
                                          : rb.user.email,
                                    ),
                                  ),
                                );

                                // 2. Se SettleDebtScreen ci ha restituito un badge, mostriamo il popup!
                                if (newBadge != null && context.mounted) {
                                  showGenericBadgePopup(
                                    context,
                                    newBadge as Map<String, dynamic>,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 0,
                                ),
                              ),
                              child: const Text(
                                'Paga',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$prefix€${rb.balance.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isZero
                                    ? 'In pari'
                                    : (isCredit ? 'Ti deve' : 'Gli devi'),
                                style: TextStyle(
                                  color: color.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 32),

                // --- SPESE TOTALI MESE ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Spese totali questo mese',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bar_chart,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        viewModel.currentMonthExpenses,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- TRANSAZIONI RECENTI ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transazioni Recenti',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // LISTA TRANSAZIONI DAL VIEWMODEL
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  )
                else if (viewModel.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Nessuna spesa ancora.\nAggiungi la prima tramite il pulsante +!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  )
                else ...[
                  ...viewModel.transactions
                      .take(
                        _showAllTransactions
                            ? viewModel.transactions.length
                            : 5,
                      )
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildTransactionItem(
                            t.title,
                            t.subtitle,
                            t.amount,
                            t.amountLabel,
                            isCredit: t.isCredit,
                            user: t.payer,
                            icon: t.isCredit
                                ? Icons.person
                                : Icons.shopping_bag,
                          ),
                        ),
                      ),

                  if (viewModel.transactions.length > 5 &&
                      !_showAllTransactions)
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAllTransactions = true;
                          });
                        },
                        icon: const Icon(
                          Icons.expand_more,
                          color: AppColors.primaryGreen,
                        ),
                        label: const Text(
                          'Visualizza tutte',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (_showAllTransactions && viewModel.transactions.length > 5)
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAllTransactions = false;
                          });
                        },
                        icon: const Icon(
                          Icons.expand_less,
                          color: AppColors.primaryGreen,
                        ),
                        label: const Text(
                          'Mostra meno',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 12),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String subtitle,
    String amount,
    String amountLabel, {
    required bool isCredit,
    dm_user.AppUser? user,
    IconData? icon,
  }) {
    return Row(
      children: [
        user != null
            ? ClickableUserAvatar(user: user, radius: 24)
            : UserAvatar(
                user: user,
                radius: 24,
                iconColor: AppColors.textSecondary,
              ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              amountLabel,
              style: TextStyle(
                color: isCredit ? AppColors.primaryDark : AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
