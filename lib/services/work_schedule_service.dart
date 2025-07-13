// lib/services/work_schedule_service.dart - 수정된 버전

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/work_schedule.dart';
import 'auth_service.dart';

class WorkScheduleService {
  static const String baseUrl = 'https://api.ilhayoung.com/api/v1';

  // 🔧 추가: v1 없는 베이스 URL도 시도
  static const String baseUrlWithoutV1 = 'https://api.ilhayoung.com/api';

  // 월별 근무 스케줄 조회 - 다양한 방식 시도
  static Future<Map<String, dynamic>> getMonthlySchedules({
    required int year,
    required int month,
  }) async {
    print('=== 월별 근무 스케줄 API 호출 (개선된 버전) ===');
    print('년도: $year, 월: $month');

    // 1. 로그인 상태 먼저 확인
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      print('❌ 로그인 상태가 아님');
      return {'success': false, 'error': '로그인이 필요합니다', 'errorType': 'AUTH'};
    }

    // 2. 액세스 토큰 가져오기
    final token = await AuthService.getAccessToken();
    if (token == null) {
      print('❌ 액세스 토큰 없음');
      return {'success': false, 'error': '인증 토큰이 없습니다', 'errorType': 'AUTH'};
    }

    print('✅ 인증 확인 완료');

