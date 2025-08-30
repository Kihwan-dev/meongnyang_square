import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/presentation/pages/home/home_page.dart';
import 'package:meongnyang_square/presentation/pages/splash/splash_view_model.dart';

// 로그인, 인포 폼
class AuthForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  bool isUser = true;

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  //로그인실패 회원가입 진행 팝업
  void showJoinPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('로그인 실패'),
          content: const Text('이메일 혹은 비밀번호 오류입니다.\n회원이 아니시라면 회원가입을 진행해주세요.'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('닫기')),
            TextButton(
                onPressed: () {
                  setState(() {
                    isUser = false;
                  });
                  Navigator.pop(context);
                },
                child: const Text('회원가입')),
          ],
        );
      },
    );
  }

  //로그인 버튼
  Future<void> loginBtnPressed() async {
    try {
      await ref
          .read(authViewModelProvider.notifier)
          .login(emailController.text, pwController.text);
      setState(() {
        isUser = true;
      });
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ));
    } catch (e) {
      print('로그인 실패!! $e');
      emailController.clear();
      pwController.clear();
      showJoinPopup();
    }
  }

  //회원가입 버튼
  Future<void> joinBtnPressed() async {
    try {
      await ref
          .read(authViewModelProvider.notifier)
          .join(emailController.text, pwController.text);
      setState(() {
        isUser = true;
      });
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return HomePage();
        },
      ));
    } catch (e) {
      setState(() {
        isUser = false;
      });
      print('회원가입 실패!! $e');
    }
  }

  //텍스트필드
  Container inputBox(TextEditingController controller, String title, bool obscure) {
    return Container(
      padding: EdgeInsets.only(left: 20),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
              width: 55,
              child: Text(
                title,
                style: TextStyle(color: Colors.white60),
              )),
          Expanded(
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              controller: controller,
              obscureText: obscure,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          inputBox(emailController, 'Email', false),
          SizedBox(height: 16,),
          inputBox(pwController, 'Pw', true),
          SizedBox(height: 16,),
          SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff9ABC85),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: isUser ? loginBtnPressed : joinBtnPressed,
                  child: Text(
                    isUser ? 'Login' : 'Join',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  )))
        ],
      ),
    );
  }

}
