// lib/services/user_info_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoService {
  static const String baseUrl = 'https://ilhayoung.com/api/v1';

  /// 현재 사용자 정보 조회
  static Future<Map<String, dynamic>> getCurrentUserInfo() async {
    print('=== 사용자 정보 조회 시작 ===');

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      print('액세스 토큰: ${accessToken?.substring(0, 20)}...');

      if (accessToken == null) {
        print('❌ 액세스 토큰이 없습니다');
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      // API 호출
      final url = '$baseUrl/users/me';
      print('사용자 정보 조회 API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('사용자 정보 조회 응답 상태: ${response.statusCode}');
      print('사용자 정보 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ 사용자 정보 조회 성공');

        return {
          'success': true,
          'data': data['data'], // API 응답에서 data 필드 추출
        };

      } else {
        print('❌ 사용자 정보 조회 실패: ${response.statusCode}');

        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? '사용자 정보를 불러올 수 없습니다';
        } catch (e) {
          errorMessage = '사용자 정보 조회에 실패했습니다 (${response.statusCode})';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }

    } catch (e) {
      print('❌ 사용자 정보 조회 중 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }
}