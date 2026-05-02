import 'dart:async';
import 'package:flutter/material.dart';
import 'package:homemate/ui/core/themes/app_colors.dart';
import 'package:provider/provider.dart';
import '../view_model/auth_view_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../setup_profile/widgets/setup_profile_screen.dart';
import '../../house/widgets/add_house_screen.dart';
import '../../main_layout/widgets/main_layout.dart';
import 'login_screen.dart';

/// Schermata di verifica email.
/// Il polling per controllare la verifica è gestito internamente,
/// ma l'azione di verifica è delegata al repository tramite il ViewModel.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  // Colori sostituiti con AppColors

  Timer? _timer;
  late final String _email;

  @override
  void initState() {
    super.initState();
    // Salva l'email una volta sola
    final authViewModel = context.read<AuthViewModel>();
    _email = authViewModel.currentFirebaseUser?.email ?? 'tua email';

    // Controlla ogni 3 secondi se l'email è stata verificata
    _timer = Timer.periodic(
        const Duration(seconds: 3), (_) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    final authViewModel = context.read<AuthViewModel>();
    final route = await authViewModel.getNextRoute();

    if (!mounted) return;

    // Se la route non è più 'verifyEmail', l'utente ha verificato!
    if (route != 'verifyEmail') {
      _timer?.cancel();
      _navigateToRoute(route);
    }
  }

  /// Naviga verso la schermata indicata dalla route.
  void _navigateToRoute(String route) {
    Widget nextScreen;
    switch (route) {
      case 'setupProfile':
        nextScreen = const SetupProfileScreen();
        break;
      case 'addHouse':
        nextScreen = const AddHouseScreen();
        break;
      case 'home':
        nextScreen = const MainLayout();
        break;
      default:
        nextScreen = const LoginScreen();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final authRepo = context.read<AuthRepository>();
      await authRepo.resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text("Nuova email inviata!"),
            backgroundColor: AppColors.primaryGreen),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Aspetta un po' prima di inviarne un'altra."),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _logout() async {
    final authRepo = context.read<AuthRepository>();
    await authRepo.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: _logout,
        ),
        title: const Text("HomeMate",
            style: TextStyle(
                color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.mark_email_read_rounded,
                  size: 80, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 40),
            Text(
              "Verifica la tua mail",
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
                children: [
                  const TextSpan(
                      text: "Abbiamo inviato un link di conferma a\n"),
                  TextSpan(
                      text: _email,
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          ".\n\nControlla la tua casella di posta e clicca sul link. Questa pagina si aggiornerà da sola!"),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: AppColors.primaryDark),
            const SizedBox(height: 48),
            TextButton(
              onPressed: _logout,
              child: Text("Torna al Login",
                  style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _sendVerificationEmail,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  children: [
                    const TextSpan(text: "Non hai ricevuto l'email? "),
                    TextSpan(
                        text: "Inviane un'altra",
                        style: TextStyle(
                            color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
