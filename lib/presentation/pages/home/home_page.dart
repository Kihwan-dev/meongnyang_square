import 'package:flutter/material.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_page.dart';
import 'package:meongnyang_square/presentation/pages/home/home_view_model.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel;

  // 현재 ViewModel의 피드 리스트가 FeedDto이든 Feed이든, Feed 리스트로 변환
  List<Feed>? _convertToFeedList(dynamic source) {
    if (source == null) return null;
    if (source is List<Feed>) return source;
    if (source is List) {
      return source.map<Feed>((item) {
        if (item is Feed) return item;
        final dynamic d = item; // FeedDto와 유사한 구조를 가정
        final String id = (d.id ?? '').toString();
        final dynamic rawCreatedAt = d.createdAt;
        DateTime createdAt;
        if (rawCreatedAt is DateTime) {
          createdAt = rawCreatedAt;
        } else if (rawCreatedAt is int) {
          // 밀리초 타임스탬프 가정
          createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
        } else {
          createdAt = DateTime.fromMillisecondsSinceEpoch(0);
        }
        final String tag = (d.tag ?? '').toString();
        final String content = (d.content ?? '').toString();
        final String imagePath = (d.imagePath ?? '').toString();
        return Feed(
          id: id,
          createdAt: createdAt,
          tag: tag,
          content: content,
          imagePath: imagePath,
        );
      }).toList();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(oldestFirst: true, limit: 30);
    _viewModel.start();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _viewModel, 
        builder: (context, _) {
          return FeedPage(
            feeds: _convertToFeedList(_viewModel.feeds),
            onEndReached: _viewModel.loadMore,
            isLoadingMore: _viewModel.isLoadingMore,
            hasMore: _viewModel.hasMore,
            onRefresh: _viewModel.refresh,
          );
        },
      ),
    );
  }
}
