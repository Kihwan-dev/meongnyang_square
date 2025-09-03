import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meongnyang_square/core/router/router.dart';
import 'package:meongnyang_square/firebase_options.dart';
import 'package:meongnyang_square/core/notifications/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationHelper.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'SCDream',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'SCDream',
      )
    );
  }
}
