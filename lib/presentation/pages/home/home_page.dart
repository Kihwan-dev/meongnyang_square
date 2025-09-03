import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_bottom.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_center.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_top.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/origin_feed_page.dart';
import 'package:meongnyang_square/presentation/pages/home/origin_home_view_model.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late PageController pageController;
  bool isSwiping = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  //스와이프 시 이동
  onPageSwipe(int page) async {
    if (page == 1) return;
    if (isSwiping) return;
    isSwiping = true;

    if (page == 0) {
      // await Navigator.of(
      //   context,
      // ).push(MaterialPageRoute(builder: (context) => WritePage()));
    } else if (page == 2) {
      // await Navigator.of(
      //   context,
      // ).push(MaterialPageRoute(builder: (context) => CommentPage()));
    }

    if (mounted) {
      pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
    isSwiping = false;
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.horizontal,
      controller: pageController,
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
