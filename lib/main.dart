import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/auth_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: JejuApp()));
}

class JejuApp extends StatelessWidget {
  const JejuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '일하영 - 제주 일자리 플랫폼',
      debugShowCheckedModeBanner: false,
      theme: JejuTheme.theme,
      home: const AuthWrapper(),
    );
  }
}