import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponsiveHelper {
  // 📱 모바일 기기 체크 (화면 너비 768px 미만)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  // 📟 태블릿 기기 체크 (화면 너비 768px 이상 1024px 미만)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  // 🖥️ 데스크톱 기기 체크 (화면 너비 1024px 이상)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  // 🌐 웹 플랫폼 체크
  static bool isWeb() {
    return kIsWeb;
  }

  // 📏 최대 너비 설정 (컨텐츠가 너무 넓어지지 않도록)
  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;  // 모바일은 전체 너비 사용
    } else if (isTablet(context)) {
      return 480;  // 태블릿은 480px 제한
    } else {
      return 400;  // 데스크톱은 400px 제한 (깔끔한 중앙 정렬)
    }
  }

  // 📐 화면 패딩 설정 (기기별로 다른 여백)
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 40);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(40);
    } else {
      return const EdgeInsets.all(60);  // 데스크톱은 더 큰 여백
    }
  }

  // 🔤 폰트 크기 조정 (기기별로 다른 크기)
  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;  // 기본 크기
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;  // 10% 크게
    } else {
      return baseFontSize * 1.2;  // 20% 크게
    }
  }

  // ✨ 블러 반경 설정 (웹에서는 더 크게)
  static double getBlurRadius(BuildContext context) {
    return isWeb() ? 20 : 10;
  }

  // 📱 화면 크기별 컬럼 개수 (그리드에서 사용)
  static int getColumnCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;  // 모바일: 1열
    } else if (isTablet(context)) {
      return 2;  // 태블릿: 2열
    } else {
      return 3;  // 데스크톱: 3열
    }
  }

  // 🎨 아이콘 크기 조정
  static double getIconSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize;
    } else if (isTablet(context)) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.4;
    }
  }

  // 📊 차트나 그래프 높이 설정
  static double getChartHeight(BuildContext context) {
    if (isMobile(context)) {
      return 200;
    } else if (isTablet(context)) {
      return 300;
    } else {
      return 400;
    }
  }

  // 🎛️ 버튼 높이 설정
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 50;
    } else if (isTablet(context)) {
      return 55;
    } else {
      return 60;
    }
  }

  // 📝 텍스트필드 패딩 설정
  static EdgeInsets getTextFieldPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 18);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
  }

  // 🃏 카드 사이 간격 설정
  static double getCardSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 20;
    } else {
      return 24;
    }
  }

  // 📱 SafeArea 체크 (노치가 있는 기기 등)
  static bool hasSafeArea(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top > 0 || padding.bottom > 0;
  }

  // 🔄 세로/가로 모드 체크
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  // 📏 화면 크기 정보 가져오기
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // 📊 화면 비율 계산
  static double getScreenRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }

  // 🎯 반응형 값 설정 (3가지 값 중에서 기기에 맞는 값 선택)
  static T getResponsiveValue<T>(
      BuildContext context, {
        required T mobile,
        T? tablet,
        T? desktop,
      }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // 📱 사용 예시들:

  // 반응형 패딩
  static EdgeInsets responsivePadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  // 반응형 폰트 크기
  static double responsiveFont(BuildContext context, double baseSize) {
    return getResponsiveValue(
      context,
      mobile: baseSize,
      tablet: baseSize * 1.1,
      desktop: baseSize * 1.2,
    );
  }

  // 반응형 그리드 개수
  static int responsiveGrid(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 1,
      tablet: 2,
      desktop: 3,
    );
  }
}