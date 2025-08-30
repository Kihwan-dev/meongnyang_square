import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/data/data_sources/feed_remote_data_source.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final firestore = FirebaseFirestore.instance;
  @override
  Future<bool> upsertFeed({
    required FeedDto dto,
    String? id,
  }) async {
    try {
      final collection = firestore.collection("feeds");
      final doc = id == null ? collection.doc() : collection.doc(id);
      await doc.set({
        "id": doc.id,
        "createdAt": DateTime.now().toIso8601String(),
        "tag": dto.tag ?? "",
        "content": dto.content ?? "",
        "imagePath": dto.imagePath ?? "",
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
