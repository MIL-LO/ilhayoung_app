import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ManagerInfoService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// 사업자 정보 조회 (GET /api/v1/users/manager)
  static Future<Map<String, dynamic>?> getManagerInfo() async {
    try {
      print('=== 사업자 정보 조회 API 호출 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        print('❌ 액세스 토큰이 없습니다');
        return null;
      }

      final url = '$baseUrl/users/me';
      print('사업자 정보 조회 API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          print('✅ 사업자 정보 조회 성공');
          return jsonResponse['data'];
        } else {
          print('❌ 사업자 정보 조회 실패: ${jsonResponse['message']}');
          return null;
        }
      } else {
        print('❌ 사업자 정보 조회 HTTP 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ 사업자 정보 조회 예외: $e');
      return null;
    }
  }

  /// 사업자 정보 수정 (PATCH /api/v1/users/manager)
  static Future<Map<String, dynamic>> updateManagerInfo({
    required String phone,
    required String businessAddress,
    required String businessType,
  }) async {
    try {
      print('=== 사업자 정보 수정 API 호출 ===');
      print('수정 데이터: phone= [0m$phone, businessAddress=$businessAddress, businessType=$businessType');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final requestBody = {
        'phone': phone,
        'businessAddress': businessAddress,
        'businessType': businessType,
      };

      print('API 요청 데이터: $requestBody');

      final url = '$baseUrl/users/manager';
      print('API 호출 URL: $url');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          print('✅ 사업자 정보 수정 성공');
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '사업자 정보가 성공적으로 수정되었습니다.',
            'data': jsonResponse['data'],
          };
        } else {
          print('❌ API 오류: ${jsonResponse['message']}');
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '사업자 정보 수정에 실패했습니다.',
          };
        }
      } else {
        print('❌ HTTP 오류: ${response.statusCode}');

        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? 'HTTP ${response.statusCode}: 서버 오류가 발생했습니다';
        } catch (e) {
          errorMessage = 'HTTP ${response.statusCode}: 서버 오류가 발생했습니다';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ 사업자 정보 수정 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 전화번호 포맷팅 (하이픈 제거)
  static String formatPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// 전화번호 유효성 검사
  static bool isValidPhoneNumber(String phone) {
    // 010-XXXX-XXXX 형식 검증
    final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');        return phoneRegex.hasMatch(phone.trim());
  }

  /// 사업장 주소 유효성 검사
  static bool isValidBusinessAddress(String address) {
    return address.trim().length >= 5;
  }
}