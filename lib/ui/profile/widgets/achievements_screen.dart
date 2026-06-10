import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/app_user.dart';
import '../../../domain/models/user_badge.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/badge_icon_helper.dart';

class AchievementsScreen extends StatelessWidget {
  final AppUser user;

  const AchievementsScreen({super.key, required this.user});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bacheca Traguardi"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Recuperiamo TUTTI i badge possibili dal catalogo
        stream: FirebaseFirestore.instance.collection('badges_metadata').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nessun badge trovato nel catalogo."));
          }

          // Organizziamo i badge per categoria
          Map<String, List<DocumentSnapshot>> categories = {};
          for (var doc in snapshot.data!.docs) {
            String category = doc['category'] ?? 'Altro';
            if (!categories.containsKey(category)) {
              categories[category] = [];
            }
            categories[category]!.add(doc);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: categories.keys.map((cat) {
              return _buildCategorySection(cat, categories[cat]!);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(String title, List<DocumentSnapshot> badges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.8,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badgeData = badges[index].data() as Map<String, dynamic>;
            final String badgeId = badges[index].id;
            
            // Verifichiamo se l'utente possiede questo badge
            final bool isUnlocked = user.unlockedBadges.values.any((b) => b.templateId == badgeId);

            return _buildBadgeItem(badgeData, isUnlocked);
          },
        ),
        const Divider(height: 40),
      ],
    );
  }

  Widget _buildBadgeItem(Map<String, dynamic> data, bool isUnlocked) {
    final Color baseColor = Color(int.parse((data['color'] ?? '#9E9E9E').toString().replaceFirst('#', '0xff')));

    // Calcoliamo l'icona usando il nome dal catalogo
    final IconData iconData = BadgeIconHelper.getIconFromName(data['iconName']);
    
    // Leggiamo la descrizione (o mettiamo un default se manca)
    final String description = data['description'] ?? 'Continua a partecipare per sbloccarlo!';

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
      
      // Contenuto del badge
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: isUnlocked ? baseColor.withOpacity(0.15) : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isUnlocked ? baseColor.withOpacity(0.5) : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: baseColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  iconData,
                  color: isUnlocked ? baseColor : Colors.grey.shade400,
                  size: 30,
                ),
              ),
              if (!isUnlocked)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, size: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data['title'] ?? 'Badge',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              color: isUnlocked ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  
}