import 'package:cloud_firestore/cloud_firestore.dart';

class CleaningTask {
  final String id;
  final String title;
  final String assigneeUid;
  final DateTime weekStart; // settimana di riferimento
  final bool completed;
  final DateTime? completedAt;

  CleaningTask({
    required this.id,
    required this.title,
    required this.assigneeUid,
    required this.weekStart,
    this.completed = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'assigneeUid': assigneeUid,
        'weekStart': weekStart.toIso8601String(),
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  factory CleaningTask.fromMap(Map<String, dynamic> map) => CleaningTask(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        assigneeUid: map['assigneeUid'] ?? '',
        weekStart: DateTime.parse(map['weekStart'] ?? DateTime.now().toIso8601String()),
        completed: map['completed'] ?? false,
        completedAt: _readDate(map['completedAt']),
      );
}
