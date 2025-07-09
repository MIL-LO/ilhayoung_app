// lib/core/constants/app_constants.dart

class AppConstants {
  // API 기본 URL
  static const String baseUrl = 'https://api.ilhayoung.com';

  // API 엔드포인트들
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // 채용공고 관련 엔드포인트
  static const String recruitsEndpoint = '$apiPrefix/recruits';

  // 인증 관련 엔드포인트
  static const String authEndpoint = '$apiPrefix/auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String signupEndpoint = '$authEndpoint/signup';
  static const String refreshEndpoint = '$authEndpoint/refresh';

  // OAuth 관련 엔드포인트
  static const String oauthEndpoint = '$apiPrefix/oauth';

  // 사용자 정보 관련 엔드포인트
  static const String userEndpoint = '$apiPrefix/user';

  // 지원 관련 엔드포인트
  static const String applicationsEndpoint = '$apiPrefix/applications';

  // 페이지네이션 기본값
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 캐시 관련 설정
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);

  // 타임아웃 설정
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);

  // 에러 메시지
  static const String networkError = '네트워크 오류가 발생했습니다.';
  static const String serverError = '서버 오류가 발생했습니다.';
  static const String unknownError = '알 수 없는 오류가 발생했습니다.';
  static const String tokenExpiredError = '로그인이 만료되었습니다. 다시 로그인해주세요.';

  // 성공 메시지
  static const String loginSuccess = '로그인에 성공했습니다.';
  static const String signupSuccess = '회원가입이 완료되었습니다.';
  static const String logoutSuccess = '로그아웃되었습니다.';
  static const String applicationSuccess = '지원이 완료되었습니다.';

  // 지역 데이터
  static const List<String> jejuRegions = [
    '제주 전체',
    '제주시',
    '서귀포시',
    '애월읍',
    '한림읍',
    '구좌읍',
    '조천읍',
    '성산읍',
    '표선면',
    '남원읍',
    '안덕면',
    '대정읍',
  ];

  // 업종 데이터
  static const List<String> jobCategories = [
    '전체',
    '카페/음료',
    '음식점',
    '숙박업',
    '관광/레저',
    '농업',
    '유통/판매',
    '서비스업',
    '제조업',
    '건설업',
    '운송업',
    '기타',
  ];

  // 근무 기간 옵션
  static const List<String> workPeriods = [
    '1-3개월',
    '3-6개월',
    '6-12개월',
    '장기',
  ];

  // 요일 데이터
  static const List<String> weekDays = [
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
    '일',
  ];

  // 앱 정보
  static const String appName = '제주 일하영';
  static const String appVersion = '1.0.0';
  static const String appDescription = '제주 일자리 플랫폼';

  // 디자인 상수
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;

  // 컬러 상수
  static const int primaryColorValue = 0xFF00A3A3;
  static const int accentColorValue = 0xFFFF6B35;
  static const int successColorValue = 0xFF4CAF50;
  static const int warningColorValue = 0xFFFF9800;
  static const int errorColorValue = 0xFFF44336;
  static const int backgroundColorValue = 0xFFF8FFFE;
}