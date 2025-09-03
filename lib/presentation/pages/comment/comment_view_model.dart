import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/core/notifications/notification_helper.dart';

class Comment {
  Comment({
    required this.id,
    required this.text,
    required this.authorId,
    required this.createdAt,
    this.clientAt,
  });

  final String id;
  final String text;
  final String authorId;
  final DateTime? createdAt; // 서버 타임
  final DateTime? clientAt; // 로컬 타임(대기 표시용)
}

class CommentState {
  const CommentState({
    this.isLoading = false,
    this.postAuthorId,
    this.comments = const [],
    this.error,
  });

  final bool isLoading;
  final String? postAuthorId;
  final List<Comment> comments;
  final String? error;

  CommentState copyWith({
    bool? isLoading,
    String? postAuthorId,
    List<Comment>? comments,
    String? error,
  }) {
    return CommentState(
      isLoading: isLoading ?? this.isLoading,
      postAuthorId: postAuthorId ?? this.postAuthorId,
      comments: comments ?? this.comments,
      error: error,
    );
  }
}

class CommentViewModel extends AutoDisposeFamilyNotifier<CommentState, String> {
  late final String postId = arg;
  StreamSubscription? _sub;

  @override
  CommentState build(String arg) {
    ref.onDispose(() {
      _sub?.cancel();
    });
    return const CommentState();
  }

  /// 최초 1회: 글 작성자 조회 + 댓글 스트림 구독
  Future<void> init() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

    try {
      // 작성자(authorId) 조회
      final postSnap = await FirebaseFirestore.instance
          .collection('feeds')
          .doc(postId)
          .get();
      final postData = postSnap.data();
      final postAuthorId = postData?['authorId'] as String?;

      // 댓글 스트림 구독
      _sub?.cancel();
      _sub = FirebaseFirestore.instance
          .collection('feeds')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((qs) {
        final list = qs.docs.map((d) {
          final data = d.data();
          DateTime? createdAt;
          final ts = data['createdAt'];
          if (ts is Timestamp) createdAt = ts.toDate();
          DateTime? clientAt;
          final ca = data['clientAt'];
          if (ca is Timestamp) clientAt = ca.toDate();
          if (ca is DateTime) clientAt = ca;

          return Comment(
            id: d.id,
            text: (data['text'] ?? '') as String,
            authorId: (data['authorId'] ?? '') as String,
            createdAt: createdAt,
            clientAt: clientAt,
          );
        }).toList();

        state = state.copyWith(
          isLoading: false,
          postAuthorId: postAuthorId,
          comments: list,
          error: null,
        );
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '$e');
    }
  }

  /// 댓글 추가 + 로컬 알림
  Future<String?> addComment(String text) async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return '로그인이 필요합니다.';

    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    try {
      await FirebaseFirestore.instance
          .collection('feeds')
          .doc(postId)
          .collection('comments')
          .add({
        'text': trimmed,
        'authorId': me.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'clientAt': DateTime.now(),
      });

      // 글 작성자에게 로컬 알림
      final postAuthorId = state.postAuthorId;
      // if (postAuthorId != null && postAuthorId != me.uid) { //(본인이면 X)
      //   await NotificationHelper.show('새 댓글', '내 게시물에 새 댓글이 달렸어요');
      // }
      if (postAuthorId != null) {
        await NotificationHelper.show('새 댓글', '내 게시물에 새 댓글이 달렸어요');
      }
      return null;
    } catch (e) {
      return '댓글 전송 실패: $e';
    }
  }
}
