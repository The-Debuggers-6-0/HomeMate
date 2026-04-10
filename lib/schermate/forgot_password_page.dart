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
      backgroundColor: const Color(0xFFF7F9F7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
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
                  child: Icon(Icons.restore_page_outlined, size: 40, color: darkGreen),
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
                  color: Color(0xFF1E1E1E),
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
                    suffixIcon: Icon(Icons.mail_outline, color: Color(0xFF5A5A5A)),
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
                  backgroundColor: const Color(0xFF758D7B),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Invia link di recupero",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF5A5A5A), size: 16),
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