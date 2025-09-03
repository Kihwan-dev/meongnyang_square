import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meongnyang_square/presentation/pages/splash/splash_widgets/auth_form.dart';

//스플래시 화면
class SplashPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  //로고 위로 이동, 버튼 페이드인
  late Animation<double> _translateY;
  late Animation<double> _loginFade;

  //세션확인용
  bool checkingSession = true;
  bool _hasSession = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );

    //위로 이동
    _translateY = Tween<double>(begin: 0.0, end: -50.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)),
    );

    //페이드 인
    _loginFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.7, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && _hasSession) {
        context.go('/homepage');
      }
    });
    checkSessionRoute();
  }

  //세션확인
  Future<void> checkSessionRoute() async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (!mounted) return;

    if (user != null) {
      _hasSession = true;
    } else {
      setState(() => checkingSession = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 스플래시(로고 애니메이션)는 항상 그림
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _translateY.value),
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child:
                              Image.asset('assets/images/logo.png', width: 116),
                        ),
                      ),
                    ),

                    // 로그인 폼은 세션 없을 때만
                    if (!checkingSession && !_hasSession)
                      Opacity(
                        opacity: _loginFade.value,
                        child: IgnorePointer(
                          ignoring: _loginFade.value < 0.99,
                          child: AuthForm(),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
