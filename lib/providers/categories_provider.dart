// lib/providers/categories_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// 직종 카테고리 목록
final List<String> jobCategories = [
  '카페/음료',
  '음식점/요리',
  '판매/마케팅',
  '관광/호텔',
  '농업/축산',
  '건설/인테리어',
  '운송/배송',
  '청소/정리',
  '행정/사무',
  '교육/강사',
  '의료/간호',
  '미용/뷰티',
  '운동/레저',
  'IT/개발',
  '디자인/예술',
  '기타',
];

// 직종 카테고리 Provider
final categoriesProvider = Provider<List<String>>((ref) {
  return jobCategories;
});

// 성별 요구사항 목록
final List<String> genderRequirements = [
  '무관',
  '남성',
  '여성',
];

// 성별 요구사항 Provider
final genderRequirementsProvider = Provider<List<String>>((ref) {
  return genderRequirements;
});

// 근무 기간 옵션 목록
final List<String> workPeriodOptions = [
  'ONE_TO_THREE',    // 1-3개월
  'THREE_TO_SIX',    // 3-6개월
  'SIX_TO_TWELVE',   // 6-12개월
  'OVER_TWELVE',     // 12개월 이상
];

// 근무 기간 Provider
final workPeriodOptionsProvider = Provider<List<String>>((ref) {
  return workPeriodOptions;
});

// 근무 요일 목록
final List<String> workDays = [
  '월',
  '화',
  '수',
  '목',
  '금',
  '토',
  '일',
];

// 근무 요일 Provider
final workDaysProvider = Provider<List<String>>((ref) {
  return workDays;
});

// 근무 기간 표시 텍스트 변환 함수
String getWorkPeriodDisplayText(String period) {
  switch (period) {
    case 'ONE_TO_THREE':
      return '1-3개월';
    case 'THREE_TO_SIX':
      return '3-6개월';
    case 'SIX_TO_TWELVE':
      return '6-12개월';
    case 'OVER_TWELVE':
      return '12개월 이상';
    default:
      return period;
  }
}

// 근무 기간 코드 변환 함수
String getWorkPeriodCode(String displayText) {
  switch (displayText) {
    case '1-3개월':
      return 'ONE_TO_THREE';
    case '3-6개월':
      return 'THREE_TO_SIX';
    case '6-12개월':
      return 'SIX_TO_TWELVE';
    case '12개월 이상':
      return 'OVER_TWELVE';
    default:
      return displayText;
  }
} 