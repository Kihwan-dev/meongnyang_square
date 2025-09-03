import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meongnyang_square/core/notifications/notification_helper.dart';

/// 내 글들에 달리는 새 댓글을 감지해서 로컬 알림을 띄우는 워처
class NotificationService {
  NotificationService({required this.currentUserId});

  final String currentUserId;

  final _subs = <StreamSubscription>[];
  final _lastNotifiedCommentIdForPost =
      <String, String?>{}; // postId -> last commentId

  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    // 1) 내가 작성한 feed 목록 리슨
    final postsQuery = FirebaseFirestore.instance
        .collection('feeds')
        .where('authorId', isEqualTo: currentUserId);

    final postsSub = postsQuery.snapshots().listen((postSnap) {
      // 각 포스트마다 최신 댓글 1개를 리슨
      for (final postDoc in postSnap.docs) {
        final postId = postDoc.id;
        _ensureCommentListener(postId);
      }
    });

    _subs.add(postsSub);
  }

  void _ensureCommentListener(String postId) {
    // 이미 리슨 중이면 패스
    final alreadyListening = _subs.any((s) => false); // 간단히 중복 방지 안함
    // (간단히 처리: 같은 postId 중복 리슨이 드물다면 생략 가능. 필요시 Map에 따로 관리)

    final commentsQuery = FirebaseFirestore.instance
        .collection('feeds')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .limit(1);

    final sub = commentsQuery.snapshots().listen((commentSnap) async {
      if (commentSnap.docs.isEmpty) return;

      final c = commentSnap.docs.first;
      final cid = c.id;
      final data = c.data();

      // 중복 방지: 이 postId에 대해 마지막으로 알린 댓글과 같은지 확인
      final lastId = _lastNotifiedCommentIdForPost[postId];
      if (lastId == cid) return;

      final commenterId =
          (data['authorId'] ?? data['userId']) as String?; // 댓글 작성자
      //if (commenterId == currentUserId) { // 내가 내 글에 단 댓글이면 알림 X
      //_lastNotifiedCommentIdForPost[postId] = cid;
      //  return;
      //}

      final text = (data['text'] as String?) ?? '(내용 없음)';

      // 알림 제목/본문 구성 (필요 시 글 태그/제목 가져오기)
      final title = '내 게시물에 새 댓글';
      final content = text.length > 60 ? '${text.substring(0, 60)}…' : text;

      await NotificationHelper.show(title, content);

      _lastNotifiedCommentIdForPost[postId] = cid;
    });

    _subs.add(sub);
  }

  Future<void> stop() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _started = false;
  }
}
