import 'package:flutter/material.dart';

// --- NUOVE IMPORTAZIONI FIREBASE ---
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 
// -----------------------------------

import 'schermate/home_screen.dart';
import 'theme/app_colors.dart';
import 'schermate/finanze_screen.dart';
import 'schermate/login_page.dart';
import 'schermate/verify_email_page.dart';

// --- FUNZIONE MAIN AGGIORNATA ---
Future<void> main() async {
  // Assicura che Flutter sia pronto prima di avviare Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza Firebase con le chiavi del tuo progetto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // DISABILITATO, solo in caso di test del logout:
  await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}
// --------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HomeMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),

      // Se l'utente è loggato, mostra HomeScreen, altrimenti mostra LoginPage
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Se snapshot ha dati, l'utente è già loggato
          if (snapshot.hasData) {
            // Controlla se la mail è verificata!
            if (snapshot.data!.emailVerified) {
              return HomeScreen(); // Va alla Home
            } else {
              return VerifyEmailPage(); // Lo blocca qui!
            }
          }   
        // Altrimenti, mostra la pagina di Login
        return LoginPage();
        },
      ),
    );
  }
}