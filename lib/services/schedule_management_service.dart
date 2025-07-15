// lib/services/schedule_management_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ScheduleManagementService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// 월별 스케줄 조회 (MANAGER/STAFF)
  static Future<Map<String, dynamic>> getMonthlySchedules({
    int? year,
    int? month,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      // API 문서에 따르면 year와 month 파라미터가 필수
      final currentDate = DateTime.now();
      final targetYear = year ?? currentDate.year;
      final targetMonth = month ?? currentDate.month;

      final url = '$baseUrl/schedules?year=$targetYear&month=$targetMonth';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'data': jsonResponse['data'] ?? [],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '스케줄 조회에 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 스케줄 상태 수정 (MANAGER)
  static Future<Map<String, dynamic>> updateScheduleStatus(
      String scheduleId,
      String status,
      ) async {
    try {
      print('=== 스케줄 상태 수정 ===');
      print('스케줄 ID: $scheduleId');
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
        Uri.parse('$baseUrl/schedules/$scheduleId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '스케줄 상태가 변경되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '상태 변경에 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 스케줄 생성 (MANAGER) - 바이트 배열 방식으로 완전 해결
  static Future<Map<String, dynamic>> createSchedule({
    required String staffId,
    required String jobId,
    required DateTime startTime,
    required DateTime endTime,
    required double hourlyRate,
    required String workLocation,
    String? notes,
  }) async {
    try {
      print('=== 스케줄 수동 생성 (BYTES) ===');
      print('스태프 ID: $staffId');
      print('작업 ID: $jobId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 🔧 가장 극단적인 방법: 바이트 배열로 JSON 생성
      // DateTime을 개별 부분으로 분해
      final startYear = startTime.year;
      final startMonth = startTime.month;
      final startDay = startTime.day;
      final startHour = startTime.hour;
      final startMinute = startTime.minute;

      final endYear = endTime.year;
      final endMonth = endTime.month;
      final endDay = endTime.day;
      final endHour = endTime.hour;
      final endMinute = endTime.minute;

      print('📅 시작 시간 부분들: $startYear-$startMonth-$startDay $startHour:$startMinute');
      print('📅 종료 시간 부분들: $endYear-$endMonth-$endDay $endHour:$endMinute');

      // 바이트 배열로 JSON 문자열 구성
      final buffer = <int>[];

      // {
      buffer.add(123); // {

      // "staffId":"
      buffer.addAll([34, 115, 116, 97, 102, 102, 73, 100, 34, 58, 34]); // "staffId":"
      buffer.addAll(utf8.encode(staffId));
      buffer.add(34); // "
      buffer.add(44); // ,

      // "jobId":"
      buffer.addAll([34, 106, 111, 98, 73, 100, 34, 58, 34]); // "jobId":"
      buffer.addAll(utf8.encode(jobId));
      buffer.add(34); // "
      buffer.add(44); // ,

      // "startTime":"YYYY-MM-DDTHH:MM:00.000"
      buffer.addAll([34, 115, 116, 97, 114, 116, 84, 105, 109, 101, 34, 58, 34]); // "startTime":"
      buffer.addAll(utf8.encode(startYear.toString()));
      buffer.add(45); // -
      buffer.addAll(utf8.encode(startMonth.toString().padLeft(2, '0')));
      buffer.add(45); // -
      buffer.addAll(utf8.encode(startDay.toString().padLeft(2, '0')));
      buffer.add(84); // T
      buffer.addAll(utf8.encode(startHour.toString().padLeft(2, '0')));
      buffer.add(58); // :
      buffer.addAll(utf8.encode(startMinute.toString().padLeft(2, '0')));
      buffer.addAll([58, 48, 48, 46, 48, 48, 48]); // :00.000
      buffer.add(34); // "
      buffer.add(44); // ,

      // "endTime":"YYYY-MM-DDTHH:MM:00.000"
      buffer.addAll([34, 101, 110, 100, 84, 105, 109, 101, 34, 58, 34]); // "endTime":"
      buffer.addAll(utf8.encode(endYear.toString()));
      buffer.add(45); // -
      buffer.addAll(utf8.encode(endMonth.toString().padLeft(2, '0')));
      buffer.add(45); // -
      buffer.addAll(utf8.encode(endDay.toString().padLeft(2, '0')));
      buffer.add(84); // T
      buffer.addAll(utf8.encode(endHour.toString().padLeft(2, '0')));
      buffer.add(58); // :
      buffer.addAll(utf8.encode(endMinute.toString().padLeft(2, '0')));
      buffer.addAll([58, 48, 48, 46, 48, 48, 48]); // :00.000
      buffer.add(34); // "
      buffer.add(44); // ,

      // "hourlyRate":10000.0,
      buffer.addAll([34, 104, 111, 117, 114, 108, 121, 82, 97, 116, 101, 34, 58]); // "hourlyRate":
      buffer.addAll(utf8.encode(hourlyRate.toString()));
      buffer.add(44); // ,

      // "status":"SCHEDULED",
      buffer.addAll([34, 115, 116, 97, 116, 117, 115, 34, 58, 34, 83, 67, 72, 69, 68, 85, 76, 69, 68, 34, 44]); // "status":"SCHEDULED",

      // "workLocation":"
      buffer.addAll([34, 119, 111, 114, 107, 76, 111, 99, 97, 116, 105, 111, 110, 34, 58, 34]); // "workLocation":"
      buffer.addAll(utf8.encode(workLocation));
      buffer.add(34); // "

      // }
      buffer.add(125); // }

      // 바이트 배열을 문자열로 변환
      final jsonBytes = Uint8List.fromList(buffer);
      final jsonString = utf8.decode(jsonBytes);

      print('🔧 바이트 배열로 생성된 JSON:');
      print(jsonString);

      // JSON 유효성 검증
      try {
        json.decode(jsonString);
        print('✅ 바이트 생성 JSON 유효성 검증 통과');
      } catch (e) {
        print('❌ 바이트 생성 JSON 유효성 검증 실패: $e');
        return {'success': false, 'error': 'JSON 생성 실패: $e'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/schedules'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonString,
      );

      print('바이트 방식 응답 상태: ${response.statusCode}');
      print('바이트 방식 응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'data': jsonResponse['data'],
            'message': '스케줄이 성공적으로 생성되었습니다 (바이트)',
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '스케줄 생성에 실패했습니다',
          };
        }
      } else {
        return _handleFailedResponse(response);
      }

    } catch (e) {
      print('❌ 스케줄 생성 중 오류: $e');
      return {
        'success': false,
        'error': '스케줄 생성 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 스케줄 생성 전 유효성 검증
  static Future<Map<String, dynamic>> validateScheduleCreation({
    required String staffId,
    required String jobId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      print('=== 스케줄 생성 전 유효성 검증 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      // 1. 월별 스케줄 조회로 기본 API 연결 테스트
      print('🔍 1. 기본 스케줄 조회 API 테스트');
      final scheduleResult = await getMonthlySchedules(year: 2025, month: 7);
      print('스케줄 조회 결과: ${scheduleResult['success']}');

      if (!scheduleResult['success']) {
        return {
          'success': false,
          'error': '기본 스케줄 API 연결 실패: ${scheduleResult['error']}'
        };
      }

      // 2. 특정 직원의 기존 스케줄 확인
      print('🔍 2. 해당 직원의 기존 스케줄 확인');
      final existingSchedules = scheduleResult['data'] as List? ?? [];
      final staffSchedules = existingSchedules.where((schedule) =>
      schedule['staffId'] == staffId
      ).toList();

      print('해당 직원의 기존 스케줄 개수: ${staffSchedules.length}');

      // 3. 시간 중복 확인
      final startTimeStr = startTime.toIso8601String();
      final endTimeStr = endTime.toIso8601String();

      final hasConflict = staffSchedules.any((schedule) {
        final scheduleStart = schedule['startTime'] as String?;
        final scheduleEnd = schedule['endTime'] as String?;

        if (scheduleStart == null || scheduleEnd == null) return false;

        // 시간 중복 로직 (단순 문자열 비교)
        return (startTimeStr.compareTo(scheduleEnd) < 0 &&
            endTimeStr.compareTo(scheduleStart) > 0);
      });

      if (hasConflict) {
        print('❌ 시간 중복 발견');
        return {
          'success': false,
          'error': '해당 시간대에 이미 스케줄이 존재합니다'
        };
      }

      // 4. 간단한 테스트 데이터로 스케줄 생성 시도
      print('🔍 3. 간단한 테스트 데이터로 생성 시도');
      return await _createTestSchedule(staffId, jobId, accessToken);

    } catch (e) {
      return {
        'success': false,
        'error': '유효성 검증 중 오류: $e'
      };
    }
  }

  /// 간단한 테스트 데이터로 스케줄 생성 시도
  static Future<Map<String, dynamic>> _createTestSchedule(
      String staffId,
      String jobId,
      String accessToken
      ) async {
    try {
      // 매우 간단한 JSON으로 테스트
      final simpleJson = '''
{
  "staffId": "$staffId",
  "jobId": "$jobId",
  "startTime": "2025-07-15T09:00:00.000",
  "endTime": "2025-07-15T10:00:00.000",
  "hourlyRate": 12000.0,
  "status": "SCHEDULED",
  "workLocation": "테스트"
}''';

      print('🧪 테스트 JSON:');
      print(simpleJson);

      final response = await http.post(
        Uri.parse('$baseUrl/schedules'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: simpleJson,
      );

      print('테스트 응답 상태: ${response.statusCode}');
      print('테스트 응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': '테스트 스케줄 생성 성공! 원본 데이터 문제일 수 있음'
        };
      } else if (response.statusCode == 400) {
        try {
          final errorJson = json.decode(response.body);
          return {
            'success': false,
            'error': '요청 데이터 문제: ${errorJson['message'] ?? '알 수 없는 400 오류'}'
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'HTTP 400: 잘못된 요청 형식'
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': '인증 오류: 로그인이 만료되었거나 권한이 없습니다'
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': '권한 오류: 해당 직원에 대한 스케줄 생성 권한이 없습니다'
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: 서버 오류'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '테스트 생성 중 오류: $e'
      };
    }
  }



  /// 실패한 응답 처리
  static Map<String, dynamic> _handleFailedResponse(http.Response response) {
    try {
      final errorJson = json.decode(response.body);
      final errorMessage = errorJson['message'] ?? errorJson['error'] ?? '알 수 없는 오류';

      print('❌ 모든 방식 실패 - 상태: ${response.statusCode}');
      print('❌ 에러 메시지: $errorMessage');

      return {
        'success': false,
        'error': '스케줄 생성 실패 (${response.statusCode}): $errorMessage',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'HTTP ${response.statusCode}: 서버 오류가 발생했습니다',
      };
    }
  }

  /// 지원서 승인 시 스케줄 자동 생성 (MANAGER)
  static Future<Map<String, dynamic>> createScheduleFromApplication(
      String applicationId, {
        required DateTime startDate,
        DateTime? endDate,
        required double hourlyRate,
        String? workLocation,
        Map<String, dynamic>? additionalInfo,
      }) async {
    try {
      print('=== 지원서 승인 시 스케줄 자동 생성 ===');
      print('지원서 ID: $applicationId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      final requestBody = {
        'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        'hourlyRate': hourlyRate,
        if (workLocation != null && workLocation.isNotEmpty) 'workLocation': workLocation,
        if (additionalInfo != null) ...additionalInfo,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/schedules/applications/$applicationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '스케줄이 생성되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '스케줄 생성에 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 편의 메서드들
  static Future<Map<String, dynamic>> startSchedule(String scheduleId) async {
    return await updateScheduleStatus(scheduleId, 'IN_PROGRESS');
  }

  static Future<Map<String, dynamic>> completeSchedule(String scheduleId) async {
    return await updateScheduleStatus(scheduleId, 'COMPLETED');
  }

  static Future<Map<String, dynamic>> cancelSchedule(String scheduleId) async {
    return await updateScheduleStatus(scheduleId, 'CANCELLED');
  }

  static Future<Map<String, dynamic>> restoreSchedule(String scheduleId) async {
    return await updateScheduleStatus(scheduleId, 'SCHEDULED');
  }
}