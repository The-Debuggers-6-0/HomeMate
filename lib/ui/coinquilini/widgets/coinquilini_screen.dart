import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../view_model/coinquilini_view_model.dart';
import '../../house/widgets/add_house_screen.dart';
import '../../core/ui/custom_user_header.dart';
import '../../core/ui/user_avatar.dart';
import '../../core/ui/roommate_profile_sheet.dart';
import '../../main_layout/widgets/main_layout.dart';
import '../../../domain/models/app_user.dart';
 
class CoinquiliniScreen extends StatefulWidget {
  final TabChangeNotifier tabNotifier;
  final int tabIndex;
 
  const CoinquiliniScreen({
    super.key,
    required this.tabNotifier,
    required this.tabIndex,
  });
 
  @override
  State<CoinquiliniScreen> createState() => _CoinquiliniScreenState();
}
 
class _CoinquiliniScreenState extends State<CoinquiliniScreen> {
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
    final viewModel = context.watch<CoinquiliniViewModel>();
 
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
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              const CustomUserHeader(
                greetingText: 'LA TUA CASA',
                showBell: true,
              ),
 
              const SizedBox(height: 30),
 
              // ── 1. CLASSIFICA (prima)
              if (viewModel.currentHouse != null &&
                  viewModel.roommates.isNotEmpty)
                _buildLeaderboard(viewModel.roommates),
 
              const SizedBox(height: 24),
 
