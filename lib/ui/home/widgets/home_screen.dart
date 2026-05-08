import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/home_view_model.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/custom_user_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
    return Container(
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
              const Text(
                'BILANCIO CASA',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: viewModel.isInCredit
                      ? AppColors.accentGreen.withOpacity(0.1)
                      : AppColors.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  viewModel.balanceStatus,
                  style: TextStyle(
                    color: viewModel.isInCredit ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            viewModel.balanceFormatted,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          Text(
            viewModel.balanceDescription,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: viewModel.balanceProgress,
              minHeight: 8,
              backgroundColor: Colors.grey[100],
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
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
      return const Text(
        "Nessun post-it presente. Aggiungine uno!",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: viewModel.stickyNotes.length,
      itemBuilder: (context, index) {
        final note = viewModel.stickyNotes[index];
        final colors = [
          const Color(0xFFFFF9C4), // Giallo classico
          const Color(0xFFFFE1E1), // Rosa pastello
          const Color(0xFFE1F5FE), // Azzurro pastello
        ];
        final postItColor = colors[index % colors.length];

        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: postItColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.push_pin, size: 16, color: Colors.black26),
                  const Spacer(),
                  Text(
                    note.content,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () => _confirmDeletePostIt(context, viewModel, note.id),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.black45),
                ),
              ),
            ),
          ],
        );
      },
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
