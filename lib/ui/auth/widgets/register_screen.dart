import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/register_view_model.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/loading_overlay.dart';

/// Schermata di registrazione. View pura che delega tutta la logica al [RegisterViewModel].
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Color _titleGreen = const Color(0xFF324A3D);
  final Color _inputBg = const Color(0xFFE5E3DD);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final viewModel = context.read<RegisterViewModel>();
    final success = await viewModel.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrazione completata! Verifica la tua email."),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      _showErrorSnackBar(
          viewModel.errorMessage ?? 'Errore durante la registrazione.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // --- ICONA CASA IN ALTO ---
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD3E4D8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.home, size: 40,
                      color: Color(0xFF324A3D)),
                ),
              ),
              const SizedBox(height: 32),

              // --- TITOLO ---
              Text(
                "Registrati",
                style: TextStyle(
                  color: _titleGreen,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Crea il tuo profilo e inizia a gestire la\nconvivenza con facilità.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // --- CARD FORM ---
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Email",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildField(
                        controller: _emailController,
                        hint: "esempio@home.it",
                        icon: Icons.email_outlined),

                    const SizedBox(height: 24),
                    const Text("Password",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _passwordController,
                      hint: "Minimo 8 caratteri",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscure: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),

                    const SizedBox(height: 24),
                    const Text("Conferma Password",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _confirmPasswordController,
                      hint: "Ripeti la password",
                      icon: Icons.lock_reset_outlined,
                      isPassword: true,
                      obscure: _obscureConfirmPassword,
                      onToggle: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),

                    const SizedBox(height: 32),
                    // Pulsante Registrati
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            viewModel.isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: viewModel.isLoading
                            ? const ButtonLoadingIndicator()
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Registrati",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.chevron_right, size: 18),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              // Footer: Accedi ora
              Center(
                child: Column(
                  children: [
                    const Text("Hai già un account?",
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Accedi ora",
                        style: TextStyle(
                          color: Color(0xFF324A3D),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
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
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? obscure,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure! : false,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscure! ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 20),
                  onPressed: onToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}
