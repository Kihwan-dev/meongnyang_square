class FeedParams {
  FeedParams({
    this.id,
    required this.tag,
    required this.content,
    required this.imagePath,
  });

  final String? id;
  final String tag;
  final String content;
  final String imagePath;
}
