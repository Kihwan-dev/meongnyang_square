class FeedParams {
  FeedParams({
    this.id,
    required this.tag,
    required this.content,
    required this.imagePath,
    required this.authorId,
  });

  final String? id;
  final String tag;
  final String content;
  final String imagePath;
  final String authorId;
}
