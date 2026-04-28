enum FarmingCategory { crops, seasons, methods }

class FarmingPost {
  final String id;
  final String title;
  final String description;
  final FarmingCategory category;
  final String? imageUrl;

  FarmingPost({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'imageUrl': imageUrl,
    };
  }

  factory FarmingPost.fromMap(Map<String, dynamic> map) {
    return FarmingPost(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: FarmingCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => FarmingCategory.crops,
      ),
      imageUrl: map['imageUrl'],
    );
  }
}
