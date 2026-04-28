enum EventType { education, cleaning, farming, communal, other }

class VillageEvent {
  final String id;
  final String title;
  final String date;
  final String description;
  final String imageUrl;
  final EventType type;
  final List<String> additionalImages;

  const VillageEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.imageUrl,
    this.type = EventType.other,
    this.additionalImages = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'additionalImages': additionalImages,
    };
  }

  factory VillageEvent.fromMap(Map<String, dynamic> map) {
    return VillageEvent(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: EventType.values.byName(map['type'] ?? 'other'),
      additionalImages: List<String>.from(map['additionalImages'] ?? []),
    );
  }

  static String getAutoImage(String imageUrl, EventType type) {
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) return imageUrl;
    
    switch (type) {
      case EventType.education:
        return 'assets/images/master_education.png';
      case EventType.cleaning:
        return 'assets/images/master_cleaning.png';
      case EventType.farming:
        return 'assets/images/master_farming.png';
      case EventType.communal:
        return 'https://images.unsplash.com/photo-1523580494863-6f3031224c94';
      case EventType.other:
      default:
        return 'https://images.unsplash.com/photo-1542332213-9b5a5a3fab35';
    }
  }
}
