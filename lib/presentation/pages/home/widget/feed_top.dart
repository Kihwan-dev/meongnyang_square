import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedTop extends StatelessWidget {
  FeedTop(this.createdAt);
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/logo_s.png', width: 40, height: 20),
        //작성시간
        Text(DateFormat('MM.dd HH:mm').format(createdAt), style: TextStyle(fontWeight: FontWeight.w300)),
      ],
    );
  }
}
