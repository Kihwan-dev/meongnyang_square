import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import 'package:meongnyang_square/data/data_sources/feed_remote_data_source.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FeedRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<bool> upsertFeed(FeedDto dto) async {
    try {
      final collection = _firestore.collection("feeds");
      final doc = dto.id == null || dto.id!.isEmpty
          ? collection.doc()
          : collection.doc(dto.id);

      String? imagePath = dto.imagePath;

      // 로컬 경로일 경우 Storage 업로드 후 downloadURL로 치환
      if (imagePath != null && imagePath.isNotEmpty && !imagePath.startsWith("http")) {
        final file = imagePath.startsWith("file://")
            ? File(Uri.parse(imagePath).path)
            : File(imagePath);

        if (await file.exists()) {
          final fileName =
              '${doc.id}_${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
          final ref = _storage.ref().child('feeds/$fileName');
          await ref.putFile(file);
          imagePath = await ref.getDownloadURL();
        } else {
          imagePath = null;
        }
      }

      final payload = <String, dynamic>{
        "id": doc.id,
        "tag": (dto.tag ?? '').trim(),
        "content": (dto.content ?? '').trim(),
        "createdAt": FieldValue.serverTimestamp(),
      };
      if (imagePath != null && imagePath.isNotEmpty) {
        payload["imagePath"] = imagePath;
      }

      await doc.set(payload, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('[FeedRemoteDataSourceImpl] upsertFeed ERROR: $e');
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
