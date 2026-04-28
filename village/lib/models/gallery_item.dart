class GalleryImage {
  final String id;
  final String imageUrl;
  final String title;
  final String category;
  final String description;
  final List<String> images;

  const GalleryImage({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    this.description = "",
    this.images = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'category': category,
      'description': description,
      'images': images,
    };
  }

  factory GalleryImage.fromMap(Map<String, dynamic> map) {
    return GalleryImage(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
    );
  }
}
