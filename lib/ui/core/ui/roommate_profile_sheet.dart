import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/user_badge.dart';
import 'badge_icon_helper.dart';
import '../themes/app_colors.dart';
import 'user_avatar.dart';

// TENDINA PROFILO COINQUILINO 
class RoommateProfileSheet extends StatelessWidget {
  final AppUser user;

  const RoommateProfileSheet({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Estraiamo la lista dei badge sbloccati dell'utente
    final badges = user.unlockedBadges.values.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. AVATAR GRANDE
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen, width: 3),
            ),
            child: UserAvatar(user: user, radius: 45),
          ),
          const SizedBox(height: 16),
          
          // 2. NOME
          Text(
            '${user.name} ${user.surname}'.trim(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          // 3. BIO
          Text(
            user.bio.isNotEmpty ? user.bio : 'Nessuna biografia inserita.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // 4. TITOLO BACHECA
          const Text(
            'Bacheca Trofei 🏆',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 16),

          // 5. I BADGE O IL MESSAGGIO DI INCORAGGIAMENTO
          if (badges.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Ancora nessun badge sbloccato.\nÈ ora di darsi da fare!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: badges.map((b) => _buildBadgeMini(b)).toList(),
            ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Costruisce il singolo badge nella tendina
  Widget _buildBadgeMini(UserBadge badge) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('badges_metadata')
          .doc(badge.templateId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        // Se e' un badge mensile (Top Roommate), cambiamo il titolo.
        String title = data['title'] ?? 'Badge';
        if (badge.templateId == 'top_roommate_monthly' && badge.month != null) {
          title = 'Top $title';
        }

        final Color badgeColor = Color(
          int.parse((data['color'] ?? '#000000').replaceFirst('#', '0xff')),
        );
        final IconData icon = BadgeIconHelper.getIconFromName(data['iconName']);

        return Tooltip(
          message: data['description'] ?? '',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: badgeColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: badgeColor, size: 24),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 70,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}