// lib/config/app_config.dart

class AppConfig {
  // 개발/운영 환경 설정
  static const bool isDevelopment = false; // true: 로컬, false: 운영

  // 서버 URL 설정
  static String get baseUrl {
    if (isDevelopment) {
      return 'http://localhost:5000'; // 로컬 개발 서버
    } else {
      return 'https://api.ilhayoung.com'; // 🔥 변경된 운영 서버
    }
  }

  // API 버전
  static const String apiVersion = 'v1';

  // API Base URL
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';

  // OAuth URLs
  static String getOAuthUrl(String provider, String role) {
    return '$baseUrl/oauth2/authorization/$provider?role=$role';
  }

  // 앱 정보
  static const String appName = '일하영';
  static const String appVersion = '1.0.0';
  static const String appDescription = '제주 일자리 플랫폼';

  // 디버그 모드 설정
  static bool get isDebugMode => isDevelopment;
}