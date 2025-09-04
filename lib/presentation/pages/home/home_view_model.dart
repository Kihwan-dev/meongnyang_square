import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/presentation/providers.dart';

class HomeState {
  final List<Feed> feeds;
  final DocumentSnapshot? lastDoc;

  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;

  HomeState({
    required this.feeds,
    this.lastDoc,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  HomeState copyWith({
    List<Feed>? feeds,
    DocumentSnapshot? lastDoc,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return HomeState(
      feeds: feeds ?? this.feeds,
      lastDoc: lastDoc ?? this.lastDoc,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState(feeds: []);
  }

  Future<void> fetchFeeds() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);
    try {
      final (feeds, lastDoc) = await ref.read(fetchFeedsUseCaseProvider).execute();
      final hasMore = lastDoc != null && feeds.isNotEmpty;
      state = state.copyWith(feeds: feeds, lastDoc: lastDoc, hasMore: hasMore, isLoading: false);
    } catch (e) {
      print(e);
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoadingMore || !state.hasMore || state.lastDoc == null) return;
    print("more load");
    state = state.copyWith(isLoadingMore: true);
    try {
      final (moreFeeds, newLastDoc) = await ref.read(fetchFeedsUseCaseProvider).execute(lastDoc: state.lastDoc);

      // 더 받을 게 있는지 추정: 새 lastDoc 있고, 받아온 리스트가 비어있지 않으면 true
      final hasMore = newLastDoc != null && moreFeeds.isNotEmpty;

      state = state.copyWith(
        feeds: [...state.feeds, ...moreFeeds],
        lastDoc: newLastDoc,
        hasMore: hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      print(e);
      state = state.copyWith(isLoadingMore: false);
    }
  }
}
