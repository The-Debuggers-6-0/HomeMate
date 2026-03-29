import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final Color darkGreen = const Color(0xFF2C5542);
  final Color lightBackground = const Color(0xFFF4F7F5); // Colore card
  final Color pageBackground = const Color(0xFFFAFCFA); // Colore sfondo pagina

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Per favore, inserisci la tua email.", Colors.redAccent);
      return;
    }

    try {
      // Mostra il cerchio di caricamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator(color: darkGreen)),
      );

      // Comando di Firebase per il reset
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // --- CASO 1: L'EMAIL ESISTE ---
      if (!mounted) return;
      Navigator.pop(context); // Chiude il caricamento

      _showSnackBar("Link inviato! Se l'email è registrata, riceverai un messaggio.", darkGreen);
      
      // Torna automaticamente al login
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Chiude il caricamento
      
      // --- CASO 2: L'EMAIL NON ESISTE (SIMULIAMO IL SUCCESSO,per evitare che dei malintenzionati scoprano chi è iscritto all'app facendo dei tentativi) ---
      if (e.code == 'user-not-found') {
        _showSnackBar("Link inviato! Se l'email è registrata, riceverai un messaggio.", darkGreen);
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } 
      // --- ALTRI ERRORI REALI (es. email scritta male) ---
      else if (e.code == 'invalid-email') {
        _showSnackBar("Il formato dell'email non è valido.", Colors.redAccent);
      } else {
        _showSnackBar("Errore durante l'invio.", Colors.redAccent);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar("Errore imprevisto. Riprova.", Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: lightBackground,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Icona in alto ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8E4), // Verde grigiastro chiaro
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.lock_reset_outlined, size: 40, color: darkGreen),
                  ),
                  const SizedBox(height: 24),

                  // --- Titolo ---
                  const Text(
                    "Recupera la\npassword",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Sottotitolo ---
                  const Text(
                    "Inserisci la tua email e ti\ninvieremo un link per resettare la\ntua password.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5A5A5A),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Campo Email ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text("Email", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black87),
                      decoration: const InputDecoration(
                        hintText: "nome@esempio.it",
                        hintStyle: TextStyle(color: Colors.black38),
                        suffixIcon: Icon(Icons.mail_outline, color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Pulsante INVIA LINK ---
                  ElevatedButton(
                    onPressed: _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Invia link di recupero", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.send_rounded, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Tasto TORNA AL LOGIN ---
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: darkGreen, size: 20),
                    label: Text(
                      "Torna al login",
                      style: TextStyle(color: darkGreen, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}