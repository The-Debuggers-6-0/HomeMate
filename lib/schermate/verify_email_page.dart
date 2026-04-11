import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_checker.dart'; // Importiamo il controllore

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final Color darkGreen = const Color(0xFF2C5542);
  final Color greyTextColor = const Color(0xFF707070);
  
  bool isEmailVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Controlla ogni 3 secondi se l'email è stata verificata
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      if (!mounted) return;
      setState(() {
        isEmailVerified = true;
      });
      timer?.cancel();
      
      // LA CORREZIONE: Invece di andare alla Home demo, 
      // andiamo all'AuthChecker che deciderà cosa mostrarti (Profilo o Casa)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthChecker(user: user)),
      );
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Nuova email inviata!"), backgroundColor: darkGreen),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aspetta un po' prima di inviarne un'altra."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => FirebaseAuth.instance.signOut(), 
        ),
        title: const Text("Maison Soft", style: TextStyle(color: Color(0xFF2C5542), fontWeight: FontWeight.bold)),
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
              child: Icon(Icons.mark_email_read_rounded, size: 80, color: darkGreen),
            ),
            const SizedBox(height: 40),

            Text(
              "Verifica la tua mail",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkGreen),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: greyTextColor, fontSize: 16, height: 1.5),
                children: [
                  const TextSpan(text: "Abbiamo inviato un link di conferma a\n"),
                  TextSpan(text: "${user?.email ?? 'tua email'}", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  const TextSpan(text: ".\n\nControlla la tua casella di posta e clicca sul link. Questa pagina si aggiornerà da sola!"),
                ],
              ),
            ),
            const SizedBox(height: 40),

            CircularProgressIndicator(color: darkGreen),
            const SizedBox(height: 48),

            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text("Torna al Login", style: TextStyle(color: darkGreen, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: sendVerificationEmail,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: greyTextColor, fontSize: 14),
                  children: [
                    const TextSpan(text: "Non hai ricevuto l'email? "),
                    TextSpan(text: "Inviane un'altra", style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
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
