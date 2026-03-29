import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final Color darkGreen = Color(0xFF2C5542);
  final Color greyTextColor = Color(0xFF707070);
  
  bool isEmailVerified = false;
  Timer? timer;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    // Inizia a controllare in background ogni 3 secondi!
    timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      // LA CORREZIONE: Lo forziamo noi ad andare alla Home!
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()), // Cambia in HomeScreen se si chiama diversamente
      );
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await user.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nuova email inviata!"), backgroundColor: darkGreen),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Aspetta un po' prima di inviarne un'altra."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => FirebaseAuth.instance.signOut(), // Torna al login
        ),
        title: Text("Maison Soft", style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Color(0xFFE9EFE9),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(Icons.mark_email_read_rounded, size: 80, color: darkGreen),
            ),
            SizedBox(height: 40),

            Text(
              "Verifica la tua mail",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkGreen),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: greyTextColor, fontSize: 16, height: 1.5),
                children: [
                  TextSpan(text: "Abbiamo inviato un link di conferma a\n"),
                  TextSpan(text: "${user.email}", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  TextSpan(text: ".\n\nControlla la tua casella di posta e clicca sul link. Questa pagina si aggiornerà da sola!"),
                ],
              ),
            ),
            SizedBox(height: 40),

            // --- Animazione di attesa ---
            CircularProgressIndicator(color: darkGreen),
            SizedBox(height: 48),

            // --- Torna al Login (in caso abbiano sbagliato a scrivere la mail) ---
            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text("Torna al Login", style: TextStyle(color: darkGreen, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 24),

            GestureDetector(
              onTap: sendVerificationEmail,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: greyTextColor, fontSize: 14),
                  children: [
                    TextSpan(text: "Non hai ricevuto l'email? "),
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