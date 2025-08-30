import 'package:meongnyang_square/domain/repositories/feed_repository.dart';
import 'package:meongnyang_square/domain/use_cases/feed_params.dart';

class UpsertFeedUseCase {
  UpsertFeedUseCase(this._feedRepository);
  final FeedRepository _feedRepository;
  Future<void> execute(FeedParams feedParams) async {
    return await _feedRepository.upsertFeed(feedParams);
  }
}
