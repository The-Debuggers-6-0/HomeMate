import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../view_model/edit_profile_view_model.dart';
import '../../auth/view_model/auth_view_model.dart';
import 'dart:io'; // Per usare la classe File
import 'package:image_picker/image_picker.dart'; // Pacchetto per la selezione delle immagini
import 'dart:convert'; // Per la codifica e decodifica base64

/// View per la modifica del profilo.
/// Si occupa solo della parte grafica e dell'input utente.
class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentSurname;
  final String currentBio;
  final String? currentPhotoUrl;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentSurname,
    required this.currentBio,
    this.currentPhotoUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller per leggere e scrivere nei campi di testo
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _bioController;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Usiamo widget. per accedere alle variabili definite nella classe sopra
    _nameController = TextEditingController(text: widget.currentName);
    _surnameController = TextEditingController(text: widget.currentSurname);
    _bioController = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // --- NUOVA FUNZIONE PER APRIRE LA GALLERIA ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Apriamo la galleria (puoi anche usare ImageSource.camera per la fotocamera)
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
      maxWidth: 400,
      maxHeight: 400,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditProfileViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          "Modifica Profilo",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Avatar e Pulsante Fotocamera ---
            Center(
              child: GestureDetector(
                onTap: _pickImage, // Quando tocchi, apre la galleria!
                child: Stack(
                  children: [
                    // --- FOTO PROFILO NELLA MODIFICA ---
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,

                      // --- LOGICA DI VISUALIZZAZIONE PRIORITARIA ---
                      backgroundImage: _selectedImage != null
                          ? FileImage(
                              _selectedImage!,
                            ) // 1. Mostra subito la NUOVA foto scelta
                          : (widget.currentPhotoUrl != null &&
                                widget.currentPhotoUrl!.isNotEmpty)
                          ? MemoryImage(
                              base64Decode(widget.currentPhotoUrl!),
                            ) // 2. Altrimenti, mostra la VECCHIA in Base64
                          : null, // 3. Altrimenti, cerchio vuoto
                      // Mostriamo l'omino bianco solo se non c'è nessuna foto
                      child:
                          (_selectedImage == null &&
                              (widget.currentPhotoUrl == null ||
                                  widget.currentPhotoUrl!.isEmpty))
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Campo Nome ---
            Text(
              "Nome",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: "Il tuo nome",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 24),

            // --- Campo Cognome ---
            Text(
              "Cognome",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _surnameController,
              hintText: "Il tuo cognome",
              icon: Icons.person_outline,
            ),

            // --- Campo Bio ---
            Text(
              "Bio",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _bioController,
              hintText: "Scrivi qualcosa su di te...",
              icon: Icons.edit_note,
              maxLines: 3, // Rende il campo più alto per il testo lungo
            ),
            const SizedBox(height: 48),

            // --- Pulsante Salva ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  // 1. Leggiamo l'utente attuale dall'AuthViewModel (senza ricaricare la pagina)
                  final authViewModel = context.read<AuthViewModel>();
                  final currentUser = authViewModel.userProfile;

                  // Controllo di sicurezza: se per qualche motivo l'utente non c'è, ci fermiamo
                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Errore: impossibile trovare l\'utente.'),
                      ),
                    );
                    return;
                  }

                  // 2. Ora chiamiamo il saveProfile passando TUTTI E 3 i parametri!
                  await viewModel.saveProfile(
                    currentUser, // 1° parametro: l'utente attuale
                    _nameController.text, // 2° parametro: il nuovo nome
                    _surnameController.text, // 3° parametro: il nuovo cognome
                    _bioController.text, // 4° parametro: la nuova bio
                    _selectedImage, // 5° parametro: l'immagine selezionata (può essere null se non è stata cambiata)
                  );

                  // 3. Mostriamo il messaggio di successo e torniamo alla pagina precedente
                  // Nota: usiamo mounted per assicurarci che la pagina esista ancora dopo il salvataggio
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profilo aggiornato con successo!'),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Salva Modifiche",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Metodo helper per creare i campi di testo con lo stesso stile ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.cardBackground, // Usa il colore bianco delle card
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: AppColors.textSecondary)
            : null,
        // Bordo quando non selezionato
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        // Bordo quando selezionato (verde)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
    );
  }
}
