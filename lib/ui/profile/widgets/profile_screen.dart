import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../view_model/profile_view_model.dart';
import '../../core/themes/app_colors.dart';
import 'edit_profile_screen.dart';
import '../../../ui/auth/widgets/login_screen.dart';
import '../../house/widgets/add_house_screen.dart';

/// Schermata Profilo. View pura che legge i dati da [ProfileViewModel].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    if (viewModel.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      // --- 1. AGGIUNGI QUESTO (Fa comparire la freccia indietro!) ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // O AppColors.textDark
      ),

      body: SafeArea(
        child: SizedBox(
          // <--- 1. AGGIUNTO SIZEDBOX
          width: double
              .infinity, // <--- 2. PRENDE TUTTA LA LARGHEZZA DELLO SCHERMO
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // <--- 3. CENTRA GLI ELEMENTI
              children: [
                const SizedBox(height: 48),

                // --- FOTO PROFILO CENTRALE ---
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGreen, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,

                    // 1. ORA CONTROLLIAMO SE C'È UNA FOTO SALVATA!
                    // Sostituisci 'photoUrl' col nome esatto che hai nel tuo modello AppUser
                    backgroundImage:
                        (viewModel.userProfile?.photoUrl != null &&
                            viewModel.userProfile!.photoUrl!.isNotEmpty)
                        ? MemoryImage(
                            base64Decode(viewModel.userProfile!.photoUrl!),
                          )
                        : null,

                    // 2. MOSTRA L'ICONA SOLO SE LA FOTO NON C'È
                    child:
                        (viewModel.userProfile?.photoUrl == null ||
                            viewModel.userProfile!.photoUrl!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                // --- NOME E COGNOME ---
                Text(
                  viewModel.fullName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // --- BIO / EMAIL ---
                Text(
                  viewModel.bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ), // Spazio tra la bio e il nuovo bottone
                // --- PULSANTE MODIFICA PROFILO ---
                OutlinedButton.icon(
                  onPressed: () async {
                    // 1. Apri la pagina e aspetta che l'utente finisca e la chiuda
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          currentName: viewModel.userProfile?.name ?? '',
                          currentSurname: viewModel.userProfile?.surname ?? '',
                          currentBio: viewModel.userProfile?.bio ?? '',
                          currentPhotoUrl: viewModel.userProfile?.photoUrl,
                        ),
                      ),
                    );
                    // 2. Quando l'utente torna indietro (ha salvato o annullato),
                    // diciamo al ViewModel di riscaricare i dati freschi!
                    viewModel.reloadProfile();
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
                  label: const Text(
                    "Modifica profilo",
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- ZONA LA MIA CASA ---
                if (viewModel.currentHouse != null)
                  _buildHouseSection(context, viewModel),
                if (viewModel.currentHouse == null)
                  const Text("Non fai ancora parte di una casa.", style: TextStyle(color: Colors.grey)),
                  
                const SizedBox(height: 48),

                /*
              // --- PULSANTE LOGOUT ---
              TextButton.icon(
                onPressed: () async {
                  // 1. Mostra il pop-up
                  final bool? confirmLogout = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Disconnessione'),
                        content: const Text(
                          'Vuoi davvero effettuare il logout?',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        actions: [
                          // Bottone NO
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'No',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Bottone SI
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              'Sì',
                              style: TextStyle(
                                color: AppColors.accentRed,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  // 2. Se l'utente clicca Sì (true), eseguiamo il logout vero e proprio
                  if (confirmLogout == true) {
                    viewModel.logout();
                  }
                },
                // --- PARTE GRAFICA DEL BOTTONE ---
                icon: const Icon(Icons.logout, color: AppColors.accentRed),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- PULSANTE ELIMINA ACCOUNT ---
              TextButton.icon(
                onPressed: () async {
                  // 1. Mostriamo il pop-up di ALLARME ROSSO
                  final bool? confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: const [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Attenzione'),
                          ],
                        ),
                        content: const Text(
                          'Sei sicuro di voler eliminare definitivamente il tuo account?\n\nQuesta azione è irreversibile e tutti i tuoi dati, la tua bio e le tue foto verranno cancellati per sempre.',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        actions: [
                          // Bottone ANNULLA (in evidenza per salvarli)
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Annulla',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Bottone ELIMINA (rosso e spaventoso)
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Elimina per sempre',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  // 2. Se l'utente clicca "Elimina per sempre" (true)...
                  if (confirmDelete == true) {
                    // 1. Il ViewModel fa esplodere i dati su Firebase
                    await viewModel.deleteAccount();

                    // 2. Controllo di sicurezza di Flutter (obbligatorio dopo un 'await')
                    if (context.mounted) {
                      // 3. Ti butto fuori alla schermata di Login e cancello la cronologia!
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  "Elimina Account",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              */

                // --- ZONA OPZIONI ACCOUNT ---

                // 1. Tasto Logout (Più sobrio e con Popup di conferma!)
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text(
                            'Logout',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            'Sei sicuro di voler uscire dal tuo account?',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // Angoli arrotondati in stile app
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(
                                  dialogContext,
                                ).pop(); // Chiude il popup senza fare nulla
                              },
                              child: const Text(
                                'Annulla',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                // 1. Chiude il popup
                                Navigator.of(dialogContext).pop();

                                // 2. Esegue il logout tramite il ViewModel
                                await context.read<ProfileViewModel>().logout();

                                // 3. Teletrasporta l'utente alla schermata iniziale e cancella la cronologia!
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    // Teletrasporta l'utente alla schermata di Login
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                    (Route<dynamic> route) =>
                                        false, // Distrugge le schermate precedenti (non puoi fare "indietro")
                                  );
                                }
                              },
                              child: Text(
                                'Esci',
                                style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.grey),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16), // Spazio prima della linea
                // 2. Il tuo separatore elegante!
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Divider(color: Colors.grey.shade300, thickness: 1),
                ),

                const SizedBox(height: 16), // Spazio dopo la linea
                // 3. Bottone Elimina Account (Danger Zone CON POPUP DI SICUREZZA)
                OutlinedButton.icon(
                  onPressed: () {
                    // --- APRIAMO IL POPUP DI CONFERMA ---
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: Text(
                            'Attenzione!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade600,
                            ),
                          ),
                          content: const Text(
                            'Sei sicuro di voler eliminare definitivamente il tuo account? Questa azione è irreversibile e perderai tutti i tuoi dati associati alla casa.',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(
                                  dialogContext,
                                ).pop(); // Chiude il popup senza fare danni
                              },
                              child: const Text(
                                'Annulla',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                // 1. Chiude il popup
                                Navigator.of(dialogContext).pop();

                                // 2. --- IL MOTORE DELL'ELIMINAZIONE CHE ABBIAMO SCRITTO PRIMA ---
                                try {
                                  final success = await context
                                      .read<ProfileViewModel>()
                                      .deleteAccount();

                                  if (context.mounted) {
                                    if (success) {
                                      // Eliminazione totale riuscita! Andiamo alla schermata iniziale
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Errore durante l\'eliminazione. Riprova.',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  // GESTIONE ERRORE FIREBASE: Il login è troppo vecchio
                                  if (context.mounted &&
                                      e.toString().contains(
                                        'requires-recent-login',
                                      )) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Per motivi di sicurezza, devi effettuare nuovamente l\'accesso per eliminare l\'account.',
                                        ),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                    // Mandiamo l'utente al Login per fare l'accesso fresco
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                      (Route<dynamic> route) => false,
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'Elimina',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  // --- LA CARROZZERIA DEL BOTTONE ---
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    side: BorderSide(color: Colors.red.shade400, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(
                    'Elimina Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  void _mostraDialogModificaNome(BuildContext context, ProfileViewModel viewModel) {
    final TextEditingController nameController = TextEditingController(text: viewModel.currentHouse!.nome);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modifica Nome Casa'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Nuovo nome...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await viewModel.updateHouseName(nameController.text);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _confermaAbbandono(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Abbandona Casa'),
        content: const Text('Sei sicuro di voler abbandonare questa casa? Non potrai più accedere ai dati finché non sarai invitato di nuovo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext); // Chiude il dialog
              final success = await viewModel.leaveHouse();
              if (success && context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHouseScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Abbandona', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseSection(BuildContext context, ProfileViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.finanzeBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        viewModel.currentHouse!.nome,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: AppColors.textSecondary),
                      onPressed: () => _mostraDialogModificaNome(context, viewModel),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: viewModel.currentHouse!.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Codice casa copiato negli appunti!"),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        viewModel.currentHouse!.id,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy, size: 14, color: AppColors.primaryGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Membri della casa",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Mostra avatar orizzontali dei coinquilini
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.roommates.length,
              itemBuilder: (context, index) {
                final roommate = viewModel.roommates[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.lightGreen,
                        backgroundImage: (roommate.photoUrl != null && roommate.photoUrl!.isNotEmpty)
                            ? MemoryImage(base64Decode(roommate.photoUrl!))
                            : null,
                        child: (roommate.photoUrl == null || roommate.photoUrl!.isEmpty)
                            ? Text(
                                roommate.name.isNotEmpty ? roommate.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roommate.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Abbandona Casa', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _confermaAbbandono(context, viewModel),
            ),
          ),
        ],
      ),
    );
  }
}
