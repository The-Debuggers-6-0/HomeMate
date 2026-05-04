import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../view_model/coinquilini_view_model.dart';
import '../../house/widgets/add_house_screen.dart';
import '../../core/ui/custom_user_header.dart';

class CoinquiliniScreen extends StatelessWidget {
  const CoinquiliniScreen({super.key});

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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER PERSONALIZZATO ---
              const CustomUserHeader(
                greetingText: 'LA TUA CASA',
                showBell: true,
              ),

              // spazio prima della card
              const SizedBox(height: 30),

              // --- CARD DELLA CASA DINAMICA ---
              if (viewModel.currentHouse != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
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
                                  onPressed: () => _mostraDialogModificaNome(
                                    context,
                                    viewModel,
                                  ),
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
                                  color: AppColors.primaryGreen.withOpacity(
                                    0.2,
                                  ),
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

                      // Lista Membri Orizzontale Dinamica
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.roommates.length,
                          itemBuilder: (context, index) {
                            final roommate = viewModel.roommates[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: AppColors.lightGreen,
                                    backgroundImage:
                                        (roommate.photoUrl != null &&
                                            roommate.photoUrl!.isNotEmpty)
                                        ? MemoryImage(
                                            base64Decode(roommate.photoUrl!),
                                          )
                                        : null,
                                    child:
                                        (roommate.photoUrl == null ||
                                            roommate.photoUrl!.isEmpty)
                                        ? Text(
                                            roommate.name.isNotEmpty
                                                ? roommate.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: AppColors.primaryDark,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
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
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton.icon(
                          onPressed: () =>
                              _confermaAbbandono(context, viewModel),
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
                )
              else
                const Center(
                  child: Text(
                    "Non fai ancora parte di una casa.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 36),

              // --- CLASSIFICA ---
              if (viewModel.currentHouse != null) ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Classifica Miglior\nCoinquilino',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        height: 1.2,
                      ),
                    ),
                    Icon(
                      Icons.emoji_events_outlined,
                      color: AppColors.primaryDark,
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Text(
                      '🚧 Qui costruiremo il Podio! 🚧',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
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
    // 1. Controlliamo se l'utente è l'ultimo membro rimasto
    // (Se la lista dei coinquilini ha 1 solo elemento, significa che ci sei solo tu!)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Annulla',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
              Navigator.pop(dialogContext); // Chiude il dialog

              // Esegue l'abbandono (e l'eliminazione automatica se sei l'ultimo)
              final success = await viewModel.leaveHouse();

              if (success && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHouseScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Abbandona',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
