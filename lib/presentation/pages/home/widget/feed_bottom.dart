import 'package:flutter/material.dart';
import 'package:meongnyang_square/presentation/pages/comment/comment_page.dart';
import 'package:meongnyang_square/presentation/pages/write/write_page.dart';

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
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => WritePage()));
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
            final id = postId!;
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CommentPage(postId: id)),
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
