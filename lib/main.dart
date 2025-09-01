import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/domain/entities/feed.dart';
import 'package:meongnyang_square/presentation/pages/home/home_page.dart';
import 'package:meongnyang_square/presentation/pages/splash/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meongnyang_square/presentation/pages/write/write_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
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
      home: WritePage(
          // feed: Feed(
          //   id: "",
          //   imagePath: "https://picsum.photos/200/300",
          //   tag: "태그",
          //   content: "내용",
          //   createdAt: DateTime.now(),
          // ),
          ),
    );
  }
}
