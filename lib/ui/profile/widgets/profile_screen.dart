import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/profile_view_model.dart';
import '../../core/themes/app_colors.dart';
import 'edit_profile_screen.dart';
import '../../auth/view_model/auth_view_model.dart';
import 'dart:convert';

/// Schermata Profilo. View pura che legge i dati da [ProfileViewModel].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    if (viewModel.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // --- HEADER: Ciao, Nome ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Ciao, ${viewModel.displayName}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.notifications_none, color: AppColors.primaryGreen),
                ],
              ),
              const SizedBox(height: 48),

              // --- FOTO PROFILO CENTRALE ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGreen, width: 3),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,

                  // 1. ORA CONTROLLIAMO SE C'È UNA FOTO SALVATA!
                  // Sostituisci 'photoUrl' col nome esatto che hai nel tuo modello AppUser
                  backgroundImage:
                      (viewModel.userProfile?.photoUrl != null &&
                          viewModel.userProfile!.photoUrl!.isNotEmpty)
                      ? MemoryImage(
                          base64Decode(viewModel.userProfile!.photoUrl!),
                        )
                      : null,

                  // 2. MOSTRA L'ICONA SOLO SE LA FOTO NON C'È
                  child:
                      (viewModel.userProfile?.photoUrl == null ||
                          viewModel.userProfile!.photoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              // --- NOME E COGNOME ---
              Text(
                viewModel.fullName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // --- BIO / EMAIL ---
              Text(
                viewModel.bio,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),

              const SizedBox(
                height: 24,
              ), // Spazio tra la bio e il nuovo bottone


              // --- PULSANTE MODIFICA PROFILO ---
              OutlinedButton.icon(
                onPressed: () async {
                  // 1. Apri la pagina e aspetta che l'utente finisca e la chiuda
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        currentName: viewModel.userProfile?.name ?? '',
                        currentSurname: viewModel.userProfile?.surname ?? '',
                        currentBio: viewModel.userProfile?.bio ?? '',
                        currentPhotoUrl: viewModel.userProfile?.photoUrl,
                      ),
                    ),
                  );
                  // 2. Quando l'utente torna indietro (ha salvato o annullato),
                  // diciamo al ViewModel di riscaricare i dati freschi!
                  viewModel.reloadProfile();
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
                label: const Text(
                  "Modifica profilo",
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),

              const Spacer(),

              // --- PULSANTE LOGOUT ---
              TextButton.icon(
                onPressed: () => viewModel.logout(),
                icon: const Icon(Icons.logout, color: AppColors.accentRed),
                label: const Text(
                  "Disconnetti Account",
                  style: TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
