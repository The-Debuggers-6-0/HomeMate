import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Converte un campo data da/verso Firestore in modo robusto.
///
/// In lettura accetta sia una stringa ISO 8601 (il formato con cui salviamo)
/// sia un [Timestamp] nativo di Firestore (es. quando si usa
/// FieldValue.serverTimestamp()). In scrittura serializza sempre come stringa
/// ISO 8601, per coerenza. Se il valore manca, ripiega su DateTime.now().
class DateTimeConverter implements JsonConverter<DateTime, Object?> {
  const DateTimeConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is String && json.isNotEmpty) {
      return DateTime.tryParse(json) ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  Object? toJson(DateTime date) => date.toIso8601String();
}

/// Variante per le date opzionali (nullable).
///
/// Stessa logica di [DateTimeConverter] ma restituisce null quando il valore
/// è assente, invece di ripiegare su DateTime.now().
class NullableDateTimeConverter implements JsonConverter<DateTime?, Object?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is DateTime) return json;
    if (json is String && json.isNotEmpty) return DateTime.tryParse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? date) => date?.toIso8601String();
}
