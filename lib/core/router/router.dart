import 'dart:io';

import 'package:go_router/go_router.dart';
import 'package:meongnyang_square/presentation/pages/comment/comment_page.dart';
import 'package:meongnyang_square/presentation/pages/error/error_page.dart';
import 'package:meongnyang_square/presentation/pages/home/home_page.dart';
import 'package:meongnyang_square/presentation/pages/splash/splash_page.dart';
import 'package:meongnyang_square/presentation/pages/write/write_page.dart';
import 'package:meongnyang_square/presentation/pages/write/write_widgets/cropper_widget.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashPage(),
      routes: [
        GoRoute(
            path: 'homepage',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                  path: 'writepage',
                  builder: (context, state) => WritePage(),
                  routes: [
                    GoRoute(
                      path: 'cropper',
                      name: 'cropper',
                      builder: (context, state) {
                        return CropperWidget(file: state.extra as File);
                      },
                    ),
                  ]),
              GoRoute(
                path: 'comment/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CommentPage(
                    postId: id,
                  );
                },
              ),
            ]),
      ],
    ),
  ],
  initialLocation: '/',
  errorBuilder: (context, state) {
    return ErrorPage();
  },
);
