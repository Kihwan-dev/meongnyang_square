import 'package:flutter/material.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: PageView(
      scrollDirection: Axis.vertical,
      children: [
        FeedPage(),
        FeedPage(),
      ]));
  }
}
