import 'package:meongnyang_square/domain/entities/comment.dart';

abstract interface class CommentRepository {
  Stream<List<Comment>> observeComments(String postId); // 최신순
  Future<void> addComment({
    required String postId,
    required String authorId,
    required String text,
  });
}
