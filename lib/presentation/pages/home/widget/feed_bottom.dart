import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class FeedBottom extends StatelessWidget {
  const FeedBottom({super.key, required this.postId});
  final String? postId;

  @override
  Widget build(BuildContext context) {
    final canOpenComment = postId != null && postId!.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            context.push('/homepage/writepage');
          },
          child: Container(
            padding: EdgeInsets.all(12),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, .4),
              borderRadius: BorderRadius.circular(48),
            ),
            child: ImageIcon(AssetImage('assets/images/icon_pencil.png')),
          ),
        ),
        GestureDetector(
          onTap: () {
            final openComment = postId != null && postId!.isNotEmpty;
            if (!canOpenComment) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('댓글을 열 수 없는 게시글입니다.')),
              );
              return;
            }
            context.push('/homepage/comment/${postId!}');
          },
          child: Container(
            padding: EdgeInsets.all(12),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, .4),
              borderRadius: BorderRadius.circular(48),
            ),
            child: ImageIcon(AssetImage('assets/images/icon_comment.png')),
          ),
        ),
      ],
    );
  }
}
