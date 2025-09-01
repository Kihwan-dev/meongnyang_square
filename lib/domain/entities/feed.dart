class Feed {
  Feed({
    required this.id,
    required this.createdAt,
    required this.tag,
    required this.content,
    required this.imagePath,
  });

  final String id;
  final DateTime createdAt;
  final String tag;
  final String content;
  final String imagePath;
}
