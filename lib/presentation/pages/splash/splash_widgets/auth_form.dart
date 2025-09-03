import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meongnyang_square/presentation/pages/splash/auth_view_model.dart';

// 로그인, 인포 폼
class AuthForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  //에러메시지 다이얼로그
  void showErrorPopup({String? message}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('실패!'),
          content:
              Text((message?.isNotEmpty ?? false) ? message! : '문제가 발생했습니다.'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('닫기'),
            ),
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
      if (!mounted) return;
      context.go('/homepage');
    } catch (e) {
      emailController.clear();
      pwController.clear();
      showErrorPopup(
          message: '이메일 또는 비밀번호가 올바르지 않습니다. \n회원이 아니시라면 회원가입을 진행해주세요.');
    }
  }

  //회원가입 버튼
  Future<void> joinBtnPressed() async {
    try {
      await ref
          .read(authViewModelProvider.notifier)
          .join(emailController.text, pwController.text);
      if (!mounted) return;
      context.go('/homepage');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showErrorPopup(message: '이미 사용중인 이메일입니다.');
      }
    } catch (e) {
      showErrorPopup();
    }
  }

  //텍스트폼 필드 & 밸리데이트
  TextFormField inputBox(
      TextEditingController controller, String title, bool obscure) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 20),
          width: 75,
          child: Text(title, style: const TextStyle(color: Colors.white60)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 75),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        errorMaxLines: 2,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "$title 입력해주세요";
        if (title == "Email" && !value.contains("@")) return "올바른 이메일 형식이 아닙니다";
        if ((title == "Pw" || title == "Password") && value.length < 6) {
          return "비밀번호는 6자 이상이어야 합니다";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            inputBox(emailController, 'Email', false),
            const SizedBox(height: 16),
            inputBox(pwController, 'Pw', true),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(0, 60),
                      backgroundColor: const Color(0xff9ABC85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        loginBtnPressed();
                      }
                    },
                    child: Text('Login',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16,),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(0, 60),
                      backgroundColor: const Color(0xffE5EFE7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        joinBtnPressed();
                      }
                    },
                    child: Text('Join',
                      style: const TextStyle(
                        color: Color(0xff8BB571),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
