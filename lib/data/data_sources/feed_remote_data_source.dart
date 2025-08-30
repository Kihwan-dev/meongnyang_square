import 'package:meongnyang_square/data/dtos/feed_dto.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';

abstract interface class FeedRemoteDataSource {
  Future<bool> upsertFeed(FeedDto dto);
}
