import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'screens/login/ios_login_screen.dart';

void main() {
  // iOS 스타일 상태바 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const IlhayoungApp());
}

class IlhayoungApp extends StatelessWidget {
  const IlhayoungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '일하영',
      theme: AppTheme.iosTheme,
      home: const IosLoginScreen(),
      debugShowCheckedModeBanner: false,

      // iOS 스타일 페이지 전환
      builder: (context, child) {
        return CupertinoTheme(
          data: const CupertinoThemeData(
            primaryColor: AppTheme.primaryBlue,
            scaffoldBackgroundColor: AppTheme.background,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(
                fontFamily: '.SF Pro Text',
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}