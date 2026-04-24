import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/home_view_model.dart';
import '../../core/themes/app_colors.dart';
import 'dart:convert'; // Serve per decodificare l'immagine in base64
import '../../auth/view_model/auth_view_model.dart';

/// Schermata Home (dashboard). View pura che legge i dati da [HomeViewModel].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    // Ascoltiamo l'AuthViewModel per avere i dati dell'utente sempre aggiornati
    final authViewModel = context.watch<AuthViewModel>();
    final userProfile = authViewModel.userProfile;

    // Estraiamo nome e foto, mettendo valori di default se non ci sono
    final String nome = userProfile?.name ?? 'Utente';
    final String photoBase64 = userProfile?.photoUrl ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER (Profilo e Campanella) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // PARTE SINISTRA: Foto e Testi
                  Row(
                    children: [
                      // 1. La foto dinamica
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: photoBase64.isNotEmpty
                            ? MemoryImage(base64Decode(photoBase64))
                            : null,
                        child: photoBase64.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 28,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12), // Spazio tra foto e testo
                      // 2. I testi di benvenuto
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BENTORNATO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Ciao, $nome',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // PARTE DESTRA: Campanella
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 28),
                    onPressed: () {
                      // Azione notifiche (per il futuro)
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- CARD BILANCIO ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IL TUO BILANCIO',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          viewModel.balanceFormatted,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            viewModel.balanceStatus,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      viewModel.balanceDescription,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    LinearProgressIndicator(
                      value: viewModel.balanceProgress,
                      backgroundColor: Colors.grey[200],
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text('Vedi Dettagli'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                'DA FARE OGGI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),

              // --- TASK DAL VIEWMODEL ---
              ...viewModel.tasks.map(
                (task) => _buildTaskItem(
                  _getTaskIcon(task.iconName),
                  task.title,
                  task.subtitle,
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTaskIcon(String iconName) {
    switch (iconName) {
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'delete_outline':
        return Icons.delete_outline;
      default:
        return Icons.task_alt;
    }
  }

  Widget _buildTaskItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        ],
      ),
    );
  }
}
