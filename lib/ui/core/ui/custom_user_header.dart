import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Usa Ctrl + . (o Cmd + .) se questo import ti dà errore per sistemare il percorso
import '../../auth/view_model/auth_view_model.dart';
import '../themes/app_colors.dart'; // Aggiunto per i colori

class CustomUserHeader extends StatelessWidget {
  final String greetingText; // Es: "BENTORNATO" o "BENVENUTO A CASA"
  final bool showBell;       // Mostrare la campanella? (Vero o Falso)

  const CustomUserHeader({
    super.key,
    this.greetingText = 'BENTORNATO', // Valore predefinito
    this.showBell = true,             // Valore predefinito
  });

  @override
  Widget build(BuildContext context) {
    // 1. Il widget ascolta in autonomia i dati dell'utente!
    final authViewModel = context.watch<AuthViewModel>();
    final userProfile = authViewModel.userProfile;

    final String nome = userProfile?.name ?? 'Utente';
    final String photoBase64 = userProfile?.photoUrl ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // --- PARTE SINISTRA: Foto e Testi ---
        Row(
          children: [
            // Immagine Profilo Dinamica
            CircleAvatar(
              radius: 22, 
              backgroundColor: Colors.grey.shade300,
              backgroundImage: photoBase64.isNotEmpty 
                  ? MemoryImage(base64Decode(photoBase64)) 
                  : null,
              child: photoBase64.isEmpty 
                  ? const Icon(Icons.person, color: Colors.white, size: 24) 
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Testi ("BENTORNATO" + "Ciao, nome")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greetingText.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Ciao, $nome',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Cambia in AppColors.textDark se necessario
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // --- PARTE DESTRA: Campanella (Opzionale) ---
        if (showBell)
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 28),
            onPressed: () {
              // Qui in futuro metteremo la logica delle notifiche
            },
          )
        else
          const SizedBox(width: 48), // Spazio per bilanciare se manca la campanella
      ],
    );
  }
}