// lib/services/work_schedule_service.dart - 정리된 근무 스케줄 API 서비스

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/work_schedule.dart';

class WorkScheduleService {
  static const String baseUrl = 'https://api.ilhayoung.com/api/v1';

  /// 내 근무 스케줄 조회
  static Future<Map<String, dynamic>> getMyWorkSchedules({
    int page = 0,
    int size = 100,
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    try {
      print('=== 근무 스케줄 조회 API 호출 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      // 쿼리 파라미터 구성
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (startDate != null) {
        queryParams['startDate'] = startDate;
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate;
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/work-schedules/my').replace(queryParameters: queryParams);
      print('API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS' && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          final content = data['content'] as List;

          // WorkSchedule 객체 리스트로 변환
          final List<WorkSchedule> schedules = [];
          for (var item in content) {
            try {
              schedules.add(WorkSchedule.fromJson(item));
            } catch (e) {
              print('WorkSchedule 변환 오류: $e');
              print('문제가 된 데이터: $item');
            }
          }

          return {
            'success': true,
            'data': schedules,
            'pagination': {
              'totalElements': data['totalElements'] ?? 0,
              'totalPages': data['totalPages'] ?? 0,
              'currentPage': data['number'] ?? 0,
              'pageSize': data['size'] ?? 0,
              'hasNext': !(data['last'] ?? true),
              'hasPrevious': !(data['first'] ?? false),
            },
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '근무 스케줄을 불러오는데 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 근무 스케줄 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 근무 스케줄 상세 조회
  static Future<Map<String, dynamic>> getWorkScheduleDetail(String scheduleId) async {
    try {
      print('=== 근무 스케줄 상세 조회 API 호출 ===');
      print('스케줄 ID: $scheduleId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/work-schedules/$scheduleId');
      print('API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '상세 정보를 불러오는데 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 근무 스케줄 상세 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 근무 스케줄 취소
  static Future<Map<String, dynamic>> cancelWorkSchedule(String scheduleId) async {
    try {
      print('=== 근무 스케줄 취소 API 호출 ===');
      print('스케줄 ID: $scheduleId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/work-schedules/$scheduleId/cancel');
      print('API URL: $uri');

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '근무 일정이 취소되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '근무 일정 취소에 실패했습니다',
          };
        }
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? '서버 오류가 발생했습니다 (${response.statusCode})';
        } catch (e) {
          errorMessage = '서버 오류가 발생했습니다 (${response.statusCode})';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ 근무 스케줄 취소 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 근무 완료 처리
  static Future<Map<String, dynamic>> completeWorkSchedule(String scheduleId) async {
    try {
      print('=== 근무 완료 처리 API 호출 ===');
      print('스케줄 ID: $scheduleId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/work-schedules/$scheduleId/complete');
      print('API URL: $uri');

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '근무가 완료되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '근무 완료 처리에 실패했습니다',
          };
        }
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? '서버 오류가 발생했습니다 (${response.statusCode})';
        } catch (e) {
          errorMessage = '서버 오류가 발생했습니다 (${response.statusCode})';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ 근무 완료 처리 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }
}