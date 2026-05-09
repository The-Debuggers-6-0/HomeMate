import 'package:cloud_firestore/cloud_firestore.dart';

class UserBadge {
  final String templateId;
  final DateTime unlockedAt;
  final int? month;
  final int? year;

  UserBadge({
    required this.templateId,
    required this.unlockedAt,
    this.month,
    this.year,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    // --- IL TRUCCO: Gestione intelligente della data ---
    DateTime parsedDate = DateTime.now();
    
    if (json['unlockedAt'] != null) {
      final dynamic dateData = json['unlockedAt'];
      // Se Firebase ci manda una stringa di testo (il nostro caso!)
      if (dateData is String) {
        parsedDate = DateTime.tryParse(dateData) ?? DateTime.now();
      } 
      // Se Firebase ci manda un Timestamp nativo (per sicurezza)
      else if (dateData is Timestamp) {
        parsedDate = dateData.toDate();
      }
    }

    return UserBadge(
      templateId: json['templateId'] ?? '',
      unlockedAt: parsedDate,
      month: json['month'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'unlockedAt': unlockedAt.toIso8601String(), // Ora salviamo sempre come Stringa per coerenza
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    };
  }
}