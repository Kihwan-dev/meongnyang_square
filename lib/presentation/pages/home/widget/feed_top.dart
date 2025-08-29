import 'package:flutter/material.dart';

class FeedTop extends StatelessWidget {
  const FeedTop({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/logo_s.png', width: 40, height: 20),
        //작성시간
        Text('08. 28 13:08', style: TextStyle(fontWeight: FontWeight.w300)),
      ],
    );
  }
}
