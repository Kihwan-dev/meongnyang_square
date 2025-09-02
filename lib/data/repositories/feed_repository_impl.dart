import 'dart:typed_data';

import 'package:meongnyang_square/data/data_sources/feed_remote_data_source.dart';
import 'package:meongnyang_square/data/data_sources/storage_data_source.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';
import 'package:meongnyang_square/domain/repositories/feed_repository.dart';
import 'package:meongnyang_square/domain/use_cases/feed_params.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._feedRemoteDataSource);
  final FeedRemoteDataSource _feedRemoteDataSource;

  @override
  Future<void> upsertFeed(FeedParams feedParams) async {
    final feedDto = FeedDto(
      id: feedParams.id,
      createdAt: null,
      tag: feedParams.tag,
      content: feedParams.content,
      imagePath: feedParams.imagePath,
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
}
