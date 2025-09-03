import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class CommentRemoteDataSource {
  Stream<QuerySnapshot<Map<String, dynamic>>> observe(String postId);
  Future<void> add({
    required String postId,
    required String authorId,
    required String text,
  });
}
