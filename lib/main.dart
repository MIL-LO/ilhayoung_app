import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/auth_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화 - 어드민 키 사용
  KakaoSdk.init(
    nativeAppKey: '', // 어드민 키 사용
  );

  // 웹에서는 시스템 UI 설정을 건너뛰기
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

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
      // 웹 전용 설정
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // 웹에서 텍스트 스케일링 제한
            textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2)
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
