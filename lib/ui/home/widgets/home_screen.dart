import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/home_view_model.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/custom_user_header.dart';
import '../../main_layout/widgets/main_layout.dart';

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

                    // 3. POST-IT (Sticky Notes) con tasto aggiungi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'POST-IT / PROMEMORIA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showAddPostItDialog(context, viewModel),
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
                    _buildPostItGrid(viewModel),

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

  // Dialog per la creazione di un nuovo Post-it
  void _showAddPostItDialog(BuildContext context, HomeViewModel viewModel) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuovo Post-it', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Scrivi un promemoria per la casa...',
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
            child: const Text('Condividi'),
          ),
        ],
      ),
    );
  }

  // Dialog di conferma eliminazione
  void _confirmDeletePostIt(BuildContext context, HomeViewModel viewModel, String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Post-it'),
        content: const Text('Vuoi davvero rimuovere questo promemoria?'),
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
                          color: viewModel.isInCredit ? AppColors.primaryGreen : AppColors.accentRed,
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
                        color: AppColors.accentGreen,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryGreen,
            child: Icon(Icons.cleaning_services, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHI TOCCA OGGI?',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  '${viewModel.choreToday} • ${viewModel.personToday}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.primaryGreen),
        ],
      ),
    );
  }

  Widget _buildPostItGrid(HomeViewModel viewModel) {
    if (viewModel.stickyNotes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: const Text(
          "Nessun promemoria presente. Tocca '+' per aggiungerne uno!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 1.0,
      ),
      itemCount: viewModel.stickyNotes.length,
      itemBuilder: (context, index) {
        final note = viewModel.stickyNotes[index];
        
        final colors = [
          const Color(0xFFFFF9C4), // Giallo limone chiaro
          const Color(0xFFFFECB3), // Ambra chiaro
          const Color(0xFFF1F8E9), // Verde chiarissimo
          const Color(0xFFE3F2FD), // Blu chiarissimo
          const Color(0xFFFCE4EC), // Rosa chiarissimo
        ];
        
        final postItColor = colors[index % colors.length];
        final rotations = [-0.04, 0.03, -0.02, 0.05, -0.03];
        final rotation = rotations[index % rotations.length];

        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Transform.rotate(
            angle: rotation,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Ombra dinamica stratificata
                Positioned(
                  bottom: 2,
                  right: 2,
                  left: 6,
                  top: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(4, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Corpo del Post-it
                ClipPath(
                  clipper: PostItClipper(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 28, 14, 14),
                    decoration: BoxDecoration(
                      color: postItColor,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.0, 0.5, 1.0],
                        colors: [
                          Color.lerp(postItColor, Colors.white, 0.4)!,
                          postItColor,
                          Color.lerp(postItColor, Colors.black, 0.1)!,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        note.content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Verdana',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF333333),
                          height: 1.3,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),

                // 3. Angolo piegato (3D Curl)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: CornerFoldClipper(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.lerp(postItColor, Colors.black, 0.25)!,
                            Color.lerp(postItColor, Colors.black, 0.1)!,
                            Color.lerp(postItColor, Colors.white, 0.3)!,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 4. Puntina (Push-pin) 3D
                Align(
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                    offset: const Offset(0, -10),
                    child: _buildPushPin(),
                  ),
                ),

                // 5. Tasto elimina
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => _confirmDeletePostIt(context, viewModel, note.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 10, color: Colors.black.withOpacity(0.3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget helper per la puntina realistica
  Widget _buildPushPin() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ombra della puntina
        Transform.translate(
          offset: const Offset(2, 4),
          child: Icon(Icons.push_pin, size: 20, color: Colors.black.withOpacity(0.15)),
        ),
        // Corpo puntina
        const Icon(Icons.push_pin, size: 20, color: Color(0xFFD32F2F)),
        // Riflesso puntina
        Positioned(
          top: 4,
          left: 8,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
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
