import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // Scommenta quando configuri Google

class LoginPage extends StatefulWidget {
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Login riuscito: chiudi il caricamento e vai alla Home
      Navigator.pop(context); // Chiude il dialog
      print("Login riuscito!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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

  // --- LOGICA (ABBOZZO) GOOGLE SIGN-IN ---
  Future<void> _loginWithGoogle() async {
    _showErrorSnackBar("Login con Google non ancora configurato (richiede SHA-1).");
    /* Scommenta e usa questo codice dopo la configurazione SHA-1
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      print("Login Google riuscito!");
      // Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorSnackBar("Errore Google Sign-In: ${e.toString()}");
    }
    */
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
              // --- Barra Superiore (Icona Casa, Accedi, Aiuto) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.home_outlined, color: darkGreen),
                      SizedBox(width: 8),
                      Text("Accedi", style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Icon(Icons.help_outline, color: Colors.grey[400]),
                ],
              ),
              SizedBox(height: 32),

              // --- Titolo Principale ---
              Text(
                "Bentornato a\ncasa",
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1.1, // Spaziatura interlinea stretta come nel prototipo
                ),
              ),
              SizedBox(height: 16),

              // --- Sottotitolo ---
              Text(
                "Il tuo rifugio digitale ti aspetta. Gestisci i tuoi compiti e le tue finanze in totale armonia.",
                style: TextStyle(color: greyTextColor, fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 40),

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
                    Text("Email", style: TextStyle(color: greyTextColor, fontWeight: FontWeight.w500)),
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
                        Text("Password", style: TextStyle(color: greyTextColor, fontWeight: FontWeight.w500)),
                        GestureDetector(
                          onTap: _disableActions ? null : () { /* Logica Password Dimenticata */ },
                          child: Text("Hai dimenticato la password?", style: TextStyle(color: darkGreen, fontSize: 12, fontWeight: FontWeight.w500)),
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
              SizedBox(height: 48),

              // --- Testo Footer (Non hai un account? Registrati) ---
              Center(
                child: GestureDetector(
                  onTap: _disableActions ? null : () { /* Logica vai a Registrazione */ },
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
              SizedBox(height: 16), // Spazio finale
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