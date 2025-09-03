import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/data/data_sources/comment_remote_data_source.dart';
import 'package:meongnyang_square/domain/entities/comment.dart';
import 'package:meongnyang_square/domain/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._remote);
  final CommentRemoteDataSource _remote;

  @override
  Stream<List<Comment>> observeComments(String postId) {
    return _remote.observe(postId).map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        DateTime? createdAt;
        final ts = data['createdAt'];
        if (ts is Timestamp) createdAt = ts.toDate();
        DateTime? clientAt;
        final ca = data['clientAt'];
        if (ca is Timestamp) clientAt = ca.toDate();
        if (ca is DateTime) clientAt = ca;

        return Comment(
          id: d.id,
          postId: postId,
          authorId: (data['authorId'] ?? '') as String,
          text: (data['text'] ?? '') as String,
          createdAt: createdAt,
          clientAt: clientAt,
        );
      }).toList();
    });
  }

  @override
  Future<void> addComment({
    required String postId,
    required String authorId,
    required String text,
  }) {
    return _remote.add(postId: postId, authorId: authorId, text: text);
  }
}
