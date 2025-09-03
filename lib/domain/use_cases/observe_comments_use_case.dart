import 'package:meongnyang_square/domain/entities/comment.dart';
import 'package:meongnyang_square/domain/repositories/comment_repository.dart';

class ObserveCommentsUseCase {
  ObserveCommentsUseCase(this._repo);
  final CommentRepository _repo;

  Stream<List<Comment>> execute(String postId) {
    return _repo.observeComments(postId);
  }
}
