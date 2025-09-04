import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';

class FeedBottom extends StatelessWidget {
  FeedBottom(this.feed);
  final Feed feed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            //write페이지로 이동!
            context.go("/home/Writepage", extra: feed);
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
            //comment페이지로 이동!
            context.go("/home/comment", extra: {"postId": feed.id, "postPath": feed.imagePath});
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
