import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../view_model/house_view_model.dart';
import '../../auth/view_model/auth_view_model.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/loading_overlay.dart';

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
            backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _handleJoinHouse() async {
    final viewModel = context.read<HouseViewModel>();
    final success = await viewModel.joinHouse(_codiceController.text);

    if (!mounted) return;

    if (success) {
      await context.read<AuthViewModel>().refreshAuthState();
    } else if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(viewModel.errorMessage!),
            backgroundColor: Colors.orange),
      );
    }
  }

  void _mostraCodiceCreato(String codice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Casa creata con successo!",
            style: TextStyle(
                color: Color(0xFF324A3D), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "Condividi questo codice con i tuoi coinquilini per farli unire:"),
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F2EE),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
              ),
              child: SelectableText(
                codice,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Color(0xFF324A3D)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: codice));
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                      content: Text("Codice copiato!"),
                      duration: Duration(seconds: 1)),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text("Copia Codice"),
            )
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await context.read<AuthViewModel>().refreshAuthState();
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
        title: const Text(
          'Benvenuto a Casa',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
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
                  color: Color(0xFF324A3D)),
            ),
            const SizedBox(height: 12),
            Text(
              'La gestione della tua casa non è mai stata così semplice e armoniosa. Scegli come vuoi cominciare oggi.',
              style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5),
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
                            color: const Color(0xFFD3E4D8),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.home_outlined,
                            size: 50, color: Color(0xFF324A3D)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Color(0xFFF0D6C1),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.add,
                            size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Crea una nuova casa',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    'Inizia da zero, definisci le stanze e invita i tuoi coinquilini o familiari.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8073),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed:
                          viewModel.isLoading ? null : _handleCreateHouse,
                      child: viewModel.isLoading
                          ? const ButtonLoadingIndicator()
                          : const Text('Inizia una nuova avventura',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- CARD: UNISCITI A UNA CASA ---
            _buildActionCard(
              backgroundColor: const Color(0xFFF3F2EE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.person_add_outlined,
                            color: Color(0xFF6B8073)),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unisciti a una casa esistente',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary)),
                            Text(
                                'Inserisci il codice ricevuto dal proprietario.',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('CODICE CASA',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codiceController,
                    decoration: InputDecoration(
                      hintText: 'ABC - 123',
                      filled: true,
                      fillColor: const Color(0xFFE5E3DD),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B8073),
                        side: const BorderSide(color: Color(0xFF6B8073)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white.withOpacity(0.5),
                      ),
                      onPressed:
                          viewModel.isLoading ? null : _handleJoinHouse,
                      child: viewModel.isLoading
                          ? const ButtonLoadingIndicator(
                              color: Color(0xFF6B8073))
                          : const Text('Unisciti',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildActionCard(
      {required Widget child, Color backgroundColor = Colors.white}) {
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
                offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}
