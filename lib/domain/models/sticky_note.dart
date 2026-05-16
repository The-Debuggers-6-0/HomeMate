class StickyNote {
  final String id;
  final String content;
  final String authorUid;
  final String authorName;
  final String authorPhotoUrl;
  final DateTime createdAt;

  StickyNote({
    required this.id,
    required this.content,
    required this.authorUid,
    this.authorName = '',
    this.authorPhotoUrl = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'content': content,
        'authorUid': authorUid,
      'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StickyNote.fromMap(Map<String, dynamic> map) => StickyNote(
        id: map['id'] ?? '',
        content: map['content'] ?? '',
        authorUid: map['authorUid'] ?? '',
      authorName: map['authorName'] ?? '',
        authorPhotoUrl: map['authorPhotoUrl'] ?? '',
        createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      );
}
