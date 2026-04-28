class Job {
  final String id;
  final String title;
  final String description;
  final String contact;
  final String? link;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.contact,
    this.link,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'contact': contact,
      'link': link,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      contact: map['contact'] ?? '',
      link: map['link'],
    );
  }
}
