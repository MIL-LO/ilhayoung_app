import 'package:flutter/material.dart';

class AppTheme {
  // iOS 스타일 컬러 팔레트
  static const Color primaryBlue = Color(0xFF007AFF);
  static const Color primaryOrange = Color(0xFFFF9500);
  static const Color primaryGreen = Color(0xFF34C759);
  static const Color background = Color(0xFFF2F2F7);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFF2F2F7);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color separator = Color(0xFFC6C6C8);
  static const Color systemRed = Color(0xFFFF3B30);

  // 제주 그라데이션 (iOS 스타일)
  static const LinearGradient jejuGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0F8FF), // 연한 하늘색
      Color(0xFFFFF8F0), // 연한 오렌지
      Color(0xFFF0FFF4), // 연한 초록
    ],
  );

  // 헤더 그라데이션 (더 부드럽게)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF007AFF),
      Color(0xFF5AC8FA),
      Color(0xFF34C759),
    ],
  );

  static ThemeData get iosTheme {
    return ThemeData(
      useMaterial3: false,
      primaryColor: primaryBlue,
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
            borderRadius: BorderRadius.circular(14),
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
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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