import 'package:flutter/material.dart';

/// Classe centralizzata per la gestione della navigazione dell'app.
///
/// Fornisce metodi statici per navigare tra le schermate,
/// mantenendo la logica di routing separata dai widget.
class AppRouter {
  AppRouter._();

  /// Naviga verso una nuova schermata con push.
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Naviga verso una nuova schermata sostituendo quella corrente.
  static Future<T?> pushReplacement<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, dynamic>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Naviga verso una nuova schermata rimuovendo tutte le precedenti.
  static Future<T?> pushAndRemoveAll<T>(BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  /// Torna alla schermata precedente.
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
