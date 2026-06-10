import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../view_model/edit_profile_view_model.dart';
import '../view_model/profile_view_model.dart';
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
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
                onTap: _pickImage,
                child: Stack(
                  children: [
                    // --- FOTO PROFILO NELLA MODIFICA ---
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,

                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (widget.currentPhotoUrl != null && widget.currentPhotoUrl!.isNotEmpty)
                              ? MemoryImage(base64Decode(widget.currentPhotoUrl!))
                              : null,
                      // Mostra l'icona di default se non c'è nessuna foto
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
              maxLines: 3,
            ),
            const SizedBox(height: 48),

            // --- Pulsante Salva ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final profileViewModel = context.read<ProfileViewModel>();
                  final currentUser = profileViewModel.userProfile;

                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Errore: impossibile trovare l\'utente.'),
                      ),
                    );
                    return;
                  }

                  await viewModel.saveProfile(
                    currentUser,
                    _nameController.text,
                    _surnameController.text,
                    _bioController.text,
                    _selectedImage,
                  );

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

  /// Crea i campi di testo con stile uniforme.
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
