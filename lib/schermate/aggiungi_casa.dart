import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../auth/auth_checker.dart';

class AggiungiCasaScreen extends StatefulWidget {
  const AggiungiCasaScreen({super.key});

  @override
  State<AggiungiCasaScreen> createState() => _AggiungiCasaScreenState();
}

class _AggiungiCasaScreenState extends State<AggiungiCasaScreen> {
  final TextEditingController _codiceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codiceController.dispose();
    super.dispose();
  }

  // Funzione per generare un codice univoco di 6 caratteri
  String _generaCodiceCasa() {
    const caratteri = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(6, (index) => caratteri[random.nextInt(caratteri.length)]).join();
  }

  // LOGICA: CREA NUOVA CASA
  Future<void> _creaNuovaCasa() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String nuovoCodice = _generaCodiceCasa();
      
      // 1. Crea il documento della casa su Firestore
      await FirebaseFirestore.instance.collection('houses').doc(nuovoCodice).set({
        'admin': user.uid,
        'membri': [user.uid],
        'nome': "Casa di ${user.displayName ?? 'Nuovo Utente'}",
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Aggiorna l'utente con il nuovo homeId
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'homeId': nuovoCodice,
      });

      if (!mounted) return;
      
      // Naviga all'AuthChecker per rinfrescare lo stato e andare alla Home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthChecker(user: user)),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore durante la creazione: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // LOGICA: UNISCITI A CASA ESISTENTE
  Future<void> _uniscitiACasa() async {
    String codice = _codiceController.text.trim().toUpperCase();

    if (codice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci un codice valido.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. Controlla se la casa esiste
      var houseDoc = await FirebaseFirestore.instance.collection('houses').doc(codice).get();

      if (houseDoc.exists) {
        // 2. Aggiungi l'utente ai membri della casa
        await houseDoc.reference.update({
          'membri': FieldValue.arrayUnion([user.uid]),
        });

        // 3. Aggiorna l'homeId dell'utente
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'homeId': codice,
        });

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthChecker(user: user)),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Codice casa non trovato."), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Benvenuto a Casa',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Inizia il tuo viaggio.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF324A3D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'La gestione della tua casa non è mai stata così semplice e armoniosa. Scegli come vuoi cominciare oggi.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // --- CARD: CREA UNA NUOVA CASA ---
            _buildActionCard(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD3E4D8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.home_outlined, size: 50, color: Color(0xFF324A3D)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0D6C1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Crea una nuova casa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inizia da zero, definisci le stanze e invita i tuoi coinquilini o familiari.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8073),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _creaNuovaCasa,
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Inizia una nuova avventura', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- CARD: UNISCITI A UNA CASA ---
            _buildActionCard(
              backgroundColor: const Color(0xFFF3F2EE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person_add_outlined, color: Color(0xFF6B8073)),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unisciti a una casa esistente',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Inserisci il codice ricevuto dal proprietario.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CODICE CASA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codiceController,
                    decoration: InputDecoration(
                      hintText: 'ABC - 123',
                      filled: true,
                      fillColor: const Color(0xFFE5E3DD),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B8073),
                        side: const BorderSide(color: Color(0xFF6B8073)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white.withOpacity(0.5),
                      ),
                      onPressed: _isLoading ? null : _uniscitiACasa,
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF6B8073), strokeWidth: 2))
                        : const Text('Unisciti', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required Widget child, Color backgroundColor = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (backgroundColor == Colors.white)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: child,
    );
  }
}
