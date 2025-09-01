import 'package:flutter/material.dart';
import 'package:meongnyang_square/presentation/pages/home/widget/feed_page.dart';
import 'package:meongnyang_square/presentation/pages/home/home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(oldestFirst: true, limit: 30);
    _viewModel.start();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _viewModel, 
        builder: (context, _) {
          return FeedPage(
            feeds: _viewModel.feeds,
            onEndReached: _viewModel.loadMore,
            isLoadingMore: _viewModel.isLoadingMore,
            hasMore: _viewModel.hasMore,
            onRefresh: _viewModel.refresh,
          );
        },
      ),
    );
  }
}
