import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../themes/app_colors.dart';
import '../../profile/widgets/profile_screen.dart'; 
import 'user_avatar.dart';
import '../../../data/services/notification_service.dart';
import '../../home/widgets/notifications_bottom_sheet.dart';

class CustomUserHeader extends StatelessWidget {
  final String greetingText; // Es: "BENTORNATO" o "BENVENUTO A CASA"
  final bool showBell;       // Mostrare la campanella? (Vero o Falso)

  const CustomUserHeader({
    super.key,
    this.greetingText = 'BENTORNATO', // Valore predefinito
    this.showBell = true,             // Valore predefinito
  });

  @override
  Widget build(BuildContext context) {
    // 1. Il widget ascolta in autonomia i dati dell'utente!
    final profileViewModel = context.watch<ProfileViewModel>();
    final userProfile = profileViewModel.userProfile;

    final String nome = userProfile?.name ?? 'Utente';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // --- PARTE SINISTRA: Foto e Testi ---
        Row(
          children: [
            // Immagine Profilo Dinamica e Cliccabile (con effetto onda)
            InkWell(
              onTap: () {
                // Navighiamo verso la schermata Profilo
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              borderRadius: BorderRadius.circular(22),
              child: UserAvatar(
                user: userProfile,
                radius: 22,
              ),
            ),

            SizedBox(width: 20), // Spazio tra foto e testi
            
            // Testi ("BENTORNATO" + "Ciao, nome")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greetingText.toUpperCase(),
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
        
        // --- PARTE DESTRA: Campanella ---
        if (showBell)
          ValueListenableBuilder<int>(
            valueListenable: NotificationService().unreadCountNotifier,
            builder: (context, unreadCount, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, size: 28),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const NotificationsBottomSheet(),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          )
        else
          const SizedBox(width: 48), // Spazio per bilanciare se manca la campanella
      ],
    );
  }
}