              // ── 2. CARD CASA (dopo)
              if (viewModel.currentHouse != null)
                _buildHouseCard(context, viewModel)
              else
                const Center(
                  child: Text(
                    "Non fai ancora parte di una casa.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
 
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
 
  // LEADERBOARD con podio
  Widget _buildLeaderboard(List<AppUser> roommates) {
    // Ordina per punti decrescenti (la lista dovrebbe già arrivarci ordinata
    // dal ViewModel, ma lo facciamo anche qui per sicurezza)
    final sorted = [...roommates]..sort((a, b) => b.points.compareTo(a.points));
 
    // Calcola il punteggio massimo per le barre di progresso
    final maxPoints =
        sorted.isNotEmpty ? sorted.first.points.toDouble() : 1.0;
 
    final top3 = sorted.take(3).toList();
    final rest = sorted.length > 3 ? sorted.sublist(3) : <AppUser>[];
 
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo
          const Text(
            '🏆 Classifica Miglior Coinquilino',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 28),
 
          // ── PODIO
          _buildPodium(top3),
 
          // ── LISTA DAL 4° IN GIÙ
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...rest.asMap().entries.map((entry) {
              final rank = entry.key + 4; // parte da #4
              final user = entry.value;
              final pct = maxPoints > 0
                  ? (user.points / maxPoints).clamp(0.0, 1.0)
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRestCard(user, rank, pct),
              );
            }),
          ],
        ],
      ),
    );
  }
 
  // ── Podio (1°, 2°, 3°)
  Widget _buildPodium(List<AppUser> top3) {
    // Calcola il punteggio massimo del podio per le barre sotto
    final maxPts =
        top3.isNotEmpty ? top3.first.points.toDouble() : 1.0;
 
    // Slot: ordine visivo = [2°, 1°, 3°]
    Widget slot(int visualIndex) {
      // visualIndex: 0=2°, 1=1°, 2=3°
      final rankIndex = visualIndex == 0
          ? 1
          : visualIndex == 1
              ? 0
              : 2; // indice nella lista ordinata
      if (rankIndex >= top3.length) return _buildEmptyPodiumSlot(visualIndex);
 
      final user = top3[rankIndex];
      final rank = rankIndex + 1;
      final isFirst = rank == 1;
 
      // Altezze piattaforma
      final platformHeight = isFirst ? 90.0 : 60.0;
      final avatarRadius = isFirst ? 36.0 : 28.0;
 
      // Colori badge posizione
      final badgeColor = rank == 1
          ? const Color(0xFF3D6B4F) // verde scuro come nell'app
          : rank == 2
              ? Colors.grey.shade400
              : Colors.orange.shade300;
 
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Badge posizione sopra l'avatar
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFirst
                          ? const Color(0xFF3D6B4F)
                          : AppColors.primaryGreen.withValues(alpha: 0.3),
                      width: isFirst ? 3 : 2,
                    ),
                  ),
                  child: UserAvatar(
                    user: user,
                    radius: avatarRadius,
                    backgroundColor: AppColors.lightGreen,
                  ),
                ),
                // Badge numero
                Positioned(
                  bottom: -6,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cardBackground,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Nome
            Text(
              user.name.isNotEmpty ? user.name : 'Utente',
              style: TextStyle(
                fontSize: isFirst ? 14 : 12,
                fontWeight:
                    isFirst ? FontWeight.w800 : FontWeight.w600,
                color: AppColors.primaryDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Piattaforma podio
            Container(
              height: platformHeight,
              decoration: BoxDecoration(
                color: isFirst
                    ? const Color(0xFF3D6B4F)
                    : const Color(0xFF3D6B4F).withValues(alpha: 0.18),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${user.points}',
                      style: TextStyle(
                        fontSize: isFirst ? 22 : 17,
                        fontWeight: FontWeight.w900,
                        color: isFirst
                            ? Colors.white
                            : const Color(0xFF3D6B4F),
                      ),
                    ),
                    Text(
                      'pt',
                      style: TextStyle(
                        fontSize: isFirst ? 11 : 10,
                        fontWeight: FontWeight.w600,
                        color: isFirst
                            ? Colors.white.withValues(alpha: 0.8)
                            : const Color(0xFF3D6B4F).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
 
    return SizedBox(
      height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          slot(0), // 2°
          const SizedBox(width: 8),
          slot(1), // 1°
          const SizedBox(width: 8),
          slot(2), // 3°
        ],
      ),
    );
  }
 
  Widget _buildEmptyPodiumSlot(int visualIndex) {
    final platformHeight = visualIndex == 1 ? 90.0 : 60.0;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(height: 18),
          Container(
            height: platformHeight,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  // ── Card per 4°+
  Widget _buildRestCard(AppUser user, int rank, double progressPct) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          UserAvatar(
            user: user,
            radius: 22,
            backgroundColor: AppColors.lightGreen,
          ),
          const SizedBox(width: 14),
          // Nome + barra
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : 'Utente',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      '${user.points} pt',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Barra di progresso
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPct,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'PUNTEGGIO CASA',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Numero posizione
          Text(
            '#$rank',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
 
  // CARD CASA
  Widget _buildHouseCard(
      BuildContext context, CoinquiliniViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        viewModel.currentHouse!.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          _mostraDialogModificaNome(context, viewModel),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: viewModel.currentHouse!.id),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Codice casa copiato!"),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.finanzeBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          AppColors.primaryGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        viewModel.currentHouse!.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.copy,
                        size: 14,
                        color: AppColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Membri della casa',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
 
          // Lista Membri Orizzontale
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.roommates.length,
              itemBuilder: (context, index) {
                final roommate = viewModel.roommates[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            RoommateProfileSheet(user: roommate),
                      );
                    },
                    child: Column(
                      children: [
                        UserAvatar(
                          user: roommate,
                          radius: 26,
                          backgroundColor: AppColors.lightGreen,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          roommate.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () => _confermaAbbandono(context, viewModel),
              icon: const Icon(
                Icons.exit_to_app,
                color: AppColors.accentRed,
              ),
              label: const Text(
                'Abbandona Casa',
                style: TextStyle(
                  color: AppColors.accentRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  void _mostraDialogModificaNome(
    BuildContext context,
    CoinquiliniViewModel viewModel,
  ) {
    final TextEditingController nameController = TextEditingController(
      text: viewModel.currentHouse!.nome,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modifica Nome Casa'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Nuovo nome...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await viewModel.updateHouseName(nameController.text);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
 
  void _confermaAbbandono(
    BuildContext context,
    CoinquiliniViewModel viewModel,
  ) {
    final isLastMember = viewModel.roommates.length <= 1;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            if (isLastMember)
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
            if (isLastMember) const SizedBox(width: 8),
            Text(
              isLastMember ? 'ATTENZIONE!' : 'Abbandona Casa',
              style: TextStyle(
                color: isLastMember ? Colors.red : AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          isLastMember
              ? "Essendo l'unico membro attuale, se abbandoni ora la casa verrà eliminata del tutto!!"
              : "Sei sicuro di voler abbandonare questa casa?",
          style: const TextStyle(fontSize: 15),
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Annulla',
              style: TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await viewModel.leaveHouse();
              if (success && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddHouseScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Abbandona',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}