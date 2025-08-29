import 'package:flutter/material.dart';

class FeedCenter extends StatelessWidget {
  const FeedCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //제목
            Text(
              '#꼬리의진실',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            //내용
            Text(
              '흔들흔들\n신나서 그런 줄 알았는데…\n\n사실은\n밥 달라는 신호였다고 한다.',
              style: const TextStyle(fontSize: 16, color: Colors.white60),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
