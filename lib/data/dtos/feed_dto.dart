import 'package:cloud_firestore/cloud_firestore.dart';

class FeedDto {
  final String? id;
  final DateTime? createdAt;
  final String? tag;
  final String? content;
  final String? imagePath;
  final String? authorId;

  FeedDto({
    this.id,
    this.createdAt,
    this.tag,
    this.content,
    this.imagePath,
    this.authorId,
  });

  factory FeedDto.fromJson(Map<String, dynamic> map) {
    return FeedDto(
      id: map["id"],
      createdAt: map["createdAt"] == null ? DateTime.parse(map["createdAt"]) : DateTime.now(),
      tag: map["tag"],
      content: map["content"],
      imagePath: map["imagePath"],
      authorId: map["authorId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt?.toIso8601String(),
      "tag": tag,
      "content": content,
      "imagePath": imagePath,
      "authorId": authorId,
    };
  }
}
