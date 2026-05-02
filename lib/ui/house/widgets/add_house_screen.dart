import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../view_model/house_view_model.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/loading_overlay.dart';
import '../../core/ui/custom_user_header.dart';
import '../../main_layout/widgets/main_layout.dart';

/// Schermata per creare o unirsi a una casa. View pura che delega al [HouseViewModel].
class AddHouseScreen extends StatefulWidget {
  const AddHouseScreen({super.key});

  @override
  State<AddHouseScreen> createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  final TextEditingController _codiceController = TextEditingController();

  @override
  void dispose() {
    _codiceController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateHouse() async {
    final viewModel = context.read<HouseViewModel>();
    final success = await viewModel.createHouse();

    if (!mounted) return;

    if (success && viewModel.createdCode != null) {
      _mostraCodiceCreato(viewModel.createdCode!);
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleJoinHouse() async {
    final viewModel = context.read<HouseViewModel>();
    final success = await viewModel.joinHouse(_codiceController.text);

    if (!mounted) return;

    if (success) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _mostraCodiceCreato(String codice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Casa creata con successo!",
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Condividi questo codice con i tuoi coinquilini per farli unire:",
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.finanzeBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: SelectableText(
                codice,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: codice));
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text("Codice copiato!"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text("Copia Codice"),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainLayout()),
              );
            },
            child: const Text("VAI ALLA HOME"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HouseViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Rimuove la freccia per tornare indietro (se non ti serve qui)

        title: const CustomUserHeader(
          greetingText:
              'BENVENUTO A CASA', // Testo personalizzato per questa pagina
          showBell: false, // Niente campanella qui
        ),

        actions: const [], // Svuotiamo le actions
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Inizia il tuo viaggio.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'La gestione della tua casa non è mai stata così semplice e armoniosa. Scegli come vuoi cominciare oggi.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // --- CARD: CREA UNA NUOVA CASA ---
            _buildActionCard(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.home_outlined,
                          size: 50,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.iconBgBeige,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Crea una nuova casa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inizia da zero, definisci le stanze e invita i tuoi coinquilini o familiari.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: viewModel.isLoading
                          ? null
                          : _handleCreateHouse,
                      child: viewModel.isLoading
                          ? const ButtonLoadingIndicator()
                          : const Text(
                              'Inizia una nuova avventura',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- CARD: UNISCITI A UNA CASA ---
            _buildActionCard(
              backgroundColor: AppColors.finanzeBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person_add_outlined,
                          color: Color(0xFF6B8073),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unisciti a una casa esistente',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Inserisci il codice ricevuto dal proprietario.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CODICE CASA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codiceController,
                    decoration: InputDecoration(
                      hintText: 'ABC - 123',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.5),
                      ),
                      onPressed: viewModel.isLoading ? null : _handleJoinHouse,
                      child: viewModel.isLoading
                          ? const ButtonLoadingIndicator(
                              color: AppColors.primaryGreen,
                            )
                          : const Text(
                              'Unisciti',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required Widget child,
    Color backgroundColor = Colors.white,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (backgroundColor == Colors.white)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: child,
    );
  }
}
