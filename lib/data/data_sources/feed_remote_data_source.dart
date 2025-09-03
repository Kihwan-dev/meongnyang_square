import 'package:meongnyang_square/data/dtos/feed_dto.dart';

/// 원격 저장소(Firestore/Storage) 접근을 담당하는 DataSource 인터페이스
abstract interface class FeedRemoteDataSource {
  /// 피드를 생성하거나 업데이트한다. 성공 시 true 반환.
  Future<bool> upsertFeed(FeedDto feedDto);

  Future<bool> deleteFeed(String id);

  /// 실시간 피드 스트림. 오래된 순/최신 순과 개수 조절 가능.
  Stream<List<Map<String, dynamic>>> watchFeeds({
    int limit = 30,
    bool oldestFirst = true,
  });
}
