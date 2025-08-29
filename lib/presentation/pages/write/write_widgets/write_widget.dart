import 'package:flutter/material.dart';

class TagAndContentCard extends StatelessWidget {
  const TagAndContentCard({
    super.key,
    required this.tagController,
    required this.contentController,
    required this.maximumLength,
  });

  final TextEditingController tagController;
  final TextEditingController contentController;
  final int maximumLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text(
                    '#',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: tagController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: '태그를 입력하세요',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ]),
                const Divider(color: Colors.white24, height: 28),
                Expanded(
                  child: TextField(
                    controller: contentController,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: '내용을 입력하세요',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 30,
            bottom: 40,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: contentController,
              builder: (context, value, _) {
                final int current = value.text.length;
                return Text(
                  '$current/$maximumLength',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}