class Announcement {
  final String title;
  final String date;
  final String content;
  final bool isImportant;

  const Announcement({
    required this.title,
    required this.date,
    required this.content,
    this.isImportant = false,
  });
}
