import 'package:flutter/material.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/presentation/pages/write/write_page.dart';
import 'package:meongnyang_square/presentation/pages/comment/comment_page.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Feed> items = [];

  Future<void> _goToWriteWithCurrentFeed() async {
    if (items.isEmpty) {
      // 피드가 없을 때: null 전달
      print('[FeedPage→WritePage] currentFeed(index=0): null');
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WritePage(),
          // 현재 페이지의 Feed 하나만 전달
          settings: const RouteSettings(
            arguments: {
              'feed': null,
            },
          ),
        ),
      );
    } else {
      // 인덱스 0번을 기본으로 사용
      final int currentIndex = 0;
      final Feed currentFeed = items[currentIndex];
      // 현재 페이지(여기서는 index=0)의 Feed를 로그로 출력
      print('[FeedPage→WritePage] currentFeed(index=$currentIndex): '
          'id=${currentFeed.id}, tag=${currentFeed.tag}, '
          'content=${currentFeed.content}, createdAt=${currentFeed.createdAt}, '
          'imagePath=${currentFeed.imagePath}, authorId=${currentFeed.authorId}');

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WritePage(),
          // 현재 페이지의 Feed 하나만 전달
          settings: RouteSettings(
            arguments: {
              'feed': currentFeed, // 현재 페이지의 단일 Feed만 전달
            },
          ),
        ),
      );
    }
  }

  // 카드별(개별 아이템)로 WritePage 이동
  Future<void> _goToWriteWithFeed(Feed feed) async {
    // 선택된 피드 정보를 로그로 출력
    print('[FeedPage→WritePage] currentFeed(index=?): '
        'id=${feed.id}, tag=${feed.tag}, '
        'content=${feed.content}, createdAt=${feed.createdAt}, '
        'imagePath=${feed.imagePath}, authorId=${feed.authorId}');

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WritePage(),
        // 현재 페이지의 Feed 하나만 전달
        settings: RouteSettings(
          arguments: {
            'feed': feed, // 탭한 카드의 Feed만 전달
          },
        ),
      ),
    );
  }

  Future<void> _goToCommentWithFeed(Feed feed) async {
    print('[FeedPage→CommentPage] feedId=${feed.id}, authId=${feed.authorId}');
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentPage(postId: feed.id),
        settings: RouteSettings(
          arguments: {
            'authId': feed.authorId,
            'feedId': feed.id,
          },
        ),
      ),
    );
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
    if (page == 0) {
      print('Page 0 swiped, going to write page');
      _goToWriteWithCurrentFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity;
          if (v == null) return;
          if (v < 0) {
            // 왼쪽 스와이프 → WritePage
            // ignore: avoid_print
            print('[FeedPage] left swipe to WritePage');
            _goToWriteWithCurrentFeed();
          } else if (v > 0) {
            // 오른쪽 스와이프 → CommentPage (현재 화면의 피드 하나 선택)
            if (items.isNotEmpty) {
              final Feed feed = items.first;
              // ignore: avoid_print
              print('[FeedPage] right swipe to CommentPage');
              _goToCommentWithFeed(feed);
            }
          }
        },
        child: ListView(
          children: items.map(_buildPost).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ignore: avoid_print
          print('[FeedBottom] write icon tapped');
          await _goToWriteWithCurrentFeed();
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}