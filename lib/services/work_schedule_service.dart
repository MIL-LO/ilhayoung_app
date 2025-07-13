// lib/services/work_schedule_service.dart - API 연동 버전

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/auth_service.dart';

class WorkScheduleService {

  /// 🎯 API: 월별 스케줄 조회 (/schedules - v1 제거)
  static Future<Map<String, dynamic>> getSchedulesByMonth({
    required int year,
    required int month,
  }) async {
    try {
      print('=== 📅 /schedules API 호출 (v1 제거) ===');
      print('요청 파라미터: year=$year, month=$month');

      // 인증 토큰 가져오기
      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'error': '인증 토큰이 없습니다. 다시 로그인해주세요.',
        };
      }

      // API 호출 (/api/schedules - v1만 제거)
      final url = Uri.parse('https://api.ilhayoung.com/api/schedules').replace(
        queryParameters: {
          'year': year.toString(),
          'month': month.toString(),
        },
      );

      print('API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('응답 상태: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return {
          'success': true,
          'data': data['data'] ?? [], // 스케줄 배열
          'message': data['message'] ?? '스케줄 조회 성공',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': '인증이 만료되었습니다. 다시 로그인해주세요.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': true,
          'data': [], // 스케줄이 없는 경우 빈 배열 반환
          'message': '해당 월에 스케줄이 없습니다.',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? '스케줄 조회에 실패했습니다.',
        };
      }
    } catch (e) {
      print('❌ /schedules API 호출 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 기존 메서드: 월별 스케줄 조회 (호환성 유지)
  static Future<Map<String, dynamic>> getMonthlySchedules({
    required int year,
    required int month,
  }) async {
    // 새로운 API로 리다이렉트
    return await getSchedulesByMonth(year: year, month: month);
  }

  /// 체크인/체크아웃 API (실제 사용하는 엔드포인트)
  static Future<Map<String, dynamic>> checkInOut({
    required int scheduleId,
    required String checkType, // 'CHECK_IN' 또는 'CHECK_OUT'
  }) async {
    try {
      print('=== 📍 체크인/아웃 API 호출 ===');
      print('스케줄 ID: $scheduleId');
      print('체크 타입: $checkType');

      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'error': '인증 토큰이 없습니다.',
        };
      }

      final requestBody = {
        'scheduleId': scheduleId,
        'checkType': checkType,
      };

      final response = await http.post(
        Uri.parse('https://api.ilhayoung.com/api/attendances/check-in-out'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('체크인/아웃 응답: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? '체크${checkType == 'CHECK_IN' ? '인' : '아웃'}이 완료되었습니다.',
          'data': data['data'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? '체크${checkType == 'CHECK_IN' ? '인' : '아웃'}에 실패했습니다.',
        };
      }
    } catch (e) {
      print('❌ 체크인/아웃 API 오류: $e');
      return {
        'success': false,
        'error': '체크${checkType == 'CHECK_IN' ? '인' : '아웃'} 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 체크인 API (새로운 엔드포인트 사용)
  static Future<Map<String, dynamic>> checkInNew(int scheduleId) async {
    return await checkInOut(scheduleId: scheduleId, checkType: 'CHECK_IN');
  }

  /// 체크아웃 API (새로운 엔드포인트 사용)
  static Future<Map<String, dynamic>> checkOutNew(int scheduleId) async {
    return await checkInOut(scheduleId: scheduleId, checkType: 'CHECK_OUT');
  }

  /// 스케줄 상세 조회 API
  static Future<Map<String, dynamic>> getScheduleDetail(int scheduleId) async {
    try {
      print('=== 📋 스케줄 상세 조회 API 호출 ===');
      print('스케줄 ID: $scheduleId');

      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'error': '인증 토큰이 없습니다.',
        };
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/schedules/$scheduleId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('스케줄 상세 응답: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': '스케줄 상세 조회 성공',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? '스케줄 상세 조회에 실패했습니다.',
        };
      }
    } catch (e) {
      print('❌ 스케줄 상세 조회 오류: $e');
      return {
        'success': false,
        'error': '스케줄 상세 조회 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 오늘의 스케줄 조회 API
  static Future<Map<String, dynamic>> getTodaySchedules() async {
    final now = DateTime.now();
    return await getSchedulesByMonth(
      year: now.year,
      month: now.month,
    );
  }

  /// 다가오는 스케줄 조회 API
  static Future<Map<String, dynamic>> getUpcomingSchedules({int days = 7}) async {
    try {
      print('=== 🔜 다가오는 스케줄 조회 ===');

      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'error': '인증 토큰이 없습니다.',
        };
      }

      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/schedules/upcoming?days=$days'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
          'message': '다가오는 스케줄 조회 성공',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? '다가오는 스케줄 조회에 실패했습니다.',
        };
      }
    } catch (e) {
      print('❌ 다가오는 스케줄 조회 오류: $e');
      return {
        'success': false,
        'error': '다가오는 스케줄 조회 중 오류가 발생했습니다: $e',
      };
    }
  }
}