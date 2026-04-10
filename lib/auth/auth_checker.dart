import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../schermate/main_layout.dart'; // Riferimento modificato
import '../schermate/setup_profile_page.dart'; // Riferimento modificato

class AuthChecker extends StatefulWidget {
  final User user;
  const AuthChecker({super.key, required this.user});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  late Future<DocumentSnapshot> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _userProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Errore caricamento profilo: ${snapshot.error}")),
          );
        }

        // Mostra un caricamento mentre controlla Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAF9),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF2C5542))),
          );
        }

        // Recupera i dati del documento Firestore
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final profileCompleted = data?['profileCompleted'] ?? false;

          if (profileCompleted == true) {
            return const MainLayout(); // Se completato, vai alla Home master
          } else {
            return const SetupProfilePage(); // Altrimenti completa il profilo
          }
        }

        // Se il documento non esiste ancora
        return const SetupProfilePage();
      },
    );
  }
}
