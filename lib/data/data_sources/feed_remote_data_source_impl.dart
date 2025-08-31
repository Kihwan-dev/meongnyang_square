import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/data/data_sources/feed_remote_data_source.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> upsertFeed(FeedDto dto) async {
    try {
      final collection = _firestore.collection("feeds");
      final doc = dto.id == null ? collection.doc() : collection.doc(dto.id);
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

  @override
  Stream<List<Map<String, dynamic>>> watchFeeds({int limit = 30, bool oldestFirst = true}) {
    return _firestore
        .collection('feeds')
        .orderBy('createdAt', descending: !oldestFirst)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'createdAt': data['createdAt'],
                'tag': data['tag'],
                'content': data['content'],
                'imagePath': data['imagePath'],
              };
            }).toList());
  }
}
