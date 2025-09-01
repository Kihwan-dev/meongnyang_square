
import 'package:flutter/material.dart';

class FeedCenter extends StatelessWidget {
  const FeedCenter({
    super.key,
    this.title,
    this.content,
    this.titleStream,
    this.contentStream,
  });

  /// 제목(예: 태그나 헤드라인). 값이 없으면 예시 텍스트를 사용
  final String? title;

  /// 본문 내용. 값이 없으면 예시 텍스트를 사용
  final String? content;

  /// 제목의 실시간 변경을 반영하고 싶을 때 전달하는 스트림.
  final Stream<String?>? titleStream;

  /// 본문의 실시간 변경을 반영하고 싶을 때 전달하는 스트림.
  final Stream<String?>? contentStream;

  @override
  // 기존의 예시로 보여진 부분을 예비로 넣어 데이터가 없을 시 표기 되도록 함.
  Widget build(BuildContext context) {
    const String defaultTitle = '#꼬리의진실';
    const String defaultContent = '흔들흔들\n신나서 그런 줄 알았는데…\n\n사실은\n밥 달라는 신호였다고 한다.';

    Widget buildTitle(String? value) {
      final text = (value != null && value.isNotEmpty) ? value : defaultTitle;
      return Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      );
    }

    Widget buildContent(String? value) {
      final text = (value != null && value.isNotEmpty) ? value : defaultContent;
      return Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white60),
        textAlign: TextAlign.center,
      );
    }

    final Widget titleWidget = titleStream != null
        ? StreamBuilder<String?>(
            stream: titleStream,
            builder: (context, snap) => buildTitle(snap.data ?? title),
          )
        : buildTitle(title);

    final Widget contentWidget = contentStream != null
        ? StreamBuilder<String?>(
            stream: contentStream,
            builder: (context, snap) => buildContent(snap.data ?? content),
          )
        : buildContent(content);

    // 기존 위젯이 Expanded를 반환하던 형태를 그대로 유지
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            titleWidget,
            const SizedBox(height: 20),
            contentWidget,
          ],
        ),
      ),
    );
  }
}
