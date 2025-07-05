// lib/services/signup_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class SignupService {
  static const String baseUrl = 'https://ilhayoung.com/api/v1';

  /// STAFF 회원가입 완료
  static Future<Map<String, dynamic>> completeStaffSignup({
    required String birthDate, // "1998-07-01" 형식
    required String phone,     // "010-1234-5678" 형식
    required String address,   // "제주시 애월읍"
    required String experience, // "한식 주방 홀 아르바이트 3개월"
  }) async {
    print('=== STAFF 회원가입 완료 시작 ===');

    try {
      final prefs = await SharedPreferences.getInstance();
      final tempToken = prefs.getString('access_token'); // OAuth에서 받은 임시 토큰

      print('임시 토큰: ${tempToken?.substring(0, 20)}...');

      if (tempToken == null) {
        print('❌ 임시 토큰이 없습니다');
        return {'success': false, 'error': '임시 토큰이 없습니다. 다시 로그인해주세요.'};
      }

      // 백엔드 API 스펙에 맞는 요청 데이터
      final requestData = {
        'birthDate': birthDate,   // "1998-07-01"
        'phone': phone,           // "010-1234-5678"
        'address': address,       // "제주시 애월읍"
        'experience': experience, // "한식 주방 홀 아르바이트 3개월"
      };

      print('STAFF 회원가입 요청 데이터: ${jsonEncode(requestData)}');

      // 실제 백엔드 API 엔드포인트
      final url = '$baseUrl/users/staff/signup';
      print('STAFF 회원가입 API URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tempToken',
        },
        body: jsonEncode(requestData),
      );

      print('STAFF 회원가입 응답 상태: ${response.statusCode}');
      print('STAFF 회원가입 응답 헤더: ${response.headers}');
      print('STAFF 회원가입 응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ STAFF 회원가입 성공');

        // 새로운 토큰이 있다면 저장
        if (data['access_token'] != null || data['accessToken'] != null) {
          final newToken = data['access_token'] ?? data['accessToken'];
          await prefs.setString('access_token', newToken);
          print('✅ 새로운 액세스 토큰 저장됨');
        }

        if (data['refresh_token'] != null || data['refreshToken'] != null) {
          final refreshToken = data['refresh_token'] ?? data['refreshToken'];
          await prefs.setString('refresh_token', refreshToken);
          print('✅ 리프레시 토큰 저장됨');
        }

        // 사용자 상태 업데이트 (PENDING -> ACTIVE)
        if (data['status'] != null) {
          await prefs.setString('user_status', data['status']);
          print('✅ 사용자 상태 업데이트: ${data['status']}');
        } else {
          // 회원가입 성공 시 상태를 ACTIVE로 가정
          await prefs.setString('user_status', 'ACTIVE');
          print('✅ 사용자 상태를 ACTIVE로 설정');
        }

        return {
          'success': true,
          'data': data,
          'message': 'STAFF 회원가입이 완료되었습니다!'
        };

      } else {
        print('❌ STAFF 회원가입 실패: ${response.statusCode}');
        print('❌ 오류 내용: ${response.body}');

        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? 'STAFF 회원가입에 실패했습니다';
        } catch (e) {
          errorMessage = 'STAFF 회원가입에 실패했습니다 (${response.statusCode})';
        }

        return {
          'success': false,
          'error': errorMessage,
          'details': response.body
        };
      }

    } catch (e) {
      print('❌ STAFF 회원가입 처리 중 오류: $e');
      return {
        'success': false,
        'error': '회원가입 처리 중 네트워크 오류가 발생했습니다: $e'
      };
    }
  }

  /// 현재 사용자 상태 확인
  static Future<String?> getCurrentUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_status');
    } catch (e) {
      print('사용자 상태 확인 오류: $e');
      return null;
    }
  }

  /// 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final userStatus = prefs.getString('user_status');

      // 토큰이 있고 상태가 ACTIVE인 경우만 로그인으로 간주
      return accessToken != null && userStatus == 'ACTIVE';
    } catch (e) {
      print('로그인 상태 확인 오류: $e');
      return false;
    }
  }

  /// 회원가입이 필요한지 확인
  static Future<bool> needsSignup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final userStatus = prefs.getString('user_status');

      // 토큰은 있지만 상태가 PENDING인 경우 회원가입 필요
      return accessToken != null && userStatus == 'PENDING';
    } catch (e) {
      print('회원가입 필요 확인 오류: $e');
      return false;
    }
  }
}