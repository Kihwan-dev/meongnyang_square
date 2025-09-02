import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';
import 'package:meongnyang_square/presentation/pages/comment/comment_page.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_bottom.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_center.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_top.dart';
import 'package:meongnyang_square/presentation/pages/write/write_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    this.feeds,
    this.onEndReached,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.onRefresh,
  });

  final List<FeedDto>? feeds; // ViewModel/부모에서 전달
  final Future<void> Function()? onEndReached; // 끝에 닿으면 추가 로드 요청
  final bool isLoadingMore; // 하단 로딩 표시 제어
  final bool hasMore; // 더 불러올 데이터가 있는지
  final Future<void> Function()? onRefresh; // 당겨서 새로고침

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late PageController feedController; // 좌/우(쓰기/코멘트) 이동
  late PageController verticalController = PageController(); // 세로 스크롤 피드 이동
  bool isSwiping = false;
  bool _isRequestingMore = false; // onEndReached 가드
  bool _isScrollLoadingTriggered = false; // ScrollNotification 기반 무한스크롤 중복 방지
  int _lastItemsCount = 0; // 직전 피드 개수 기록 (예시→실데이터 전환용)

  @override
  void initState() {
    super.initState();
    feedController = PageController(initialPage: 1);
    _lastItemsCount = widget.feeds?.length ?? 0;
  }

  @override
  void dispose() {
    feedController.dispose();
    verticalController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newCount = widget.feeds?.length ?? 0;
    // 새 글이 추가되면 항상 최신(맨 위)으로 이동
    if (newCount > _lastItemsCount) {
      if (verticalController.hasClients) {
        verticalController.animateToPage(
          0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    }
    _lastItemsCount = newCount;
  }

  Future<void> onPageSwipe(int page) async {
    if (page == 1) return;
    if (isSwiping) return;
    isSwiping = true;

    if (page == 0) {
      // await Navigator.of(context).push(
      //   MaterialPageRoute(builder: (context) => WritePage()),
      // );
    } else if (page == 2) {
      final items = widget.feeds ?? const <FeedDto>[];
      if (items.isNotEmpty) {
        final idx = verticalController.hasClients ? (verticalController.page?.round() ?? 0) : 0;
        final safeIdx = idx.clamp(0, items.length - 1);
        final feed = items[safeIdx];
        final id = feed.id;
        if (id != null && id.isNotEmpty) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CommentPage(postId: id)),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이 피드의 ID가 없어 댓글 페이지를 열 수 없어요.')),
            );
          }
        }
      } else {
        // 피드가 없을 때는 그냥 무시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('불러온 피드가 없습니다.')),
          );
        }
      }
    }

    if (mounted) {
      feedController.animateToPage(
        1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    isSwiping = false;
  }

  // 공통 배경 생성기
  Widget _buildBackground(String? path) {
    const fallback = AssetImage('assets/images/sample01.png');
    if (path == null || path.isEmpty) {
      return const Image(image: fallback, fit: BoxFit.cover);
    }
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Image(image: fallback, fit: BoxFit.cover),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    final file = File(path.startsWith('file://') ? Uri.parse(path).path : path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Image(image: fallback, fit: BoxFit.cover),
      );
    }
    return const Image(image: fallback, fit: BoxFit.cover);
  }

  // 단일 포스트 빌더
  Widget _buildPost(FeedDto feed) {
    final background = _buildBackground(feed.imagePath);
    return Stack(
      children: [
        Positioned.fill(child: background),
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.30))),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                FeedTop(createdAt: feed.createdAt),
                const SizedBox(height: 16),
                FeedCenter(
                  title: (feed.tag != null && feed.tag!.trim().isNotEmpty) ? '#${feed.tag!.trim()}' : null,
                  content: feed.content ?? '',
                ),
                SizedBox(height: 16),
                FeedBottom(postId: feed.id),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 예시 화면 (데이터가 하나도 없을 때만 사용)
  Widget _buildExample() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/sample01.png'),
          fit: BoxFit.cover,
          opacity: 0.60,
        ),
      ),
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              FeedTop(),
              SizedBox(height: 16),
              FeedCenter(),
              SizedBox(height: 16),
              FeedBottom(postId: null),
            ],
          ),
        ),
      ),
    );
  }

  // 마지막 카드 하단 오버레이 (로딩/마지막)
  Widget _buildBottomOverlay() {
    if (widget.isLoadingMore) {
      return const Positioned(
        bottom: 20,
        left: 0,
        right: 0,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCenterPage() {
    final items = widget.feeds ?? const <FeedDto>[];
    // 더 불러올 데이터가 없으면(example를 반복) 큰 tail 길이로 무한 스크롤 흉내
    final infiniteTail = widget.hasMore ? 0 : 1000; // 예시를 사실상 무한 반복
    final baseCount = items.isEmpty ? 1 : items.length; // 0개여도 제스처 일관성 유지
    final itemCount = baseCount + infiniteTail;

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          await widget.onRefresh!.call();
        }
        if (mounted) {
          verticalController.jumpToPage(0);
        }
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // 스크롤 진행 중에 끝에 근접하면 추가 로드 (threshold 48px)
          if (notification is ScrollUpdateNotification) {
            final m = notification.metrics;
            const threshold = 48.0;
            final isAtEnd = m.pixels >= m.maxScrollExtent - threshold;
            if (isAtEnd && widget.hasMore && !_isRequestingMore && !_isScrollLoadingTriggered && items.isNotEmpty) {
              _isScrollLoadingTriggered = true;
              _isRequestingMore = true;
              widget.onEndReached?.call().whenComplete(() {
                _isRequestingMore = false;
                _isScrollLoadingTriggered = false;
              });
            }
          }
          // 스크롤이 끝나면 트리거 리셋 (안정성)
          if (notification is ScrollEndNotification) {
            _isScrollLoadingTriggered = false;
          }
          return false; // 버블링 허용
        },
        child: PageView.builder(
          controller: verticalController,
          scrollDirection: Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (items.isEmpty) {
              // 데이터가 전혀 없으면 예시 1장만 반복
              return _buildExample();
            }

            // 더 이상 데이터가 없을 때는 마지막 이후 인덱스부터 계속 예시 화면을 보여줌
            if (!widget.hasMore && index >= items.length) {
              return _buildExample();
            }

            final isLast = index == items.length - 1;
            return Stack(
              children: [
                _buildPost(items[index]),
                // 오버레이는 더 불러오기 있을 때만 표시 (hasMore == true)
                if (isLast && widget.hasMore) _buildBottomOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.horizontal,
      controller: feedController,
      onPageChanged: onPageSwipe,
      children: [
        const Text('Write 페이지로 이동'),
        _buildCenterPage(),
        const Text('Comment 페이지로 이동'),
      ],
    );
  }
}
