import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentPage extends StatefulWidget {
  final String postId;
  const CommentPage({super.key, required this.postId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final commentController = TextEditingController();
  final textFieldFocus = FocusNode();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance
          .collection('feeds')
          .doc(widget.postId)
          .collection('comments');

  Stream<QuerySnapshot<Map<String, dynamic>>> get _commentStream =>
      _col.orderBy('createdAt', descending: true).snapshots();

  @override
  void dispose() {
    commentController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    try {
      await _col.add({
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'clientAt': DateTime.now(),
        // 'userId': ...  필요하면 추가
      });

      // 전송 후 입력 지우고 포커스 제거
      commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 전송 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: IconButton(
            icon: Image.asset(
              'assets/images/icon_back.png',
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        centerTitle: true,
        title: Image.asset('assets/images/logo_s.png', width: 40, height: 20),
      ),
      body: _getScreen(context, bottomInset),
    );
  }

  Container _getScreen(BuildContext context, double bottomInset) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/sample01.png"),
          fit: BoxFit.fitHeight,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "comments",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Expanded(child: _getCommentList()),
                ],
              ),
            ),
          ),
          _getBottomTextField(bottomInset),
        ],
      ),
    );
  }

  Padding _getBottomTextField(double bottomInset) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Focus(
            onFocusChange: (_) => setState(() {}),
            child: Builder(
              builder: (context) {
                final focused = FocusScope.of(context).hasFocus;
                final bgColor = focused
                    ? Colors.white.withValues(alpha: 1.0) // 포커스: 불투명 100%
                    : Colors.white.withValues(alpha: 0.08); // 비포커스: 옅게

                return AnimatedContainer(
                  height: 100,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  duration: Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          focusNode: textFieldFocus,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          minLines: 1,
                          maxLines: 4,
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          // 포커스에 따라 글자색 변경
                          style: TextStyle(
                            color: focused ? Colors.black87 : Colors.white,
                            fontSize: 16,
                          ),
                          cursorColor: focused ? Colors.black87 : Colors.white,
                          decoration: InputDecoration(
                            hintText: focused ? "" : "댓글을 입력하세요",
                            hintStyle: TextStyle(
                              color: focused
                                  ? Colors.black38
                                  : Colors.white.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                          ),
                          enableSuggestions: true,
                          autocorrect: true,
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: const Color(0xFF9ABC85),
                          ),
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCommentList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _commentStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox.square(
              dimension: 32,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('오류 : ${snapshot.error}',
                  style: TextStyle(color: Colors.white)));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child:
                Text('첫 댓글을 남겨보세요!', style: TextStyle(color: Colors.white70)),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: docs.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final text = (data['text'] ?? '') as String;

            // createdAt(서버) 없으면 clientAt(로컬) 사용
            DateTime? createdAt;
            final ts = data['createdAt'];
            if (ts is Timestamp) createdAt = ts.toDate();
            final clientAt = data['clientAt'];
            DateTime? clientDt;
            if (clientAt is Timestamp) clientDt = clientAt.toDate();
            if (clientAt is DateTime) clientDt = clientAt;

            final shownTime = createdAt ?? clientDt;

            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.02),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        softWrap: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          shownTime == null
                              ? '보내는 중…' // 서버 타임스탬프 들어오기 전
                              : _formatExact(shownTime),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatExact(DateTime dt) {
    final f = DateFormat('yyyy.MM.dd HH:mm');
    return f.format(dt);
  }

/*
  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  */
}
