// lib/services/account_deletion_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AccountDeletionService {
  // 회원 탈퇴 API 호출
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      print('=== 회원 탈퇴 시작 ===');

      // 저장된 토큰 가져오기
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        print('액세스 토큰이 없습니다');
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      // API 요청
      final url = '${AppConfig.apiBaseUrl}/users';
      print('회원 탈퇴 요청 URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('회원 탈퇴 응답 상태: ${response.statusCode}');
      print('회원 탈퇴 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        // 성공: 모든 로컬 데이터 삭제
        await _clearAllLocalData();

        print('회원 탈퇴 성공');
        return {
          'success': true,
          'message': '회원 탈퇴가 완료되었습니다',
        };
      } else {
        // 실패
        String errorMessage = '회원 탈퇴에 실패했습니다';

        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          print('응답 파싱 오류: $e');
        }

        print('회원 탈퇴 실패: $errorMessage');
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('회원 탈퇴 네트워크 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다',
      };
    }
  }

  // 모든 로컬 데이터 삭제
  static Future<void> _clearAllLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 모든 사용자 관련 데이터 삭제
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_type');
      await prefs.remove('user_status');
      await prefs.remove('user_email');
      await prefs.remove('is_logged_in');

      // 또는 전체 삭제
      // await prefs.clear();

      print('모든 로컬 데이터 삭제 완료');
    } catch (e) {
      print('로컬 데이터 삭제 오류: $e');
    }
  }
}