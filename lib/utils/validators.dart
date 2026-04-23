/// Classe di utilità per la validazione dei campi dei form.
class Validators {
  Validators._();

  /// Verifica che nessun campo sia vuoto.
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName è obbligatorio.';
    }
    return null;
  }

  /// Verifica che la password abbia almeno [minLength] caratteri.
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.trim().isEmpty) {
      return 'La password è obbligatoria.';
    }
    if (value.trim().length < minLength) {
      return 'La password deve avere almeno $minLength caratteri.';
    }
    return null;
  }

  /// Verifica che le due password corrispondano.
  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (password != confirmPassword) {
      return 'Le password non coincidono.';
    }
    return null;
  }

  /// Verifica il formato dell'email.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email è obbligatoria.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Formato email non valido.';
    }
    return null;
  }
}
