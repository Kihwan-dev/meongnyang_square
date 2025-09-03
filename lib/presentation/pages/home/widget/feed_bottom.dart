import 'package:flutter/material.dart';
import 'package:meongnyang_square/presentation/pages/comment/comment_page.dart';
import 'package:meongnyang_square/presentation/pages/write/write_page.dart';

class FeedBottom extends StatelessWidget {
  final VoidCallback? onWritePressed;
  final VoidCallback? onCommentPressed;

  const FeedBottom({
    super.key,
    this.onWritePressed,
    this.onCommentPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (onWritePressed != null) {
              onWritePressed!.call();
              return;
            }
            // 기본 동작: WritePage로 이동
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => WritePage()),
            );
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
            if (onCommentPressed != null) {
              onCommentPressed!.call();
              return;
            }
            // 기본 동작: CommentPage로 이동
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => CommentPage()),
            );
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
