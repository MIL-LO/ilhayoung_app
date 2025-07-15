// lib/services/worker_attendance_service.dart

import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class WorkerAttendanceService {
  static String get baseUrl => AppConfig.baseUrl;

  /// 전체 근로자 출석 현황 조회 (MANAGER)
  static Future<Map<String, dynamic>> getAttendanceOverview() async {
    try {
      print('=== 전체 근로자 출석 현황 조회 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/attendances/overview'),
        headers: {
          'Content-Type': 'application/json',
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
            'error': jsonResponse['message'] ?? '출석 현황 조회에 실패했습니다',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': '인증이 만료되었습니다. 다시 로그인해주세요.',
        };
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 출석 현황 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 특정 스태프 상세 정보 조회 (MANAGER/STAFF)
  static Future<Map<String, dynamic>> getStaffDetail(String staffId) async {
    try {
      print('=== 스태프 상세 정보 조회 ===');
      print('스태프 ID: $staffId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/attendances/staff/$staffId/detail'),
        headers: {
          'Content-Type': 'application/json',
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
            'error': jsonResponse['message'] ?? '스태프 정보 조회에 실패했습니다',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': '인증이 만료되었습니다. 다시 로그인해주세요.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': '해당 스태프를 찾을 수 없습니다',
        };
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 스태프 정보 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 스태프 근무 상태 수정 (MANAGER) - 실제 API에 맞게 수정
  static Future<Map<String, dynamic>> updateStaffStatus(
      String staffId,
      String status,
      ) async {
    try {
      print('=== 스태프 근무 상태 수정 ===');
      print('스태프 ID: $staffId');
      print('새로운 상태: $status');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      final requestBody = {
        'status': status,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/attendances/staff/$staffId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      print('요청 본문: $requestBody');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '상태가 변경되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '상태 변경에 실패했습니다',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': '인증이 만료되었습니다. 다시 로그인해주세요.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': '해당 스태프를 찾을 수 없습니다',
        };
      } else if (response.statusCode == 400) {
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'error': errorResponse['message'] ?? '잘못된 요청입니다',
        };
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 스태프 상태 변경 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 스태프 출근 처리 (MANAGER)
  static Future<Map<String, dynamic>> checkInStaff(String staffId) async {
    return await updateStaffStatus(staffId, 'PRESENT');
  }

  /// 스태프 퇴근 처리 (MANAGER)
  static Future<Map<String, dynamic>> checkOutStaff(String staffId) async {
    return await updateStaffStatus(staffId, 'COMPLETED');
  }

  /// 스태프 결근 처리 (MANAGER)
  static Future<Map<String, dynamic>> markAbsent(String staffId) async {
    return await updateStaffStatus(staffId, 'ABSENT');
  }

  /// 스태프 지각 처리 (MANAGER)
  static Future<Map<String, dynamic>> markLate(String staffId) async {
    return await updateStaffStatus(staffId, 'LATE');
  }

  /// 특정 날짜의 출석 현황 조회 (MANAGER)
  static Future<Map<String, dynamic>> getAttendanceByDate(String date) async {
    try {
      print('=== 특정 날짜 출석 현황 조회 ===');
      print('조회 날짜: $date');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/attendances/overview?date=$date'),
        headers: {
          'Content-Type': 'application/json',
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
            'error': jsonResponse['message'] ?? '출석 현황 조회에 실패했습니다',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': '인증이 만료되었습니다. 다시 로그인해주세요.',
        };
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 날짜별 출석 현황 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 출석 통계 조회 (MANAGER)
  static Future<Map<String, dynamic>> getAttendanceStatistics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      print('=== 출석 통계 조회 ===');
      print('시작일: $startDate, 종료일: $endDate');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      String url = '$baseUrl/api/v1/attendances/statistics';
      List<String> queryParams = [];

      if (startDate != null) {
        queryParams.add('startDate=$startDate');
      }
      if (endDate != null) {
        queryParams.add('endDate=$endDate');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('요청 URL: $url');
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
            'error': jsonResponse['message'] ?? '통계 조회에 실패했습니다',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': '인증이 만료되었습니다. 다시 로그인해주세요.',
        };
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 출석 통계 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 디버깅용: 현재 인증 상태 확인
  static Future<Map<String, dynamic>> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      print('=== 인증 상태 확인 ===');
      print('액세스 토큰 존재: ${accessToken != null}');
      if (accessToken != null) {
        print('토큰 길이: ${accessToken.length}');
        print('토큰 앞 10자리: ${accessToken.substring(0, math.min(10, accessToken.length))}...');
      }

      return {
        'success': true,
        'hasToken': accessToken != null,
        'tokenLength': accessToken?.length ?? 0,
      };
    } catch (e) {
      print('❌ 인증 상태 확인 실패: $e');
      return {
        'success': false,
        'error': '인증 상태 확인에 실패했습니다: $e',
      };
    }
  }
}