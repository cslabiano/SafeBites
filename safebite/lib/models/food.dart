class Food {
  final int id;
  final String name;
  final String? sourceLink;

  Food({
    required this.id,
    required this.name,
    required this.sourceLink,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      sourceLink: map['source_link'],
    );
  }
}
