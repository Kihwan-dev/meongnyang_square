import 'dart:ui';

import 'package:flutter/material.dart';

class CommentPage extends StatefulWidget {
  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final commentController = TextEditingController();
  final textFieldFocus = FocusNode();
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();
    textFieldFocus.addListener(
      () {
        setState(() {
          hasFocus = textFieldFocus.hasFocus;
          print(hasFocus);
        });
      },
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Image.asset('assets/images/icon_back.png',
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
                  Expanded(
                    child: _getCommentList(),
                  ),
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
            onFocusChange: (value) => setState(() {}),
            child: Builder(builder: (context) {
              final focused = FocusScope.of(context).hasFocus;
              return AnimatedContainer(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: focused
                      ? Colors.white.withValues(alpha: 1.0) // 포커스: 불투명 100%
                      : Colors.white.withValues(alpha: 0.08), // 비포커스: 옅게
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                duration: Duration(milliseconds: 200),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        autofocus: true,
                        controller: commentController,
                        focusNode: textFieldFocus,
                        decoration: InputDecoration(
                          hintText: focused ? "" : "댓글을 입력하세요",
                          border: InputBorder.none, // 기본 밑줄 제거
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        // 코멘트 달기
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Color(0xFF9ABC85),
                        ),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  ListView _getCommentList() {
    return ListView.separated(
      padding: EdgeInsets.zero, // padding이 null이면
      itemCount: 10,
      separatorBuilder: (context, index) => SizedBox(
        height: 12,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: 100,
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
                  // 왼쪽 문구
                  Expanded(
                    child: Text(
                      "코멘트 내용 $index",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 오른쪽 날짜
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "시간",
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
  }
}
