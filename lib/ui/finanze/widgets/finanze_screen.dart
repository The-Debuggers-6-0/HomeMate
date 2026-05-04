import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/finanze_view_model.dart';
import '../../core/themes/app_colors.dart';
import 'add_expense_screen.dart';
import 'settle_debt_screen.dart';
import '../../core/ui/custom_user_header.dart';

/// Schermata Finanze. View pura che legge i dati da [FinanzeViewModel].
class FinanzeScreen extends StatelessWidget {
  const FinanzeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinanzeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.finanzeBackground,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0), // Alza il pulsante sopra la bottom bar
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
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                const CustomUserHeader(
                  greetingText: 'FINANZE DELLA CASA',
                ),
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
                  const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                else if (viewModel.roommateBalances.isEmpty)
                  const Text('Nessun coinquilino trovato o nessun saldo.', style: TextStyle(color: Colors.grey))
                else
                  ...viewModel.roommateBalances.map((rb) {
                    final isCredit = rb.balance > 0;
                    final isZero = rb.balance == 0;
                    final color = isZero ? Colors.grey : (isCredit ? AppColors.primaryGreen : Colors.red);
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
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: rb.user.photoUrl != null ? NetworkImage(rb.user.photoUrl!) : null,
                            child: rb.user.photoUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              rb.user.name.isNotEmpty ? rb.user.name : rb.user.email,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
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
                                isZero ? 'In pari' : (isCredit ? 'Ti deve' : 'Gli devi'),
                                style: TextStyle(
                                  color: color.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (!isCredit && !isZero) ...[
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SettleDebtScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              ),
                              child: const Text('Paga', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
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
                    Text(
                      'Vedi tutto',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // LISTA TRANSAZIONI DAL VIEWMODEL
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
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
                else
                  ...viewModel.transactions.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildTransactionItem(
                          t.title,
                          t.subtitle,
                          t.amount,
                          t.amountLabel,
                          isCredit: t.isCredit,
                          imageUrl: t.imageUrl,
                          icon: t.isCredit ? Icons.person : Icons.shopping_bag,
                        ),
                      )),

                const SizedBox(height: 12),

                // --- WIDGET BUDGET & RISPARMIATI ---
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: AppColors.iconBgBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.pie_chart,
                                      color: AppColors.primaryDark),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    viewModel.budgetPercentage,
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Budget Mensile',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              viewModel.budgetAmount,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: AppColors.iconBgBeige,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.savings,
                                      color: AppColors.progressBrown),
                                ),
                                const Icon(Icons.arrow_upward,
                                    color: AppColors.textSecondary, size: 16),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Risparmiati',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              viewModel.savingsAmount,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

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
    String? imageUrl,
    IconData? icon,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[200],
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null
              ? Icon(icon, color: AppColors.textSecondary)
              : null,
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
                color:
                    isCredit ? AppColors.primaryDark : AppColors.textPrimary,
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
