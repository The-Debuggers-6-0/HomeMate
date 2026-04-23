import 'package:flutter/material.dart';
//Adatta questi import al percorso reale del tuo progetto:
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/app_user.dart';
import 'dart:io';

class EditProfileViewModel extends ChangeNotifier {
  // Riferimento al repository che comunica con Firebase
  final UserRepository _userRepository;

  // L'utente corrente (ci serve per avere il suo UID e i dati attuali)
  AppUser? currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  // Costruttore: riceve il repository (Dependency Injection come vuole il prof!)
  EditProfileViewModel({required UserRepository userRepository}) : _userRepository = userRepository;

  /// Metodo per salvare le modifiche del profilo
  Future<void> saveProfile(AppUser currentUser, String newName, String newSurname, String newBio, File? newProfileImage) async {
    
    _setLoading(true);
    _errorMessage = null;
    _isSuccess = false;

    try {
      // Chiamiamo il Repository passando i parametri esatti che si aspetta!
      await _userRepository.saveProfile(
        uid: currentUser.uid,       // Preso dall'utente attuale
        name: newName,              // Il nuovo nome digitato
        surname: newSurname,        // Il nuovo cognome digitato
        bio: newBio,                // La nuova bio digitata
        imageFile: newProfileImage, // L'immagine selezionata (può essere null se l'utente non l'ha cambiata)
      );

      _isSuccess = true;

    } catch (e) {
      _errorMessage = "Errore durante il salvataggio: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}