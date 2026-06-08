import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/profile_view_model.dart';
import '../../core/themes/app_colors.dart';
import 'edit_profile_screen.dart';
import '../../../ui/auth/widgets/login_screen.dart';
import '../../core/ui/user_avatar.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/user_badge.dart';
import 'achievements_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/ui/badge_icon_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    if (viewModel.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // --- FOTO PROFILO CENTRALE ---
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 3,
                      ),
                    ),
                    child: UserAvatar(user: viewModel.userProfile, radius: 50),
                  ),

                  const SizedBox(height: 16),

                  // --- NOME E COGNOME ---
                  Text(
                    viewModel.fullName,
                    style: const TextStyle(
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- JOLLY ---
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8), // Tolto il margine orizzontale per allinearlo al resto
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Icona a forma di ticket/jolly
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.confirmation_num_rounded,
                              color: Colors.amber,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Testo descrittivo
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "I tuoi Jolly",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Usali per saltare pulizie o spazzatura!",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Contatore dei Jolly
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1), // Usato il primaryGreen del tuo tema
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              "${viewModel.userProfile?.jollies ?? 0}", // Recupera i jolly
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- ZONA: I MIEI BADGE ---
                  _buildBadgesSection(context, viewModel.userProfile),

                  const SizedBox(height: 50),

                  // --- PULSANTE MODIFICA PROFILO ---
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(
                            currentName: viewModel.userProfile?.name ?? '',
                            currentSurname:
                                viewModel.userProfile?.surname ?? '',
                            currentBio: viewModel.userProfile?.bio ?? '',
                            currentPhotoUrl: viewModel.userProfile?.photoUrl,
                          ),
                        ),
                      );
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

                  const SizedBox(height: 48),

                  // --- ZONA OPZIONI ACCOUNT ---

                  // 1. Tasto Logout
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                              'Sei sicuro di voler uscire dal tuo account?',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text(
                                  'Annulla',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(dialogContext).pop();
                                  await context
                                      .read<ProfileViewModel>()
                                      .logout();
                                  if (context.mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                      (Route<dynamic> route) => false,
                                    );
                                  }
                                },
                                child: Text(
                                  'Esci',
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.grey),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Separatore
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),

                  const SizedBox(height: 16),

                  // 3. Bottone Elimina Account
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: Text(
                              'Attenzione!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade600,
                              ),
                            ),
                            content: const Text(
                              'Sei sicuro di voler eliminare definitivamente il tuo account? Questa azione è irreversibile e perderai tutti i tuoi dati.',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text(
                                  'Annulla',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(dialogContext).pop();
                                  try {
                                    final success = await context
                                        .read<ProfileViewModel>()
                                        .deleteAccount();
                                    if (context.mounted) {
                                      if (success) {
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                          (Route<dynamic> route) => false,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Errore durante l\'eliminazione. Riprova.',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted &&
                                        e.toString().contains(
                                          'requires-recent-login',
                                        )) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Devi effettuare nuovamente l\'accesso per eliminare l\'account.',
                                          ),
                                        ),
                                      );
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    }
                                  }
                                },
                                child: const Text(
                                  'Elimina',
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
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      side: BorderSide(color: Colors.red.shade400, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text(
                      'Elimina Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =======================================================================
  // METODI DI SUPPORTO PER I BADGE
  // =======================================================================

  Widget _buildBadgesSection(BuildContext context, AppUser? user) {
    if (user == null) return const SizedBox.shrink();

    final List<UserBadge> displayBadges = user.unlockedBadges.values
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "I miei Traguardi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AchievementsScreen(user: user),
                  ),
                );
              },
              child: const Text(
                "Vedi tutti",
                style: TextStyle(fontSize: 14, color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (index) {
            if (index < displayBadges.length) {
              return _buildRealBadge(displayBadges[index]);
            } else {
              return _buildEmptySlot();
            }
          }),
        ),
      ],
    );
  }

  Widget _buildRealBadge(UserBadge badge) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('badges_metadata')
          .doc(badge.templateId)
          .get(),
      builder: (context, snapshot) {
        IconData iconData = Icons.hourglass_empty;
        Color color = Colors.grey;
        String label = "...";
        String description = "Caricamento...";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;

          label = data['title'] ?? "Traguardo";
          description =
              data['description'] ?? "Hai sbloccato questo traguardo!";

          if (data['color'] != null) {
            color = Color(
              int.parse(data['color'].toString().replaceFirst('#', '0xff')),
            );
          }

          iconData = BadgeIconHelper.getIconFromName(data['iconName']);

          if (badge.templateId == 'top_roommate_monthly' &&
              badge.month != null) {
            label = "Top\n${_getMonthName(badge.month)}";
          }
        }

        return Tooltip(
          message: description,
          triggerMode: TooltipTriggerMode.tap,
          preferBelow: false,
          showDuration: const Duration(seconds: 3),
          textAlign: TextAlign.center,
          margin: const EdgeInsets.symmetric(horizontal: 50),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            height: 1.4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(iconData, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptySlot() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade400,
              style: BorderStyle.solid,
            ),
          ),
          child: Icon(
            Icons.lock_outline,
            color: Colors.grey.shade400,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Bloccato",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  String _getMonthName(int? month) {
    if (month == null) return "";
    const mesi = [
      "Gen",
      "Feb",
      "Mar",
      "Apr",
      "Mag",
      "Giu",
      "Lug",
      "Ago",
      "Set",
      "Ott",
      "Nov",
      "Dic",
    ];
    return (month >= 1 && month <= 12) ? mesi[month - 1] : "";
  }
}
