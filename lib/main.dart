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
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'SCDream',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'SCDream',
      ),
      home: SplashPage(),
    );
  }
}
