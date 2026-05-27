import 'package:flutter/material.dart';
import 'package:homemate/data/services/notification_service.dart';
import 'package:provider/provider.dart';
import '../view_model/home_view_model.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/custom_user_header.dart';
import '../../core/ui/user_avatar.dart';
import '../../main_layout/widgets/main_layout.dart';
import '../../../domain/models/sticky_note.dart';

class HomeScreen extends StatefulWidget {
  final TabChangeNotifier tabNotifier;
  final int tabIndex;

  const HomeScreen({
    super.key,
    required this.tabNotifier,
    required this.tabIndex,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomUserHeader(
                      greetingText: 'BENTORNATO',
                      showBell: true,
                    ),
                    const SizedBox(height: 25),

                    // 1. SALDO SPESE REALE
                    _buildQuickBalance(viewModel),

                    const SizedBox(height: 25),

                    // 2. CHI TOCCA OGGI
                    _buildChoreToday(viewModel),

                    const SizedBox(height: 25),

                    // 3. BACHECA & COMUNICAZIONI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BACHECA & COMUNICAZIONI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showAddAnnouncementDialog(context, viewModel),
                          icon: const Icon(Icons.add_circle_outline, 
                            color: AppColors.primaryGreen, 
                            size: 22
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildAnnouncementsBoard(viewModel),

                    const SizedBox(height: 25),

                    // 4. LISTA SPESA & CALENDARIO
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildShoppingFlash(viewModel)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildEventCalendar(viewModel)),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  // Dialog per la creazione di un nuovo avviso
  void _showAddAnnouncementDialog(BuildContext context, HomeViewModel viewModel) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuovo Avviso', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Scrivi una comunicazione per la casa...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                viewModel.addStickyNote(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Pubblica'),
          ),
        ],
      ),
    );
  }

  // Dialog di conferma eliminazione
  void _confirmDeleteAnnouncement(BuildContext context, HomeViewModel viewModel, String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Avviso'),
        content: const Text('Vuoi davvero rimuovere questa comunicazione?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteStickyNote(noteId);
              Navigator.pop(context);
            },
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBalance(HomeViewModel viewModel) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => widget.tabNotifier.selectTab(1),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
                  Text(
                    'SITUAZIONE SPESE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.isInCredit ? 'Credito Totale' : 'Debito Totale',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      Text(
                        viewModel.balanceFormatted,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: viewModel.isInCredit ? AppColors.primaryDark : AppColors.accentRed,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 24),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBalanceDetail(
                        label: 'Devi ricevere',
                        amount: viewModel.totalCredit,
                        color: AppColors.primaryDark,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2)),
                    Expanded(
                      child: _buildBalanceDetail(
                        label: 'Devi dare',
                        amount: viewModel.totalDebt,
                        color: AppColors.accentRed,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceDetail({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '€ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildChoreToday(HomeViewModel viewModel) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => widget.tabNotifier.selectTab(2),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primaryDark.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cleaning_services_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PULIZIE DA FARE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (viewModel.hasChoreForMe)
                      Text(
                        viewModel.choreToday,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      )
                    else
                      Text(
                        'Nessuna faccenda per te',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsBoard(HomeViewModel viewModel) {
    if (viewModel.stickyNotes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
        ),
        child: const Text(
          "Nessun avviso pubblicato. Tocca '+' per scriverne uno!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemCount: viewModel.stickyNotes.length,
      itemBuilder: (context, index) {
        final note = viewModel.stickyNotes[index];
        return _buildAnnouncementCard(context, viewModel, note, index);
      },
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    HomeViewModel viewModel,
    StickyNote note,
    int index,
  ) {
    final palette = [
      const Color(0xFFE8F5E9),
      const Color(0xFFE3F2FD),
      const Color(0xFFFFF8E1),
      const Color(0xFFFCE4EC),
      const Color(0xFFFFF3E0),
    ];
    final accent = palette[index % palette.length];
    final authorLabel = note.authorName.isNotEmpty ? note.authorName : 'Coinquilino';
    final timeLabel = _formatAnnouncementTime(note.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                radius: 20,
                photoUrl: note.authorPhotoUrl.isNotEmpty ? note.authorPhotoUrl : null,
                backgroundColor: accent.withOpacity(0.55),
                iconColor: AppColors.primaryDark,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Avviso',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      authorLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                timeLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Comunicazione casa',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _confirmDeleteAnnouncement(context, viewModel, note.id),
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAnnouncementTime(DateTime createdAt) {
    final now = DateTime.now();
    final sameDay = now.year == createdAt.year && now.month == createdAt.month && now.day == createdAt.day;
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');

    if (sameDay) {
      return 'Oggi $hour:$minute';
    }
    return '$day/$month $hour:$minute';
  }

  Widget _buildShoppingFlash(HomeViewModel viewModel) {
    return _buildSmallCard(
      title: 'RECENTI IN SPESA',
      icon: Icons.shopping_basket_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (viewModel.shoppingList.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Ultimi aggiunti:",
                style: TextStyle(fontSize: 9, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          ...viewModel.shoppingList.isEmpty
              ? [
                  const Text(
                    "Tutto preso! 🎉",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  )
                ]
              : viewModel.shoppingList.take(3).map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
        ],
      ),
    );
  }

  Widget _buildEventCalendar(HomeViewModel viewModel) {
    return _buildSmallCard(
      title: 'EVENTI',
      icon: Icons.calendar_today_outlined,
      child: Column(
        children: viewModel.events.isEmpty
            ? [
                const Text(
                  "Nessun evento",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                )
              ]
            : viewModel.events.take(2).map((event) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${event.start.day}/${event.start.month}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildSmallCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// Clipper per l'effetto post-it con curvatura naturale
class PostItClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double foldSize = 25.0;
    
    path.moveTo(4, 0); 
    path.lineTo(size.width - 4, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 4);
    
    path.lineTo(size.width, size.height - foldSize);
    
    // Curva che raccorda l'angolo piegato
    path.quadraticBezierTo(size.width - 2, size.height - 2, size.width - foldSize, size.height);
    
    // Bordo inferiore leggermente curvo per effetto carta sollevata
    path.quadraticBezierTo(size.width * 0.5, size.height - 5, 4, size.height);
    
    path.quadraticBezierTo(0, size.height, 0, size.height - 4);
    path.lineTo(0, 4);
    path.quadraticBezierTo(0, 0, 4, 0);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Clipper per l'angolo piegato (effetto curled paper)
class CornerFoldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Forma triangolare curva per simulare la piega
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
