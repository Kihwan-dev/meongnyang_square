import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/domain/use_cases/feed_params.dart';

abstract interface class FeedRepository {
  Future<void> upsertFeed(FeedParams feedParams);
  Future<void> deleteFeed(String id);
  Future<(List<Feed>, DocumentSnapshot?)> fetchFeeds({
    int limit,
    DocumentSnapshot? lastDoc,
  });
}
