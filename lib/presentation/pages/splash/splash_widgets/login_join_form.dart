// 로그인, 인포 폼
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginjoinForm extends StatefulWidget {
  @override
  State<LoginjoinForm> createState() => _LoginjoinFormState();
}

class _LoginjoinFormState extends State<LoginjoinForm> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  String _msg = '';

  Future<void> _login() async {
    if (_email.text.isEmpty || _pw.text.isEmpty) {
      setState(() => _msg = '이메일과 비밀번호를 입력해 주세요.');
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pw.text,
      );
      setState(() => _msg = '로그인 성공!');
    } catch (e) {
      setState(() => _msg = '로그인 실패: $e');
    }
  }

  Future<void> _join() async {
    if (_email.text.isEmpty || _pw.text.isEmpty) {
      setState(() => _msg = '이메일과 비밀번호를 입력해 주세요.');
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pw.text,
      );
      setState(() => _msg = '회원가입 성공!');
    } catch (e) {
      setState(() => _msg = '회원가입 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: '이메일')),
          const SizedBox(height: 8),
          TextField(
              controller: _pw,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호')),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: _login, child: const Text('Login'))),
              const SizedBox(width: 8),
              Expanded(
                  child: OutlinedButton(
                      onPressed: _join, child: const Text('Join'))),
            ],
          ),
          const SizedBox(height: 16),
          Text(_msg, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
