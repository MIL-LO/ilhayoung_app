import 'package:flutter/material.dart';

class JejuTheme {
  // 제주 현무암 컬러 팔레트
  static const Color basaltDark = Color(0xFF2C2C2C);     // 어두운 현무암
  static const Color basaltMedium = Color(0xFF404040);   // 중간 현무암
  static const Color basaltLight = Color(0xFF5A5A5A);    // 밝은 현무암
  static const Color basaltSoft = Color(0xFF8B8B8B);     // 부드러운 현무암

  // 제주 에메랄드 바다 컬러 팔레트
  static const Color emeraldDeep = Color(0xFF006B5C);    // 깊은 에메랄드
  static const Color emeraldBright = Color(0xFF00A085);  // 밝은 에메랄드
  static const Color emeraldSoft = Color(0xFF4DD0E1);    // 부드러운 에메랄드
  static const Color emeraldLight = Color(0xFF80E5FF);   // 연한 에메랄드
  static const Color emeraldFoam = Color(0xFFB3F5FF);    // 바다 거품

  // 제주 자연 컬러
  static const Color sunsetOrange = Color(0xFFFF8A50);   // 제주 노을
  static const Color tangerineOrange = Color(0xFFFF6B35); // 감귤
  static const Color skyBlue = Color(0xFF87CEEB);        // 제주 하늘
  static const Color stoneBeige = Color(0xFFF5F3F0);     // 돌담 베이지

  // 시스템 컬러
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFF8B8B8B);
  static const Color separator = Color(0xFFE9ECEF);
  static const Color systemRed = Color(0xFFDC3545);
  static const Color systemGreen = Color(0xFF28A745);

  // 그라데이션
  static const LinearGradient jejuOceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      emeraldLight,      // 얕은 바다
      emeraldSoft,       // 중간 바다
      emeraldBright,     // 깊은 바다
      emeraldDeep,       // 가장 깊은 바다
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient basaltGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      basaltSoft,
      basaltMedium,
      basaltDark,
    ],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      sunsetOrange,
      tangerineOrange,
    ],
  );

  // 배경 그라데이션 (현무암과 바다의 만남)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F4F8), // 하늘색 배경
      Color(0xFFF0F8FF), // 연한 바다색
      Color(0xFFF5F3F0), // 돌담 베이지
    ],
  );

  // 카드 그라데이션
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFCFCFC),
    ],
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: false,
      primaryColor: emeraldBright,
      scaffoldBackgroundColor: background,
      fontFamily: '.SF Pro Text',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Text',
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontFamily: '.SF Pro Text',
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: emeraldBright, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontFamily: '.SF Pro Text',
        ),
      ),
    );
  }
}