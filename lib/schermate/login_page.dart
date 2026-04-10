import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_page.dart';
import 'forgot_password_page.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_checker.dart'; // Nuova schermata di controllo

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller per leggere i dati inseriti dall'utente
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Metti a true per disattivare rapidamente tutti i pulsanti/tap.
  final bool _disableActions = false;
  
  // Variabile per mostrare/nascondere la password
  bool _obscurePassword = true;

  // Definizione dei colori presi dal prototipo
  final Color darkGreen = Color(0xFF2C5542); // Verde scuro del testo e pulsante
  final Color lightBackground = Color(0xFFF2F6F3); // Sfondo chiaro della scheda
  final Color greyTextColor = Color(0xFF707070); // Grigio del sottotitolo e etichette
  final Color inputFieldColor = Color(0xFFE0E0E0); // Grigio chiaro dei campi input

  // --- LOGICA FIREBASE: LOGIN EMAIL/PASSWORD ---
  Future<void> _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar("Per favore, compila tutti i campi.");
      return;
    }

    try {
      // Mostra un caricamento (opzionale, ma consigliato)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator(color: darkGreen)),
      );

      // Tenta il login con Firebase
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Login riuscito: chiudi il caricamento e controlla il profilo
      Navigator.pop(context); // Chiude il dialog
      print("Login riuscito!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthChecker(user: userCredential.user!)),
      );

    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Chiude il dialog
      String message = "Errore durante il login.";
      if (e.code == 'user-not-found') {
        message = "Nessun utente trovato per questa email.";
      } else if (e.code == 'wrong-password') {
        message = "Password errata.";
      }
      _showErrorSnackBar(message);
    } catch (e) {
      Navigator.pop(context); // Chiude il dialog
      _showErrorSnackBar("Errore imprevisto: ${e.toString()}");
    }
  }

  // --- LOGICA GOOGLE SIGN-IN ---
  Future<void> _loginWithGoogle() async {
    try {
      // Mostra un caricamento per far capire che sta lavorando
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator(color: darkGreen)),
      );

      // 1. Inizializza il nuovo Google Sign In
      await GoogleSignIn.instance.initialize(
        serverClientId: '888055527021-qnbqpe4o7dp1io5mo6vln0eq75g8uate.apps.googleusercontent.com',
      );

      // 2. Avvia la finestra di Google usando l'istanza corretta
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // 3. Ottieni i "documenti" da Google
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 4. Trasforma i documenti in una chiave per Firebase
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 5. Entra in Firebase
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // 6. Salva l'utente nel tuo Database Firestore!
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'name': userCredential.user!.displayName ?? 'Utente Google',
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 7. Login completato!
      if (!mounted) return;
      Navigator.pop(context); // Chiude il caricamento
      
      // Controlla se andare alla home o al setup profilo!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthChecker(user: userCredential.user!)),
      );

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Chiude il caricamento
      _showErrorSnackBar("Errore Google Sign-In: ${e.toString()}");
    }
  }

  // Funzione utility per mostrare errori
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sfondo pagina principale
      // SafeArea impedisce che il contenuto vada sotto la barra di stato o notch
      body: SafeArea(
        child: SingleChildScrollView( // Permette lo scroll se la tastiera copre lo schermo
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              // --- Titolo Principale ---
              Center(
                child: Text(
                  "Bentornato\na casa", // Il '\n' forza l'andata a capo
                  textAlign: TextAlign.center, // Centra il testo all'interno del widget Text
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 60, // Dimensione grande per il titolo
                    fontWeight: FontWeight.bold,
                    height: 1.1, // Spaziatura interlinea stretta per un look moderno
                  ),
                ),
              ),
              SizedBox(height: 24), // Spazio tra titolo e form

              // --- Scheda Bianca Arrotondata del Form ---
              Container(
                padding: EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: lightBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Campo Email ---
                    Text("Email", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    _buildInputField(
                      controller: _emailController,
                      hint: "nome@esempio.it",
                      icon: Icons.email_outlined,
                    ),
                    SizedBox(height: 24),

                    // --- Campo Password + Link Dimenticata ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Password", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                        GestureDetector( // O TextButton, a seconda di cosa hai usato
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                            );
                          },
                          child: Text(
                            "Hai dimenticato la password?",
                            style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
                          ),
                        ),  
                      ],
                    ),
                    SizedBox(height: 8),
                    _buildInputField(
                      controller: _passwordController,
                      hint: "........",
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    SizedBox(height: 32),

                    // --- Pulsante ACCEDI ---
                    ElevatedButton(
                      onPressed: _disableActions ? null : _loginWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56), // Alto e largo tutto lo schermo
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Accedi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // --- Divisore OPPURE ---
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text("OPPURE", style: TextStyle(color: Colors.grey[400], fontSize: 12, letterSpacing: 1.5)),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    SizedBox(height: 32),

                    // --- Pulsante GOOGLE ---
                    OutlinedButton(
                      onPressed: _disableActions ? null : _loginWithGoogle,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey[300]!), // Bordo leggero
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Se hai il logo Google come asset, usa: Image.asset('assets/google_logo.png', height: 24)
                          Image.asset('assets/images/icons8-logo-di-google-144.png', height: 24),
                          SizedBox(width: 12),
                          Text("Continua con Google", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // --- Testo Footer (Non hai un account? Registrati) ---
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegistrationPage()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: greyTextColor, fontSize: 16),
                      children: [
                        TextSpan(text: "Non hai un account? "),
                        TextSpan(text: "Registrati", style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32), // Spazio finale
            ],
          ),
        ),
      ),
    );
  }

  // Widget utility per creare i campi input (Email e Password)
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputFieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false, // Nasconde il testo se password
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: greyTextColor), // Icona a sinistra
          suffixIcon: isPassword // Icona occhio a destra solo per la password
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: greyTextColor),
                  onPressed: _disableActions ? null : () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none, // Nasconde il bordo di default di Flutter
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}