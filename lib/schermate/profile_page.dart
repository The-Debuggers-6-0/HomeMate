import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Nessun utente loggato.")),
      );
    }

    final Color darkGreen = const Color(0xFF2C5542);
    final Color textColor = const Color(0xFF1E1E1E);
    final Color subtitleColor = const Color(0xFF5A5A5A);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF9),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            // Stato di caricamento
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: darkGreen));
            }

            // Dati utente
            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            final name = userData?['name'] ?? 'Utente';
            final surname = userData?['surname'] ?? '';
            final bio = userData?['bio'] ?? user.email ?? '';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // --- HEADER: Ciao, Nome ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade300,
                            // Puoi inserire un'immagine placeholder qui
                            child: const Icon(Icons.person, size: 20, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Ciao, $name",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.notifications_none, color: subtitleColor),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // --- FOTO PROFILO CENTRALE ---
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Bordo esterno verde
                      Container(
                        padding: const EdgeInsets.all(4), // Distanza tra foto e bordo
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: darkGreen.withOpacity(0.8), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                      ),
                      // Iconina modifica
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: darkGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF9FAF9), width: 2),
                        ),
                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- NOME E COGNOME ---
                  Text(
                    "$name $surname".trim(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- BIO / EMAIL ---
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                  
                  // Spacer spinge il pulsante di logout tutto verso il basso
                  const Spacer(),

                  // --- PULSANTE LOGOUT ---
                  TextButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, color: Color(0xFFC62828)),
                    label: const Text(
                      "Disconnetti Account",
                      style: TextStyle(
                        color: Color(0xFFC62828),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Spazio per la bottom navigation bar
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

