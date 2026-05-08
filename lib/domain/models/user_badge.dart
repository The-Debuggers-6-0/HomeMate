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

  // --- RINOMINATO DA fromMap A fromJson ---
  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      templateId: json['templateId'] ?? '',
      unlockedAt: json['unlockedAt'] != null 
          ? (json['unlockedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      month: json['month'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    };
  }
}