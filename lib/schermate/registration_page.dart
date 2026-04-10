import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Controller per leggere i dati inseriti
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Variabili per mostrare/nascondere le password
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Colori presi dal prototipo
  final Color darkGreen = Color(0xFF2C5542);
  final Color lightBackground = Color(0xFFF2F6F3);
  final Color greyTextColor = Color(0xFF707070);
  final Color inputFieldColor = Color(0xFFE0E0E0);

  // --- LOGICA FIREBASE: REGISTRAZIONE ---
  Future<void> _registerWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 1. Controlla che i campi non siano vuoti
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showErrorSnackBar("Per favore, compila tutti i campi.");
      return;
    }

    // 2. Controlla che le password coincidano
    if (password != confirmPassword) {
      _showErrorSnackBar("Le password non coincidono.");
      return;
    }

    // 3. Controlla la lunghezza minima della password
    if (password.length < 8) {
      _showErrorSnackBar("La password deve avere almeno 8 caratteri.");
      return;
    }

    try {
      // Mostra un caricamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator(color: darkGreen)),
      );

      // PASSO 1: Crea l'utente nell'Autenticazione (La "Chiave")
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // INVIA L'EMAIL DI VERIFICA ---
      await userCredential.user!.sendEmailVerification();

      // PASSO 2: Salva il profilo nel Database (La "Cartellina")
      // Usiamo l'UID dell'utente come nome del documento per trovarlo facilmente in futuro
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(), // Salva l'ora esatta della registrazione
        'role': 'membro', // Un dato di esempio che potrebbe servirti
        // In futuro, se aggiungi un campo "Nome" nel design, potrai salvarlo qui!
      });

      // Se arriva qui, tutto è andato a buon fine!
      Navigator.pop(context); // Chiude il dialog di caricamento
      Navigator.pop(context); // Chiude la pagina di registrazione e lo StreamBuilder fa il resto

      // Avvisa l'utente di controllare la posta!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registrazione completata! Ti abbiamo inviato un'email di verifica. Controlla la posta!"), 
          backgroundColor: darkGreen, // Usiamo il verde perché è un successo, non un errore!
        ),
      );  

    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Chiude il dialog
      String message = "Errore durante la registrazione.";
      if (e.code == 'weak-password') {
        message = "La password fornita è troppo debole.";
      } else if (e.code == 'email-already-in-use') {
        message = "Esiste già un account con questa email.";
      } else if (e.code == 'invalid-email') {
        message = "Il formato dell'email non è valido.";
      }
      _showErrorSnackBar(message);
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar("Errore imprevisto: ${e.toString()}");
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),

              // --- Titolo Principale ---
              Center(
                child: Text(
                  "Unisciti\nalla casa",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkGreen,  
                    fontSize: 60,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
                ),
              ),
              SizedBox(height: 24),

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
                      hint: "esempio@sanctuary.com",
                    ),
                    SizedBox(height: 32),

                    // --- Campo Password ---
                    Text("Password", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    _buildInputField(
                      controller: _passwordController,
                      hint: "Minimo 8 caratteri",
                      isPassword: true,
                      obscureState: _obscurePassword,
                      onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                      iconRight: Icons.visibility_outlined, // Icona occhio
                    ),
                    SizedBox(height: 32),

                    // --- Campo Conferma Password ---
                    Text("Conferma Password", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    _buildInputField(
                      controller: _confirmPasswordController,
                      hint: "Ripeti la tua password",
                      isPassword: true,
                      obscureState: _obscureConfirmPassword,
                      onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      iconRight: Icons.lock_reset_outlined, // Icona lucchetto con freccia del design
                    ),
                    SizedBox(height: 40),

                    // --- Pulsante REGISTRATI ---
                    ElevatedButton(
                      onPressed: _registerWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text("Registrati", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // --- Testo Footer (Hai già un account? Accedi) ---
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Torna alla pagina di login precedente
                    Navigator.pop(context); 
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: greyTextColor, fontSize: 16),
                      children: [
                        TextSpan(text: "Hai già un account? "),
                        TextSpan(text: "Accedi", style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
                        WidgetSpan(
                          child: Icon(Icons.login, size: 16, color: darkGreen),
                          alignment: PlaceholderAlignment.middle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Widget utility personalizzato per questa pagina (senza icone a sinistra)
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool? obscureState,
    VoidCallback? onToggleObscure,
    IconData? iconRight,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputFieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureState! : false,
        style: TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          // Aggiunge l'icona a destra solo se viene passata alla funzione
          suffixIcon: isPassword && iconRight != null
              ? IconButton(
                  icon: Icon(iconRight, color: Colors.black87),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}