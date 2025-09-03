

import 'package:flutter/foundation.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';

/// 피드 화면용 ViewModel: 현재 피드 인덱스와 목록을 관리하고
/// UI가 필요로 하는 형태(Feed, FeedDto)로 안전하게 제공한다.
class FeedViewModel extends ChangeNotifier {
  FeedViewModel({List<Feed>? initialFeeds, int initialIndex = 0})
      : _feeds = initialFeeds ?? <Feed>[],
        _currentIndex = initialIndex;

  List<Feed> _feeds;
  int _currentIndex;

  /// 전체 피드 목록 반환
  List<Feed> get feeds => _feeds;

  /// 현재 선택된 인덱스 반환
  int get currentIndex => _currentIndex;

  /// 피드가 하나 이상 있는지
  bool get hasFeeds => _feeds.isNotEmpty;

  /// 현재 선택된 피드 반환 (없을 수 있음)
  Feed? get currentFeed {
    if (_feeds.isEmpty) return null;
    final int safeIndex = _currentIndex.clamp(0, _feeds.length - 1);
    return _feeds[safeIndex];
  }

  /// 현재 선택된 피드를 WritePage에서 사용하기 좋은 FeedDto로 변환하여 반환
  FeedDto? get currentFeedAsDto {
    final Feed? source = currentFeed;
    if (source == null) return null;
    return FeedDto(
      id: source.id,
      createdAt: source.createdAt,
      tag: source.tag,
      content: source.content,
      imagePath: source.imagePath,
    );
  }

  /// 피드 목록을 교체
  void setFeeds(List<Feed> newFeeds) {
    _feeds = newFeeds;
    if (_feeds.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= _feeds.length) {
      _currentIndex = _feeds.length - 1;
    }
    notifyListeners();
  }

  /// 현재 선택된 인덱스를 변경
  void setCurrentIndex(int index) {
    if (_feeds.isEmpty) {
      _currentIndex = 0;
    } else {
      _currentIndex = index.clamp(0, _feeds.length - 1);
    }
    notifyListeners();
  }
}