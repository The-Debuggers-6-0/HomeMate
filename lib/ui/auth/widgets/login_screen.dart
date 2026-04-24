import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/login_view_model.dart';
import '../../core/themes/app_colors.dart';
import '../../core/ui/loading_overlay.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

/// Schermata di login. View pura che delega tutta la logica al [LoginViewModel].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final Color _inputBg = const Color(0xFFE5E3DD);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final viewModel = context.read<LoginViewModel>();
    final success = await viewModel.loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!success && mounted) {
      _showErrorSnackBar(viewModel.errorMessage ?? 'Errore durante il login.');
    }
    // Se success, AuthViewModel rileverà il cambiamento di auth state automaticamente.
  }

  Future<void> _handleGoogleLogin() async {
    final viewModel = context.read<LoginViewModel>();
    final success = await viewModel.loginWithGoogle();

    if (!success && mounted) {
      _showErrorSnackBar(viewModel.errorMessage ?? 'Errore Google Sign-In.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),

              const SizedBox(height: 50),

              // --- INTESTAZIONE ---
              Text(
                "Bentornato a casa",
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Gestire la tua convivenza non è mai\nstato così semplice ed elegante.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // --- CARD BIANCA DEL FORM ---
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email
                    const Text("Email",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _emailController,
                      hint: "nome@esempio.it",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 24),

                    // Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Password",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen())),
                          child: const Text(
                            "Hai dimenticato la password?",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _passwordController,
                      hint: "........",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),

                    // Bottone Accedi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _handleLogin,
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
                                  Text("Accedi",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Divisore OPPURE
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("OPPURE",
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  letterSpacing: 1.2)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Bottone Google
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed:
                            viewModel.isLoading ? null : _handleGoogleLogin,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: const Color(0xFFF9F9F8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                                'assets/images/icons8-logo-di-google-144.png',
                                height: 20),
                            const SizedBox(width: 12),
                            const Text("Continua con Google",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              // Footer: Registrati
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen())),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      children: [
                        TextSpan(text: "Non hai un account? "),
                        TextSpan(
                          text: "Registrati ora",
                          style: TextStyle(
                              color: Color(0xFF324A3D),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                      size: 20),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
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
