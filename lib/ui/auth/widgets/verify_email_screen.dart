import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/auth_view_model.dart';
import '../../../data/repositories/auth_repository.dart';

/// Schermata di verifica email.
/// Il polling per controllare la verifica è gestito internamente,
/// ma l'azione di verifica è delegata al repository tramite il ViewModel.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final Color darkGreen = const Color(0xFF2C5542);
  final Color greyTextColor = const Color(0xFF707070);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
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
    await authViewModel.refreshAuthState();
    // Se lo stato cambia, AuthChecker mostrerà automaticamente la schermata corretta
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final authRepo = context.read<AuthRepository>();
      await authRepo.resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text("Nuova email inviata!"),
            backgroundColor: darkGreen),
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
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final email = authViewModel.firebaseUser?.email ?? 'tua email';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkGreen),
          onPressed: _logout,
        ),
        title: const Text("HomeMate",
            style: TextStyle(
                color: Color(0xFF2C5542), fontWeight: FontWeight.bold)),
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
                color: const Color(0xFFE9EFE9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(Icons.mark_email_read_rounded,
                  size: 80, color: darkGreen),
            ),
            const SizedBox(height: 40),
            Text(
              "Verifica la tua mail",
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: darkGreen),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style:
                    TextStyle(color: greyTextColor, fontSize: 16, height: 1.5),
                children: [
                  const TextSpan(
                      text: "Abbiamo inviato un link di conferma a\n"),
                  TextSpan(
                      text: email,
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold)),
                  const TextSpan(
                      text:
                          ".\n\nControlla la tua casella di posta e clicca sul link. Questa pagina si aggiornerà da sola!"),
                ],
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(color: darkGreen),
            const SizedBox(height: 48),
            TextButton(
              onPressed: _logout,
              child: Text("Torna al Login",
                  style: TextStyle(
                      color: darkGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _sendVerificationEmail,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: greyTextColor, fontSize: 14),
                  children: [
                    const TextSpan(text: "Non hai ricevuto l'email? "),
                    TextSpan(
                        text: "Inviane un'altra",
                        style: TextStyle(
                            color: darkGreen, fontWeight: FontWeight.bold)),
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
