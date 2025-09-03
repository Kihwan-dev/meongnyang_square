import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/domain/repositories/feed_repository.dart';

class FetchFeedsUseCase {
  FetchFeedsUseCase(this.repository);
  final FeedRepository repository;

  Future<(List<Feed>, DocumentSnapshot?)> execute({
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    return await repository.fetchFeeds(limit: limit, lastDoc: lastDoc);
  }
}
