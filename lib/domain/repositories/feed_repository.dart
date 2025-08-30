import 'package:meongnyang_square/domain/entities/feed.dart';

abstract interface class FeedRepository {
  Future<Feed> upsertFeed();
}
