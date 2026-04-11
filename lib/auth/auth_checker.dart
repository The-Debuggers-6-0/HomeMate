import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../schermate/main_layout.dart';
import '../schermate/setup_profile_page.dart';
import '../schermate/aggiungi_casa.dart'; // Importo la tua nuova pagina

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

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAF9),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF2C5542))),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final profileCompleted = data?['profileCompleted'] ?? false;
          // Controlliamo se l'utente è già associato a una casa
          final homeId = data?['homeId'] ?? "";

          if (profileCompleted == true) {
            if (homeId.isEmpty) {
              // Se ha il profilo OK ma non ha una casa, mostra la tua pagina
              return const AggiungiCasaScreen();
            } else {
              // Se ha tutto, vai alla Home master
              return const MainLayout();
            }
          } else {
            return const SetupProfilePage();
          }
        }

        return const SetupProfilePage();
      },
    );
  }
}
