import 'package:meongnyang_square/domain/use_cases/feed_params.dart';

abstract interface class FeedRepository {
  Future<void> upsertFeed(FeedParams feedParams);
}
