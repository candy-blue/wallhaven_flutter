class Tag {
  final int id;
  final String name;
  final String alias;
  final int categoryId;
  final String category;
  final String purity;
  final String createdAt;

  Tag({
    required this.id,
    required this.name,
    required this.alias,
    required this.categoryId,
    required this.category,
    required this.purity,
    required this.createdAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      alias: json['alias'] ?? '',
      categoryId: json['category_id'] ?? 0,
      category: json['category'] ?? '',
      purity: json['purity'] ?? 'sfw',
      createdAt: json['created_at'] ?? '',
    );
  }
}
