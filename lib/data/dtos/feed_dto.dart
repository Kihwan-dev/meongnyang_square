class FeedDto {
  FeedDto({
    required this.id,
    required this.createdAt,
    required this.tag,
    required this.content,
    required this.imagePath,
  });

  final String? id;
  final DateTime? createdAt;
  final String? tag;
  final String? content;
  final String? imagePath;

  FeedDto.fromJson(Map<String, dynamic> map)
      : this(
          id: map["id"] ?? "",
          createdAt: DateTime.parse(map["createdAt"] ?? ""),
          tag: map["tag"] ?? "",
          content: map["content"] ?? "",
          imagePath: map["imagePath"] ?? "",
        );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt?.toIso8601String(),
      "tag": tag,
      "content": content,
      "imagePath": imagePath,
    };
  }
}
