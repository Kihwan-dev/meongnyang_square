import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/data/data_sources/comment_remote_data_source.dart';

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final FirebaseFirestore _firestore;
  CommentRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _col(String postId) =>
      _firestore.collection('feeds').doc(postId).collection('comments');

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> observe(String postId) {
    return _col(postId).orderBy('createdAt', descending: true).snapshots();
  }

  @override
  Future<void> add({
    required String postId,
    required String authorId,
    required String text,
  }) async {
    await _col(postId).add({
      'text': text,
      'authorId': authorId,
      'createdAt': FieldValue.serverTimestamp(),
      'clientAt': DateTime.now(),
    });
  }
}
