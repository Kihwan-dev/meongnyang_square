import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meongnyang_square/presentation/pages/comment/comment_view_model.dart';
import 'package:meongnyang_square/presentation/providers.dart';

class CommentPage extends ConsumerStatefulWidget {
  final String postId;
  final String postPath;
  const CommentPage({
    super.key,
    required this.postId,
    required this.postPath,
  });

  @override
  ConsumerState<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends ConsumerState<CommentPage> {
  final commentController = TextEditingController();
  final textFieldFocus = FocusNode();

  CollectionReference<Map<String, dynamic>> get _col => FirebaseFirestore.instance.collection("feeds").doc(widget.postId).collection("comments");

  @override
  void initState() {
    super.initState();
    textFieldFocus.addListener(() => setState(() {}));

    // 뷰모델 초기화 (작성자 조회 + 댓글 스트림 구독)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentViewModelProvider(widget.postId).notifier).init();
    });
  }

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
        //'userId': authorId,
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
    final vm = ref.watch(commentViewModelProvider(widget.postId));
    final notifier = ref.read(commentViewModelProvider(widget.postId).notifier);

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
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(widget.postPath),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("comments", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 20),
                    Expanded(child: _buildCommentList(vm)),
                  ],
                ),
              ),
            ),
            _buildBottomTextField(bottomInset, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentList(CommentState vm) {
    if (vm.isLoading && vm.comments.isEmpty) {
      return const Center(
        child: SizedBox.square(
          dimension: 32,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (vm.error != null) {
      return Center(
        child: Text('오류 : ${vm.error}', style: const TextStyle(color: Colors.white)),
      );
    }
    if (vm.comments.isEmpty) {
      return const Center(
        child: Text('첫 댓글을 남겨보세요!', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: vm.comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final c = vm.comments[index];
        final shownTime = c.createdAt ?? c.clientAt;

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
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
                  // 줄바꿈 포함해 모두 보임 (maxLines 제한 X)
                  Text(
                    c.text,
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      shownTime == null ? '보내는 중…' : _formatExact(shownTime),
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Padding _buildBottomTextField(double bottomInset, CommentViewModel notifier) {
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
                              color: focused ? Colors.black38 : Colors.white.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                          ),
                          enableSuggestions: true,
                          autocorrect: true,
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () async {
                          final err = await notifier.addComment(commentController.text);
                          if (!mounted) return;
                          if (err == null) {
                            commentController.clear();
                            FocusScope.of(context).unfocus();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err)),
                            );
                          }
                        },
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

  String _formatExact(DateTime dt) {
    final f = DateFormat('yyyy.MM.dd HH:mm');
    return f.format(dt);
  }
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
