import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  static final String baseUrl = AppConfig.apiBaseUrl;

  // 월별 스케줄 조회 (달력용)
  static Future<Map<String, dynamic>> getMonthlySchedules(int year, int month) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/schedules?year=$year&month=$month');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.accessToken}',
        },
      );

      print('📅 월별 스케줄 조회 API 호출');
      print('URL: $url');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] as List;
        
        final schedules = data.map((item) => MonthlySchedule.fromJson(item)).toList();
        return {'success': true, 'data': schedules};
      } else {
        print('❌ 월별 스케줄 조회 실패: ${response.statusCode}');
        return {'success': false, 'error': '스케줄 조회에 실패했습니다.'};
      }
    } catch (e) {
      print('❌ 월별 스케줄 조회 예외: $e');
      return {'success': false, 'error': '네트워크 오류가 발생했습니다.'};
    }
  }

  // 스케줄 상세 정보 조회
  static Future<Map<String, dynamic>> getScheduleDetail(String scheduleId) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/schedules/$scheduleId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.accessToken}',
        },
      );

      print('📋 스케줄 상세 조회 API 호출');
      print('URL: $url');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];
        
        final scheduleDetail = ScheduleDetail.fromJson(data);
        return {'success': true, 'data': scheduleDetail};
      } else {
        print('❌ 스케줄 상세 조회 실패: ${response.statusCode}');
        return {'success': false, 'error': '스케줄 상세 조회에 실패했습니다.'};
      }
    } catch (e) {
      print('❌ 스케줄 상세 조회 예외: $e');
      return {'success': false, 'error': '네트워크 오류가 발생했습니다.'};
    }
  }

  // 오늘의 근무 스케줄 조회 (STAFF용)
  static Future<Map<String, dynamic>> getTodaySchedule() async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/schedules/today');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.accessToken}',
        },
      );

      print('📅 오늘의 근무 스케줄 조회 API 호출');
      print('URL: $url');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];
        
        final todaySchedule = TodaySchedule.fromJson(data);
        return {'success': true, 'data': todaySchedule};
      } else {
        print('❌ 오늘의 근무 스케줄 조회 실패: ${response.statusCode}');
        return {'success': false, 'error': '오늘의 근무 스케줄 조회에 실패했습니다.'};
      }
    } catch (e) {
      print('❌ 오늘의 근무 스케줄 조회 예외: $e');
      return {'success': false, 'error': '네트워크 오류가 발생했습니다.'};
    }
  }

  // 스케줄 상태 수정 (MANAGER용)
  static Future<Map<String, dynamic>> updateScheduleStatus(String scheduleId, String status) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/schedules/$scheduleId/status');
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.accessToken}',
        },
        body: json.encode({
          'status': status,
        }),
      );

      print('📝 스케줄 상태 수정 API 호출');
      print('URL: $url');
      print('상태: $status');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {'success': true, 'data': responseData['data']};
      } else {
        print('❌ 스케줄 상태 수정 실패: ${response.statusCode}');
        return {'success': false, 'error': '스케줄 상태 수정에 실패했습니다.'};
      }
    } catch (e) {
      print('❌ 스케줄 상태 수정 예외: $e');
      return {'success': false, 'error': '네트워크 오류가 발생했습니다.'};
    }
  }

  // 대체 근무자 정보 조회
  static Future<Map<String, dynamic>> getReplacementInfo(String scheduleId) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/schedules/$scheduleId/replacement-info');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.accessToken}',
        },
      );

      print('🔄 대체 근무자 정보 조회 API 호출');
      print('URL: $url');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];
        
        final replacementInfo = ReplacementInfo.fromJson(data);
        return {'success': true, 'data': replacementInfo};
      } else {
        print('❌ 대체 근무자 정보 조회 실패: ${response.statusCode}');
        return {'success': false, 'error': '대체 근무자 정보 조회에 실패했습니다.'};
      }
    } catch (e) {
      print('❌ 대체 근무자 정보 조회 예외: $e');
      return {'success': false, 'error': '네트워크 오류가 발생했습니다.'};
    }
  }

  // 지원서 승인 시 스케줄 자동 생성
  static Future<Map<String, dynamic>> createSchedulesFromApplication(String applicationId) async {
    try {
      final url = Uri.parse('$baseUrl/api/v1/schedules/applications/$applicationId');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.accessToken}',
        },
      );

      print('📅 지원서 승인 시 스케줄 생성 API 호출');
      print('URL: $url');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {'success': true, 'data': responseData['data']};
      } else {
        print('❌ 스케줄 생성 실패: ${response.statusCode}');
        return {'success': false, 'error': '스케줄 생성에 실패했습니다.'};
      }
    } catch (e) {
      print('❌ 스케줄 생성 예외: $e');
      return {'success': false, 'error': '네트워크 오류가 발생했습니다.'};
    }
  }
} 