import 'package:flutter/material.dart';
import 'package:meongnyang_square/presentation/pages/comment/comment_page.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_bottom.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_center.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_top.dart';
import 'package:meongnyang_square/presentation/pages/write/write_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late PageController feedController;
  bool isSwiping = false;

  //빌드시 1페이지로
  @override
  void initState() {
    super.initState();
    feedController = PageController(initialPage: 1);
  }

  //컨트롤러 초기화
  @override
  void dispose() {
    feedController.dispose();
    super.dispose();
  }

  //스와이프 시 이동
  onPageSwipe(int page) async {
    if (page == 1) return;
    if (isSwiping) return;
    isSwiping = true;

    if (page == 0) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => WritePage()));
    } else if (page == 2) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => CommentPage()));
    }

    if (mounted) {
      feedController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
    isSwiping = false;
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.horizontal,
      controller: feedController,
      onPageChanged: onPageSwipe,
      children: [
        const Text('Write 페이지로 이동'),
        //feed본문
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/sample01.png'),
              fit: BoxFit.cover,
              opacity: 0.6,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(children: [FeedTop(), FeedCenter(), FeedBottom()]),
            ),
          ),
        ),
        const Text('Comment 페이지로 이동'),
      ],
    );
  }
}
