import 'package:cloud_firestore/cloud_firestore.dart';

class FeedDto {
  final String? id;
  final DateTime? createdAt;
  final String? tag;
  final String? content;
  final String? imagePath;

  FeedDto({
    this.id,
    this.createdAt,
    this.tag,
    this.content,
    this.imagePath,
  });

  factory FeedDto.fromJson(Map<String, dynamic> map) {
    return FeedDto(
      id: map["id"] as String?,
      createdAt: (map["createdAt"] as Timestamp?)?.toDate(),
      tag: map["tag"] as String?,
      content: map["content"] as String?,
      imagePath: map["imagePath"] as String?,
    );
  }

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
