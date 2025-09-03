class Comment {
  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.text,
    required this.createdAt,
    required this.clientAt,
  });

  final String id;
  final String postId;
  final String authorId;
  final String text;
  final DateTime? createdAt; // server time
  final DateTime? clientAt; // local fallback
}
