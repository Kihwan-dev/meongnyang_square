import 'package:meongnyang_square/data/dtos/feed_dto.dart';

abstract interface class FeedRemoteDataSource {
  Future<bool> upsertFeed({
    required FeedDto dto,
    String? id,
  });
}
