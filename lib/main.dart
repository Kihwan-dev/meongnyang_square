import 'package:flutter/material.dart';
import 'package:meongnyang_square/presentation/pages/splash/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'SCDream',
      ),
      home: SplashPage(),
    );
  }
}

