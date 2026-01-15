class Collection {
  final int id;
  final String label;
  final int views;
  final int public;
  final int count;

  Collection({
    required this.id,
    required this.label,
    required this.views,
    required this.public,
    required this.count,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] ?? 0,
      label: json['label'] ?? 'Unknown',
      views: json['views'] ?? 0,
      public: json['public'] ?? 0,
      count: json['count'] ?? 0,
    );
  }
}
