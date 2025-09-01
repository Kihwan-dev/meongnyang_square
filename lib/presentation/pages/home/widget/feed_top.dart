import 'package:flutter/material.dart';
class FeedTop extends StatelessWidget {
  const FeedTop({super.key, this.createdAt, this.createdAtStream});

  /// 단발성 데이터 (부모가 StreamBuilder로 값을 내려주는 경우)
  final DateTime? createdAt;

  /// 위젯 내부에서 실시간 반영하고 싶을 때 사용하는 스트림
  /// (둘 다 null이면 예시 텍스트를 표시)
  final Stream<DateTime?>? createdAtStream;

  String _format(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    // 예시 형식과 동일: 08. 28 13:08
    return '$mm. $dd $hh:$mi';
  }

  Widget _row(String rightText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/logo_s.png', width: 40, height: 20),
        // 작성시간
        Text(
          rightText,
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 스트림이 주어지면 실시간으로 표시
    if (createdAtStream != null) {
      return StreamBuilder<DateTime?>(
        stream: createdAtStream,
        builder: (context, snap) {
          final dt = snap.data ?? createdAt; // 스트림 값 > 단발성 값 > 예시
          final text = dt != null ? _format(dt) : '08. 28 13:08';
          return _row(text);
        },
      );
    }

    // 단발성 값만 있는 경우
    if (createdAt != null) {
      return _row(_format(createdAt!));
    }

    // 아무 값도 없으면 예시 그대로 노출
    return _row('08. 28 13:08');
  }
}
