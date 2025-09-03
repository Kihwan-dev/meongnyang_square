import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/presentation/pages/comment/comment_page.dart';
import 'package:meongnyang_square/presentation/pages/error/error_page.dart';
import 'package:meongnyang_square/presentation/pages/home/home_page.dart';
import 'package:meongnyang_square/presentation/pages/splash/splash_page.dart';
import 'package:meongnyang_square/presentation/pages/write/write_page.dart';
import 'package:meongnyang_square/presentation/pages/write/write_widgets/cropper_widget.dart';
import 'package:meongnyang_square/presentation/providers.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashPage(),
      routes: [
        GoRoute(
          path: 'home',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'write',
              builder: (context, state) {
                final feed = state.extra as Feed;
                return WritePage(feed);
              },
              // WritePage에서 나갈 때 HomePage 새로고침
              onExit: (context, state) {
                final container = ProviderScope.containerOf(context);
                container.read(homeViewModelProvider.notifier).fetchFeeds();
                return true;
              },
              routes: [
                GoRoute(
                  path: 'cropper',
                  name: 'cropper',
                  builder: (context, state) {
                    return CropperWidget(file: state.extra as File);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'comment',
              builder: (context, state) {
                final id = state.extra as String;
                return CommentPage(
                  postId: id,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
  initialLocation: '/',
  errorBuilder: (context, state) {
    return ErrorPage();
  },
);
