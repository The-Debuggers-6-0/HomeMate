class HouseEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final String creatorUid;
  final String? notes;

  HouseEvent({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    required this.creatorUid,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'start': start.toIso8601String(),
        'end': end?.toIso8601String(),
        'creatorUid': creatorUid,
        'notes': notes,
      };

  factory HouseEvent.fromMap(Map<String, dynamic> map) => HouseEvent(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        start: DateTime.parse(map['start'] ?? DateTime.now().toIso8601String()),
        end: map['end'] != null ? DateTime.parse(map['end']) : null,
        creatorUid: map['creatorUid'] ?? '',
        notes: map['notes'],
      );
}
