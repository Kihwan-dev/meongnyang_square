import 'package:flutter/material.dart';
import 'package:meongnyang_square/presentation/pages/splash/splash_widgets/auth_form.dart';

//스플래시 화면
class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  //로고 위로 이동, 버튼 페이드인
  late Animation<double> _translateY;
  late Animation<double> _loginFade;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, _translateY.value),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            //로고 이미지
                            Image.asset(
                              'assets/images/logo.png',
                              width: 116,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              
                  //로그인폼:페이드인
                  Opacity(
                    opacity: _loginFade.value,
                    child: IgnorePointer(
                      ignoring: _loginFade.value < 0.99, // 거의 다 보일 때부터 터치 허용
                      child: AuthForm(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