    // 🔧 방법 1: 파라미터 없이 모든 스케줄 조회 후 클라이언트에서 필터링
    try {
      print('🔄 방법 1: 파라미터 없이 전체 스케줄 조회 시도');

      final response1 = await http.get(
        Uri.parse('$baseUrl/schedules'),  // 파라미터 없이
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('방법 1 응답 상태: ${response1.statusCode}');
      print('방법 1 응답 본문: ${response1.body}');

      if (response1.statusCode == 200) {
        final responseData = json.decode(response1.body);

        if (responseData['code'] == 'SUCCESS' && responseData['data'] != null) {
          final allSchedules = (responseData['data'] as List? ?? [])
              .map((item) => WorkSchedule.fromJson(item))
              .toList();

          // 클라이언트에서 월별 필터링
          final filteredSchedules = allSchedules.where((schedule) {
            return schedule.date.year == year && schedule.date.month == month;
          }).toList();

          print('✅ 방법 1 성공: 전체 ${allSchedules.length}개, 필터링 후 ${filteredSchedules.length}개');
          return {'success': true, 'data': filteredSchedules};
        }
      }
    } catch (e) {
      print('❌ 방법 1 실패: $e');
    }

    // 🔧 방법 2: YYYY-MM 형식으로 month 파라미터 전송
    try {
      print('🔄 방법 2: YYYY-MM 형식 파라미터 시도');

      final monthParam = '$year-${month.toString().padLeft(2, '0')}';
      final response2 = await http.get(
        Uri.parse('$baseUrl/schedules?month=$monthParam'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('방법 2 URL: $baseUrl/schedules?month=$monthParam');
      print('방법 2 응답 상태: ${response2.statusCode}');
      print('방법 2 응답 본문: ${response2.body}');

      if (response2.statusCode == 200) {
        final responseData = json.decode(response2.body);

        if (responseData['code'] == 'SUCCESS' && responseData['data'] != null) {
          final schedules = (responseData['data'] as List? ?? [])
              .map((item) => WorkSchedule.fromJson(item))
              .toList();

          print('✅ 방법 2 성공: ${schedules.length}개 스케줄');
          return {'success': true, 'data': schedules};
        }
      }
    } catch (e) {
      print('❌ 방법 2 실패: $e');
    }

    // 🔧 방법 3: 기존 방식 (year, month 개별 파라미터)
    try {
      print('🔄 방법 3: 기존 year, month 파라미터 시도');

      final response3 = await http.get(
        Uri.parse('$baseUrl/schedules?year=$year&month=$month'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('방법 3 응답 상태: ${response3.statusCode}');
      print('방법 3 응답 본문: ${response3.body}');

      if (response3.statusCode == 200) {
        final responseData = json.decode(response3.body);

        if (responseData['code'] == 'SUCCESS' && responseData['data'] != null) {
          final schedules = (responseData['data'] as List? ?? [])
              .map((item) => WorkSchedule.fromJson(item))
              .toList();

          print('✅ 방법 3 성공: ${schedules.length}개 스케줄');
          return {'success': true, 'data': schedules};
        }
      } else if (response3.statusCode == 500) {
        // 500 에러 상세 분석
        try {
          final errorData = json.decode(response3.body);
          print('❌ 방법 3 서버 에러 상세: ${errorData['message']}');
        } catch (e) {
          print('❌ 방법 3 에러 파싱 실패: $e');
        }
      }
    } catch (e) {
      print('❌ 방법 3 실패: $e');
    }

    // 🔧 방법 4: 날짜 범위로 조회
    try {
      print('🔄 방법 4: 날짜 범위 파라미터 시도');

      final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
      final lastDay = DateTime(year, month + 1, 0).day;
      final endDate = '$year-${month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';

      final response4 = await http.get(
        Uri.parse('$baseUrl/schedules?startDate=$startDate&endDate=$endDate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('방법 4 URL: $baseUrl/schedules?startDate=$startDate&endDate=$endDate');
      print('방법 4 응답 상태: ${response4.statusCode}');
      print('방법 4 응답 본문: ${response4.body}');

      if (response4.statusCode == 200) {
        final responseData = json.decode(response4.body);

        if (responseData['code'] == 'SUCCESS' && responseData['data'] != null) {
          final schedules = (responseData['data'] as List? ?? [])
              .map((item) => WorkSchedule.fromJson(item))
              .toList();

          print('✅ 방법 4 성공: ${schedules.length}개 스케줄');
          return {'success': true, 'data': schedules};
        }
      }
    } catch (e) {
      print('❌ 방법 4 실패: $e');
    }

    // 🔧 방법 5: v1 없는 URL로 시도 (API 명세서와 동일)
    try {
      print('🔄 방법 5: v1 없는 URL로 시도');

      final response5 = await http.get(
        Uri.parse('$baseUrlWithoutV1/schedules'),  // v1 제거
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('방법 5 URL: $baseUrlWithoutV1/schedules');
      print('방법 5 응답 상태: ${response5.statusCode}');
      print('방법 5 응답 본문: ${response5.body}');

      if (response5.statusCode == 200) {
        final responseData = json.decode(response5.body);

        if (responseData['code'] == 'SUCCESS' && responseData['data'] != null) {
          final allSchedules = (responseData['data'] as List? ?? [])
              .map((item) => WorkSchedule.fromJson(item))
              .toList();

          // 클라이언트에서 월별 필터링
          final filteredSchedules = allSchedules.where((schedule) {
            return schedule.date.year == year && schedule.date.month == month;
          }).toList();

          print('✅ 방법 5 성공: 전체 ${allSchedules.length}개, 필터링 후 ${filteredSchedules.length}개');
          return {'success': true, 'data': filteredSchedules};
        }
      }
    } catch (e) {
      print('❌ 방법 5 실패: $e');
    }
    print('❌ 모든 방법 실패 - 빈 배열 반환');
    return {
      'success': true,
      'data': <WorkSchedule>[],
      'message': '스케줄 데이터를 불러올 수 없습니다. 서버 문제일 수 있습니다.'
    };
  }

  // 오늘의 근무 스케줄 조회 - 개선된 버전
  static Future<Map<String, dynamic>> getTodaySchedules() async {
    try {
      print('=== 오늘 근무 스케줄 API 호출 (개선된 버전) ===');

      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        return {'success': false, 'error': '로그인이 필요합니다', 'errorType': 'AUTH'};
      }

      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {'success': false, 'error': '인증 토큰이 없습니다', 'errorType': 'AUTH'};
      }

      // 방법 1: /schedules/today 엔드포인트
      try {
        print('🔄 오늘 스케줄 방법 1: /schedules/today');

        final response = await http.get(
          Uri.parse('$baseUrl/schedules/today'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('오늘 스케줄 응답 상태: ${response.statusCode}');
        print('오늘 스케줄 응답 본문: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          if (responseData['code'] == 'SUCCESS' && responseData['data'] != null) {
            final schedules = (responseData['data'] as List? ?? [])
                .map((item) => WorkSchedule.fromJson(item))
                .toList();

            print('✅ 오늘 스케줄 방법 1 성공: ${schedules.length}개');
            return {'success': true, 'data': schedules};
          }
        } else if (response.statusCode == 500) {
          print('❌ 오늘 스케줄 500 에러 - 방법 2 시도');
        }
      } catch (e) {
        print('❌ 오늘 스케줄 방법 1 실패: $e');
      }

      // 방법 2: 전체 스케줄에서 오늘 날짜 필터링
      print('🔄 오늘 스케줄 방법 2: 전체 스케줄에서 필터링');

      final now = DateTime.now();
      final monthlyResult = await getMonthlySchedules(year: now.year, month: now.month);

      if (monthlyResult['success']) {
        final allSchedules = monthlyResult['data'] as List<WorkSchedule>;
        final todaySchedules = allSchedules.where((schedule) {
          return schedule.date.year == now.year &&
              schedule.date.month == now.month &&
              schedule.date.day == now.day;
        }).toList();

        print('✅ 오늘 스케줄 방법 2 성공: ${todaySchedules.length}개');
        return {'success': true, 'data': todaySchedules};
      }

      return {'success': true, 'data': <WorkSchedule>[]};
    } catch (e) {
      print('❌ 오늘 스케줄 조회 오류: $e');
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  // 기존 메서드들은 그대로 유지...
  static Future<Map<String, dynamic>> getScheduleDetail(String scheduleId) async {
    // 기존 코드 유지
    try {
      print('=== 스케줄 상세 정보 API 호출 ===');
      print('스케줄 ID: $scheduleId');

      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        return {'success': false, 'error': '로그인이 필요합니다', 'errorType': 'AUTH'};
      }

      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {'success': false, 'error': '인증 토큰이 없습니다', 'errorType': 'AUTH'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/schedules/$scheduleId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final schedule = WorkSchedule.fromJson(responseData['data']);
        return {'success': true, 'data': schedule};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? '스케줄 조회 실패'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkIn(String scheduleId) async {
    // 기존 체크인 코드 유지
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {'success': false, 'error': '인증 토큰이 없습니다'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/schedules/$scheduleId/checkin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'checkInTime': DateTime.now().toIso8601String()}),
      );

      if (response.statusCode == 200) {
        final now = DateTime.now();
        final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        return {
          'success': true,
          'message': '🌊 $timeString 출근 체크인 완료!',
        };
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? '체크인 실패'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkOut(String scheduleId) async {
    // 기존 체크아웃 코드 유지
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {'success': false, 'error': '인증 토큰이 없습니다'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/schedules/$scheduleId/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'checkOutTime': DateTime.now().toIso8601String()}),
      );

      if (response.statusCode == 200) {
        final now = DateTime.now();
        final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        return {
          'success': true,
          'message': '🌅 $timeString 퇴근 체크아웃 완료!',
        };
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? '체크아웃 실패'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }
}