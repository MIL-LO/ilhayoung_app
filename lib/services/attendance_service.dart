import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';
import 'work_schedule_service.dart';

enum CheckType {
  checkIn,
  checkOut,
}

enum WorkStatus {
  scheduled, // 예정
  present,   // 출근
  absent,    // 결근
  late,      // 지각
  completed, // 완료
}

class AttendanceService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // 체크인/체크아웃 처리 (deprecated - WorkScheduleService 사용 권장)
  static Future<Map<String, dynamic>> checkInOut({
    required CheckType checkType,
  }) async {
    print('⚠️ attendance_service.checkInOut은 deprecated입니다. WorkScheduleService.checkInNew() 또는 checkOutNew()를 사용하세요.');
    
    // WorkScheduleService로 리다이렉트
    if (checkType == CheckType.checkIn) {
      return await WorkScheduleService.checkInNew('');
    } else {
      return await WorkScheduleService.checkOutNew('');
    }
  }

  // 오늘 출근 상태 확인
  static Future<Map<String, dynamic>> getTodayAttendance() async {
    try {
      print('=== 오늘 출근 상태 확인 API 호출 ===');

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

      // 3. API 호출
      final response = await http.get(
        Uri.parse('$baseUrl/schedules/today'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      // 4. 응답 처리
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data['data']};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': '인증이 만료되었습니다. 다시 로그인해주세요.', 'errorType': 'AUTH'};
      } else if (response.statusCode == 404) {
        // 404는 오늘 스케줄이 없다는 의미 - 정상적인 응답으로 처리
        print('📅 404 응답 - 오늘 근무 스케줄이 없음');
        return {
          'success': true,
          'data': null,
          'message': '오늘은 근무일이 아닙니다.',
        };
      } else if (response.statusCode == 500) {
        // 500 에러도 data가 null인 경우 스케줄 없음으로 처리
        try {
          final responseData = json.decode(response.body);
          if (responseData['data'] == null) {
            print('📅 500 응답이지만 data가 null - 스케줄 없음으로 처리');
            return {
              'success': true,
              'data': null,
            };
          }
        } catch (e) {
          print('❌ 500 응답 파싱 실패: $e');
        }

        // 일반적인 500 에러 처리
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? '서버 내부 오류가 발생했습니다'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? '출근 상태 조회에 실패했습니다'};
      }
    } catch (e) {
      print('❌ 출근 상태 조회 오류: $e');
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  // 디버깅용: Auth 상태와 함께 체크
  static Future<Map<String, dynamic>> debugCheckAuthAndAPI() async {
    print('=== 🔧 Auth 상태 및 API 디버깅 ===');

    // 1. Auth 상태 전체 확인
    await AuthService.checkFullAuthStatus();

    // 2. API 호출 테스트
    final result = await getTodayAttendance();

    print('API 호출 결과: ${result['success'] ? "성공" : "실패 - ${result['error']}"}');
    print('============================');

    return result;
  }

  static String _getSuccessMessage(CheckType checkType, Map<String, dynamic>? data) {
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    switch (checkType) {
      case CheckType.checkIn:
        if (data != null && data['workStatus'] == 'LATE') {
          return '🌊 $timeString 지각 체크인 완료!';
        } else {
          return '🌊 $timeString 출근 완료! 오늘도 화이팅!';
        }
      case CheckType.checkOut:
        return '🌅 $timeString 퇴근 완료! 수고하셨습니다!';
    }
  }
}