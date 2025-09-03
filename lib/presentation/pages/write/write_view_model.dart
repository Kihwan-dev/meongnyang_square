import 'package:flutter/material.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';

class WriteViewModel {
  final tagController = TextEditingController();
  final contentController = TextEditingController();
  static const maxLength = 200;

  /// Feed 데이터를 전달받아
  /// - tagController, contentController 텍스트를 미리 채워주는 메서드
  /// - WritePage 진입 시 기존 Feed 데이터를 수정할 때 사용된다.
  void initializeFromFeed(Feed feed) {
    tagController.text = feed.tag;
    contentController.text = feed.content;
  }

  /// 현재 인덱스와 Feed 데이터를 디버그 콘솔에 출력하는 메서드
  /// - 개발 중 데이터가 올바르게 전달되었는지 확인할 때 사용된다.
  /// - 실제 서비스에서는 제거하거나 로그 레벨을 조정하는 것이 좋다.
  void debugPrintCurrentData(int index, Feed feed) {
    debugPrint('현재 인덱스: $index');
    debugPrint('Feed 데이터:');
    debugPrint('id: ${feed.id}');
    debugPrint('createdAt: ${feed.createdAt}');
    debugPrint('tag: ${feed.tag}');
    debugPrint('content: ${feed.content}');
    debugPrint('imagePath: ${feed.imagePath}');
  }

  void dispose() {
    tagController.dispose();
    contentController.dispose();
  }
}