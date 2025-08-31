import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meongnyang_square/data/dtos/feed_dto.dart';
import 'package:meongnyang_square/presentation/pages/comment/comment_page.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_bottom.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_center.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_top.dart';
import 'package:meongnyang_square/presentation/pages/write/write_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, this.feeds});
  final List<FeedDto>? feeds; // ViewModel/부모에서 전달 (정렬도 바깥에서)

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late PageController feedController;
  bool isSwiping = false;

  @override
  void initState() {
    super.initState();
    feedController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    feedController.dispose();
    super.dispose();
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
    // 네트워크 URL
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Image(image: fallback, fit: BoxFit.cover),
      );
    }
    // 에셋 경로
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }
    // 로컬 파일 (시뮬레이터 등)
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
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.3))),
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
          opacity: 0.6,
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

  @override
  Widget build(BuildContext context) {
    final items = widget.feeds ?? const <FeedDto>[];

    return PageView(
      scrollDirection: Axis.horizontal,
      controller: feedController,
      onPageChanged: onPageSwipe,
      children: [
        const Text('Write 페이지로 이동'),

        // 가운데: 피드 본문 (UI 전용 렌더링)
        Builder(
          builder: (context) {
            if (items.isEmpty) {
              return _buildExample();
            }
            if (items.length == 1) {
              return _buildPost(items.first); // 더 이상 예시 중복 노출 없음
            }
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: items.length,
              itemBuilder: (context, index) => _buildPost(items[index]),
            );
          },
        ),

        const Text('Comment 페이지로 이동'),
      ],
    );
  }
}
