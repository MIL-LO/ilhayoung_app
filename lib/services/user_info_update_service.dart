// lib/services/user_info_update_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class UserInfoUpdateService {
  /// STAFF 정보 수정 API
  static Future<Map<String, dynamic>> updateStaffInfo({
    required String phone,
    required String address,
    required String experience,
  }) async {
    try {
      print('=== STAFF 정보 수정 시작 ===');
      print('Phone: $phone');
      print('Address: $address');
      print('Experience: $experience');

      // 액세스 토큰 가져오기
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return {
          'success': false,
          'error': '인증 토큰이 없습니다. 다시 로그인해주세요.',
        };
      }

      // API 엔드포인트
      final url = Uri.parse('${AppConfig.apiBaseUrl}/users/staff');
      print('정보 수정 API URL: $url');

      // 요청 본문
      final requestBody = {
        'phone': phone,
        'address': address,
        'experience': experience,
      };

      print('요청 본문: $requestBody');

      // API 호출
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      print('정보 수정 응답 상태: ${response.statusCode}');
      print('정보 수정 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['code'] == 'SUCCESS') {
          print('✅ STAFF 정보 수정 성공');
          return {
            'success': true,
            'message': responseData['message'] ?? '정보가 성공적으로 수정되었습니다.',
            'data': {
              'phone': phone,
              'address': address,
              'experience': experience,
              'updatedAt': DateTime.now().toIso8601String(), // 🔥 수정 시간 추가
            },
          };
        } else {
          print('❌ API 응답 오류: ${responseData['message']}');
          return {
            'success': false,
            'error': responseData['message'] ?? '정보 수정에 실패했습니다.',
          };
        }
      } else {
        print('❌ HTTP 오류: ${response.statusCode}');
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: 서버 오류가 발생했습니다.',
        };
      }

    } catch (e) {
      print('❌ STAFF 정보 수정 네트워크 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 입력값 유효성 검사
  static Map<String, String?> validateStaffInfo({
    required String phone,
    required String address,
    required String experience,
  }) {
    Map<String, String?> errors = {};

    // 전화번호 유효성 검사
    if (phone.trim().isEmpty) {
      errors['phone'] = '전화번호를 입력해주세요.';
    } else if (!RegExp(r'^010-\d{4}-\d{4}$').hasMatch(phone.trim())) {
      errors['phone'] = '올바른 전화번호 형식이 아닙니다. (예: 010-1234-5678)';
    }

    // 주소 유효성 검사
    if (address.trim().isEmpty) {
      errors['address'] = '주소를 입력해주세요.';
    } else if (address.trim().length < 5) {
      errors['address'] = '주소를 더 자세히 입력해주세요.';
    }

    // 경험 유효성 검사
    if (experience.trim().isEmpty) {
      errors['experience'] = '경험을 입력해주세요.';
    } else if (experience.trim().length < 2) {
      errors['experience'] = '경험을 더 자세히 입력해주세요.';
    }

    return errors;
  }

  /// 전화번호 포맷 자동 변환
  static String formatPhoneNumber(String input) {
    // 숫자만 추출
    String numbers = input.replaceAll(RegExp(r'[^0-9]'), '');

    // 010으로 시작하는 11자리 번호만 처리
    if (numbers.length == 11 && numbers.startsWith('010')) {
      return '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7)}';
    }

    return input; // 형식이 맞지 않으면 원본 반환
  }
}