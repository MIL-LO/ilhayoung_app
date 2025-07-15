// lib/services/employer_dashboard_service.dart - 사업자 대시보드 서비스

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/auth_service.dart';

class EmployerDashboardService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // 현재 로그인한 매니저의 대시보드 데이터 조회
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'error': '인증 토큰이 없습니다.',
        };
      }

      final url = Uri.parse('$baseUrl/dashboard/employer');
      
      print('📡 매니저 대시보드 API 호출: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'], // 실제 데이터는 data 필드에 있음
        };
      } else {
        print('❌ HTTP 오류: ${response.statusCode}');
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 네트워크 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다.',
      };
    }
  }

  // 대시보드 요약 정보 조회
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'error': '인증 토큰이 없습니다.',
        };
      }

      final url = Uri.parse('$baseUrl/employer/dashboard/summary');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다.',
      };
    }
  }

  // 최근 활동 조회
  static Future<Map<String, dynamic>> getRecentActivities() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'error': '인증 토큰이 없습니다.',
        };
      }

      final url = Uri.parse('$baseUrl/employer/dashboard/activities');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다.',
      };
    }
  }

  // 오늘의 할 일 조회
  static Future<Map<String, dynamic>> getTodaysTasks() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        return {
          'success': false,
          'error': '인증 토큰이 없습니다.',
        };
      }

      final url = Uri.parse('$baseUrl/employer/dashboard/tasks');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다.',
      };
    }
  }
} 