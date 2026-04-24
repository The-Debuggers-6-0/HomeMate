import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/forgot_password_view_model.dart';
import '../../core/themes/app_colors.dart';

/// Schermata di recupero password. View pura che delega al [ForgotPasswordViewModel].
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final Color darkGreen = const Color(0xFF2C5542);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final viewModel = context.read<ForgotPasswordViewModel>();
    final success =
        await viewModel.resetPassword(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      _showSnackBar(
          "Link inviato! Se l'email è registrata, riceverai un messaggio.",
          darkGreen);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else if (viewModel.errorMessage != null) {
      _showSnackBar(viewModel.errorMessage!, Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForgotPasswordViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Icona in alto ---
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEFEB),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.restore_page_outlined,
                        size: 40, color: darkGreen),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Titolo ---
                const Text(
                  "Recupera la password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),

                // --- Sottotitolo ---
                const Text(
                  "Inserisci la tua email e ti invieremo\nun link per resettare la tua password.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF5A5A5A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 48),

                // --- Campo Email ---
                const Text(
                  "Email",
                  style: TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E4E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black87),
                    decoration: const InputDecoration(
                      hintText: "nome@esempio.it",
                      hintStyle: TextStyle(color: Colors.black38),
                      suffixIcon:
                          Icon(Icons.mail_outline, color: Color(0xFF5A5A5A)),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Pulsante INVIA LINK ---
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Invia link di recupero",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.send_outlined, size: 20),
                          ],
                        ),
                ),
                const SizedBox(height: 48),

                // --- Tasto TORNA AL LOGIN ---
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF5A5A5A), size: 16),
                    label: Container(
                      padding: const EdgeInsets.only(bottom: 2),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF5A5A5A),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: const Text(
                        "Torna al login",
                        style: TextStyle(
                          color: Color(0xFF5A5A5A),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
