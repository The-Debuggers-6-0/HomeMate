class StickyNote {
  final String id;
  final String content;
  final String authorUid;
  final DateTime createdAt;

  StickyNote({
    required this.id,
    required this.content,
    required this.authorUid,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'authorUid': authorUid,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StickyNote.fromMap(Map<String, dynamic> map) => StickyNote(
        id: map['id'] ?? '',
        content: map['content'] ?? '',
        authorUid: map['authorUid'] ?? '',
        createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      );
}
