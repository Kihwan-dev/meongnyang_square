import 'package:meongnyang_square/domain/repositories/comment_repository.dart';

class AddCommentUseCase {
  AddCommentUseCase(this._repo);
  final CommentRepository _repo;

  Future<void> execute({
    required String postId,
    required String authorId,
    required String text,
  }) {
    return _repo.addComment(
      postId: postId,
      authorId: authorId,
      text: text.trim(),
    );
  }
}
