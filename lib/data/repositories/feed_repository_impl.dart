import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/data/data_sources/feed_remote_data_source.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/domain/repositories/feed_repository.dart';
import 'package:meongnyang_square/domain/use_cases/feed_params.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._feedRemoteDataSource);
  final FeedRemoteDataSource _feedRemoteDataSource;

  @override
  Future<void> upsertFeed(FeedParams feedParams) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("로그인된 사용자가 없습니다.");
    }

    final feedDto = FeedDto(
      id: feedParams.id,
      createdAt: null,
      tag: feedParams.tag,
      content: feedParams.content,
      imagePath: feedParams.imagePath,
      authorId: currentUser.uid,
    );

    final result = await _feedRemoteDataSource.upsertFeed(feedDto);
    if (!result) {
      throw Exception("Firebase에 피드 저장 실패");
    }
  }

  @override
  Future<void> deleteFeed(String id) async {
    final result = await _feedRemoteDataSource.deleteFeed(id);
    if (!result) {
      throw Exception("Feed 저장 실패");
    }
  }

  @override
  Future<(List<Feed>, DocumentSnapshot?)> fetchFeeds({
    int limit = 10,
    DocumentSnapshot? lastDoc,
  }) async {
    final (dtos, lastDocOut) = await _feedRemoteDataSource.fetchFeeds(limit: limit, lastDoc: lastDoc);
    final entities = dtos
        .map(
          (e) => Feed(
            authorId: e.authorId ?? "",
            content: e.content ?? "",
            createdAt: e.createdAt ?? DateTime.now(),
            id: e.id ?? "",
            imagePath: e.imagePath ?? "",
            tag: e.tag ?? "",
          ),
        )
        .toList();
    return (entities, lastDocOut);
  }
}
