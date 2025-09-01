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

  // 예시 페이지를 5개 단위로 추가하기 위한 상태
  static const int exampleBatchSize = 5; // 한 번에 붙일 예시 개수
  int exampleBatchCount = 1;             // 현재 예시 배치 수 (기본 5개)
  bool isAppendingExamples = false;      // 예시 추가 중 중복 트리거 방지
  bool readyToAppendExamples = false; // 바닥에 닿은 뒤 손을 뗄 때 5개 추가
  bool recentlyAppendedExamples = false; // 한 번의 끌어당김 동작당 1회만 추가

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
    // 새 글이 추가되면 최신(맨 위)으로 이동
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

    // 더 불러올 수 있는 상태로 전환되면 예시 배치를 초기화
    if (widget.hasMore) {
      exampleBatchCount = 1;
    }
  }

  Future<void> onPageSwipe(int page) async {
    if (page == 1) return;
    if (isSwiping) return;
    isSwiping = true;

    if (page == 0) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => WritePage()),
      );
    } else if (page == 2) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CommentPage()),
      );
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
                  title: (feed.tag != null && feed.tag!.trim().isNotEmpty)
                      ? '#${feed.tag!.trim()}'
                      : null,
                  content: feed.content ?? '',
                ),
                const SizedBox(height: 16),
                const FeedBottom(),
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
            children: [FeedTop(), SizedBox(height: 16), FeedCenter(), SizedBox(height: 16), FeedBottom()],
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
    final List<FeedDto> items = widget.feeds ?? const <FeedDto>[];
    final bool hasRealItems = items.isNotEmpty;
    final int exampleTail = widget.hasMore ? 0 : exampleBatchCount * exampleBatchSize; // 더 없음 → 예시 꼬리(배치)
    final int itemCount = hasRealItems ? (items.length + exampleTail) : (exampleBatchCount * exampleBatchSize);

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
          if (notification is ScrollUpdateNotification) {
            final ScrollMetrics metrics = notification.metrics;
            const double endThreshold = 36.0; // 페이징 로드 트리거 임계값
            final bool isNearEnd = metrics.pixels >= metrics.maxScrollExtent - endThreshold;

            // 1) 페이징: 끝 근접 시 더 불러올 데이터가 있으면 loadMore 호출
            if (isNearEnd && items.isNotEmpty) {
              if (widget.hasMore && !_isRequestingMore && !_isScrollLoadingTriggered) {
                _isScrollLoadingTriggered = true;
                _isRequestingMore = true;
                widget.onEndReached?.call().whenComplete(() {
                  _isRequestingMore = false;
                  _isScrollLoadingTriggered = false;
                });
              }
            }

            // 2) 예시 추가 arm: 실제로 끝을 넘겨서 끌어당긴 거리(overPull)가 충분할 때만 준비 플래그 on
            if (!widget.hasMore) {
              final double overPull = metrics.pixels - metrics.maxScrollExtent; // 0보다 크면 바닥 넘김
              const double pullThreshold = 12.0; // 이 거리 이상 당겨야 arm
              if (overPull > pullThreshold && !recentlyAppendedExamples) {
                readyToAppendExamples = true; // 손을 떼면 추가
              }
            }
          }

          // 3) 스크롤이 끝났을 때: arm 되어 있고 hasMore == false 이면 5개만 1회 추가
          if (notification is ScrollEndNotification) {
            if (readyToAppendExamples && !widget.hasMore && !isAppendingExamples && !recentlyAppendedExamples) {
              isAppendingExamples = true;
              recentlyAppendedExamples = true; // 같은 제스처에서 중복 방지
              setState(() {
                exampleBatchCount += 1; // 예시 5개 추가
              });
              readyToAppendExamples = false; // 소비
              WidgetsBinding.instance.addPostFrameCallback((_) {
                isAppendingExamples = false;
              });
              // 약간의 쿨다운 후 다시 허용
              Future.delayed(const Duration(milliseconds: 250), () {
                recentlyAppendedExamples = false;
              });
            }
            _isScrollLoadingTriggered = false; // 로드 트리거 리셋
          }

          return false; // 버블링 허용
        },
        child: PageView.builder(
          controller: verticalController,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (items.isEmpty) {
              // 실데이터가 없으면 예시를 5개부터 시작하고, 바닥 당길 때마다 5개씩 추가
              return _buildExample();
            }

            // 실데이터 뒤쪽은 (hasMore==false) 일 때만 예시로 채움
            if (!widget.hasMore && index >= items.length) {
              return _buildExample();
            }

            final bool isLastReal = index == items.length - 1;
            return Stack(
              children: [
                _buildPost(items[index]),
                // 로딩 중일 때만 스피너 노출
                if (isLastReal) _buildBottomOverlay(),
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
