import 'package:flutter/material.dart';

class FeedCenter extends StatelessWidget {
  FeedCenter({
    required this.tag,
    required this.content,
  });

  final String tag;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //제목
            Text(
              "#$tag",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            //내용
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.white60),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
