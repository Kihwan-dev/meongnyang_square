import 'package:meongnyang_square/domain/repositories/feed_repository.dart';

class DeleteFeedUseCase {
  DeleteFeedUseCase(this._feedRepository);
  final FeedRepository _feedRepository;
  Future<void> execute(String id) async {
    return await _feedRepository.deleteFeed(id);
  }
}
