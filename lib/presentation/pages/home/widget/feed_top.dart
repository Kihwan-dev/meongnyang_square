import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meongnyang_square/presentation/pages/splash/auth_view_model.dart';

class FeedTop extends ConsumerWidget {
  FeedTop(this.createdAt);
  final DateTime createdAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async{//로그아웃
            final vm = ref.read(authViewModelProvider.notifier);
            vm.logout();
            if(context.mounted){
              context.go('/');
            }
          },
          child: Image.asset('assets/images/logo_s.png', width: 40, height: 20)),
        //작성시간
        Text(DateFormat('MM.dd HH:mm').format(createdAt), style: TextStyle(fontWeight: FontWeight.w300)),
      ],
    );
  }
}
