import 'package:flutter/material.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/presentation/pages/write/write_page.dart';
import 'package:meongnyang_square/presentation/pages/comment/comment_page.dart';

class OriginFeedViewModelPage extends StatefulWidget {
  @override
  _OriginFeedViewModelPageState createState() => _OriginFeedViewModelPageState();
}

class _OriginFeedViewModelPageState extends State<OriginFeedViewModelPage> {
  List<Feed> items = [];

  // 현재 화면에서 보이는(가장 가까운) 아이템 인덱스
  int _currentIndex = 0;
  // 스크롤 위치를 추적하기 위한 컨트롤러
  final ScrollController _scrollController = ScrollController();
  // 각 항목의 높이(고정) — 인덱스 계산을 단순하게 하기 위함
  static const double _itemExtent = 72.0;

  /// 상위에서 전달된 피드 리스트를 반환 (null 안전 처리)
  List<Feed> getFeedList() => items;

  /// WritePage로 이동 RouteSettings.arguments에 단일 Feed를 전달
  // Future<void> _openWritePage(Feed? feed) async {
  //   await Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => WritePage(),
  //       // 현재 페이지의 Feed 하나만 전달
  //       settings: RouteSettings(
  //         arguments: {
  //           'feed': feed,
  //         },
  //       ),
  //     ),
  //   );
  // }

  /// CommentPage로 이동 postId와 함께 authId, feedId를 arguments로 전달
  Future<void> _openCommentPage(Feed feed) async {
    final String? feedId = feed.id;
    final String? authorId = feed.authorId;
    if (feedId == null || feedId.isEmpty) return; // ID가 종료
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentPage(postId: feedId),
        settings: RouteSettings(
          arguments: {
            'authId': authorId,
            'feedId': feedId,
          },
        ),
      ),
    );
  }

  /// WritePage 이동 시 전달 예정인 값을 콘솔에 출력
  void _logWriteArguments(Feed? feed, int index) {
    if (feed == null) {
      print('[FeedViewModel→WritePage] feed=null, index=0');
      return;
    }
    print('[FeedViewModel→WritePage] currentFeed(index=$index): '
        'id=${feed.id}, tag=${feed.tag}, content=${feed.content}, '
        'createdAt=${feed.createdAt}, imagePath=${feed.imagePath}, authorId=${feed.authorId}');
  }

  /// CommentPage 이동 시 전달 예정인 값을 콘솔에 출력
  void _logCommentArguments(int index, Feed feed) {
    final String feedId = feed.id ?? '';
    final String authorId = feed.authorId ?? '';
    print('[FeedViewModel→CommentPage] index=$index, feedId=$feedId, authId=$authorId');
  }

  Future<void> _goToWriteWithCurrentFeed() async {
    // 1) 피드 리스트 확보
    final List<Feed> feedList = getFeedList();

    // 2) 비어 있으면 null 전달 후 종료
    if (feedList.isEmpty) {
      _logWriteArguments(null, 0);
      // await _openWritePage(null);
      return;
    }

    // 3) 현재 인덱스 계산(스크롤 위치 기반) 후 해당 피드 선택
    final int currentIndex = _currentIndex.clamp(0, feedList.length - 1);
    final Feed currentFeed = feedList[currentIndex];

    // 4) 디버그 로그 출력
    _logWriteArguments(currentFeed, currentIndex);

    // 5) 화면 전환
    // await _openWritePage(currentFeed);
  }

  // 카드별(개별 아이템)을 WritePage로 이동
  Future<void> _goToWriteWithFeed(Feed feed) async {
    // 선택된 피드 정보를 로그로 출력
    _logWriteArguments(feed, _currentIndex);
    // await _openWritePage(feed);
  }

  Future<void> _goToCommentWithFeed(Feed feed) async {
    _logCommentArguments(_currentIndex, feed);
    await _openCommentPage(feed);
  }

  Widget _buildPost(Feed feed) {
    return ListTile(
      title: Text(feed.content),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.comment),
            onPressed: () async {
              // ignore: avoid_print
              print('Comment pressed for feed id: ${feed.id}');
              await _goToCommentWithFeed(feed);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // ignore: avoid_print
              print('Write pressed for feed id: ${feed.id}');
              await _goToWriteWithFeed(feed);
            },
          ),
        ],
      ),
    );
  }

  void onPageSwipe(int page) {
    // page == 0: 왼쪽 스와이프 → WritePage 이동
    if (page == 0) {
      print('Page 0 swiped, going to write page');
      _goToWriteWithCurrentFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        // 수평 스와이프 제스처: 왼쪽=WritePage, 오른쪽=CommentPage
        onHorizontalDragEnd: (details) {
          final double? velocity = details.primaryVelocity;
          if (velocity == null) return;
          if (velocity < 0) {
            // 왼쪽 스와이프 → WritePage
            print('[FeedViewModel] left swipe to WritePage');
            _goToWriteWithCurrentFeed();
          } else if (velocity > 0) {
            // 오른쪽 스와이프 → CommentPage (현재 인덱스의 피드 사용)
            final List<Feed> feedList = getFeedList();
            if (feedList.isNotEmpty) {
              final int currentIndex = _currentIndex.clamp(0, feedList.length - 1);
              final Feed currentFeed = feedList[currentIndex];
              print('[FeedViewModel] right swipe to CommentPage');
              _goToCommentWithFeed(currentFeed);
            }
          }
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // 스크롤 위치 → 현재 항목 인덱스 추정 (고정 itemExtent 기준)
            final double pixels = notification.metrics.pixels;
            final int approximateIndex = (pixels / _itemExtent).round();
            final int clampedIndex = approximateIndex.clamp(0, (items.isEmpty ? 0 : items.length - 1));
            if (clampedIndex != _currentIndex) {
              setState(() {
                _currentIndex = clampedIndex;
              });
              print('[FeedViewModel] currentIndex → $_currentIndex');
            }
            return false; // 다른 리스너에게도 전달
          },
          child: ListView.builder(
            controller: _scrollController,
            itemExtent: _itemExtent,
            itemCount: items.length,
            itemBuilder: (context, index) => _buildPost(items[index]),
          ),
        ),
      ),
      // 플로팅 버튼: 현재 인덱스의 피드로 WritePage 이동
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('[FeedBottom] write icon tapped');
          await _goToWriteWithCurrentFeed();
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
