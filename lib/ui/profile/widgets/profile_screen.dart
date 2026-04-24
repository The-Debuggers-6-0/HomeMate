import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/profile_view_model.dart';
import '../../core/themes/app_colors.dart';
import 'edit_profile_screen.dart';
import 'dart:convert';
import '../../auth/widgets/login_screen.dart';

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
                onPressed: () async {
                  // 1. Mostra il pop-up
                  final bool? confirmLogout = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Disconnessione'),
                        content: const Text(
                          'Vuoi davvero effettuare il logout?',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        actions: [
                          // Bottone NO
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'No',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Bottone SI
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Sì',
                              style: TextStyle(
                                color: AppColors.accentRed,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  // 2. Se l'utente clicca Sì (true), eseguiamo il logout vero e proprio
                  if (confirmLogout == true) {
                    viewModel.logout();
                  }
                },
                // --- PARTE GRAFICA DEL BOTTONE ---
                icon: const Icon(Icons.logout, color: AppColors.accentRed),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- PULSANTE ELIMINA ACCOUNT ---
              TextButton.icon(
                onPressed: () async {
                  // 1. Mostriamo il pop-up di ALLARME ROSSO
                  final bool? confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: const [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Attenzione'),
                          ],
                        ),
                        content: const Text(
                          'Sei sicuro di voler eliminare definitivamente il tuo account?\n\nQuesta azione è irreversibile e tutti i tuoi dati, la tua bio e le tue foto verranno cancellati per sempre.',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        actions: [
                          // Bottone ANNULLA (in evidenza per salvarli)
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Annulla',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Bottone ELIMINA (rosso e spaventoso)
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Elimina per sempre',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  // 2. Se l'utente clicca "Elimina per sempre" (true)...
                  if (confirmDelete == true) {
                    // 1. Il ViewModel fa esplodere i dati su Firebase
                    await viewModel.deleteAccount();

                    // 2. Controllo di sicurezza di Flutter (obbligatorio dopo un 'await')
                    if (context.mounted) {
                      // 3. Ti butto fuori alla schermata di Login e cancello la cronologia!
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  "Elimina Account",
                  style: TextStyle(color: Colors.red),
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
