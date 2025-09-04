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

  HomeState({
    required this.feeds,
    this.lastDoc,
  });

  HomeState copyWith({
    List<Feed>? feeds,
    DocumentSnapshot? lastDoc,
  }) {
    return HomeState(
      feeds: feeds ?? this.feeds,
      lastDoc: lastDoc ?? this.lastDoc,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState(feeds: []);
  }

  Future<void> fetchFeeds() async {
    final (feeds, lastDoc) = await ref.read(fetchFeedsUseCaseProvider).execute();
    state = state.copyWith(feeds: feeds, lastDoc: lastDoc);
  }

  Future<void> fetchMore() async {
    if (state.lastDoc == null) return;
    final (moreFeeds, newLastDoc) = await ref.read(fetchFeedsUseCaseProvider).execute(lastDoc: state.lastDoc);
    state = state.copyWith(
      feeds: [...state.feeds, ...moreFeeds],
      lastDoc: newLastDoc,
    );
  }
}
