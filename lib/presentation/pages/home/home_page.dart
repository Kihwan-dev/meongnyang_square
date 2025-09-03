import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_bottom.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_center.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_top.dart';
import 'package:meongnyang_square/presentation/providers.dart';

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
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    final homeState = ref.watch(homeViewModelProvider);
    final feeds = homeState.feeds;

    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: feeds.length,
        itemBuilder: (context, index) {
          final feed = feeds[index];
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
                    image: CachedNetworkImageProvider(feed.imagePath),
                    fit: BoxFit.fill,
                    opacity: 0.6,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        FeedTop(feed.createdAt),
                        FeedCenter(tag: feed.tag, content: feed.content),
                        FeedBottom(feed),
                      ],
                    ),
                  ),
                ),
              ),
              const Text('Comment 페이지로 이동'),
            ],
          );
        },
      ),
    );
  }
}
