class HouseRule {
  final String id;
  final String title;
  final String description;

  HouseRule({required this.id, required this.title, required this.description});

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
      };

  factory HouseRule.fromMap(Map<String, dynamic> map) => HouseRule(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
      );
}
