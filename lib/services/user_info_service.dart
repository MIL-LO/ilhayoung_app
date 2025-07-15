// lib/services/user_info_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoService {
  static const String baseUrl = 'https://api.ilhayoung.com/api/v1';

  /// 🎯 MyPageScreen용 사용자 정보 조회 (간단한 null 반환)
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      print('=== MyPageScreen 사용자 정보 로드 시작 ===');

      final result = await getCurrentUserInfo();

      if (result['success'] == true && result['data'] != null) {
        print('✅ getUserInfo 성공: ${result['data']['name']}');
        return result['data'] as Map<String, dynamic>;
      } else {
        print('❌ getUserInfo 실패: ${result['error']}');
        return null;
      }
    } catch (e) {
      print('❌ getUserInfo 예외: $e');
      return null;
    }
  }

  /// 🎯 특정 사용자 ID로 정보 조회 (고용된 직원 정보용)
  static Future<Map<String, dynamic>?> getUserInfoById(String userId) async {
    try {
      print('=== 특정 사용자 정보 조회 시작 ===');
      print('사용자 ID: $userId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        print('❌ 액세스 토큰이 없습니다');
        return null;
      }

      // API 호출
      final url = '$baseUrl/users/$userId';
      print('특정 사용자 정보 조회 API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('특정 사용자 정보 조회 응답 상태: ${response.statusCode}');
      print('특정 사용자 정보 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ 특정 사용자 정보 조회 성공');

        return {
          'success': true,
          'data': data['data'], // API 응답에서 data 필드 추출
        };

      } else {
        print('❌ 특정 사용자 정보 조회 실패: ${response.statusCode}');

        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? '사용자 정보를 불러올 수 없습니다';
        } catch (e) {
          errorMessage = '사용자 정보 조회에 실패했습니다 (${response.statusCode})';
        }

        return null;
      }

    } catch (e) {
      print('❌ 특정 사용자 정보 조회 중 오류: $e');
      return null;
    }
  }

  /// 🎯 UserInfoScreen용 사용자 정보 조회 (Exception 기반)
  static Future<Map<String, dynamic>> fetchUserInfo() async {
    try {
      print('=== UserInfoScreen 사용자 정보 조회 시작 ===');

      final result = await getCurrentUserInfo();

      if (result['success'] == true && result['data'] != null) {
        print('✅ fetchUserInfo 성공');
        return result['data'] as Map<String, dynamic>;
      } else {
        print('❌ fetchUserInfo 실패: ${result['error']}');
        throw Exception(result['error'] ?? '사용자 정보를 가져올 수 없습니다');
      }
    } catch (e) {
      print('❌ fetchUserInfo 예외: $e');
      rethrow;
    }
  }

  /// 현재 사용자 정보 조회 (공통 로직)
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

  /// 🔧 사용자 정보 업데이트 (STAFF 전용)
  static Future<Map<String, dynamic>> updateUserInfo({
    required String phone,
    required String address,
    required String experience,
  }) async {
    try {
      print('=== 사용자 정보 업데이트 시작 ===');
      print('업데이트 데이터: phone=$phone, address=$address, experience=$experience');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      // 전화번호 포맷팅 (하이픈 제거)
      final formattedPhone = phone.replaceAll('-', '');

      // API 요청 데이터
      final requestData = {
        'phone': formattedPhone,
        'address': address,
        'experience': experience,
      };

      print('API 요청 데이터: $requestData');

      // API 호출
      final url = '$baseUrl/users/staff';
      print('API 호출 URL: $url');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestData),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? '정보가 성공적으로 업데이트되었습니다',
        };
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? '정보 업데이트에 실패했습니다';
        } catch (e) {
          errorMessage = '정보 업데이트에 실패했습니다 (${response.statusCode})';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ 사용자 정보 업데이트 중 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 📞 전화번호 포맷팅 (010-0000-0000)
  static String formatPhoneNumber(String phone) {
    // 숫자만 추출
    String numbersOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // 11자리 전화번호인 경우에만 포맷팅
    if (numbersOnly.length == 11 && numbersOnly.startsWith('010')) {
      return '${numbersOnly.substring(0, 3)}-${numbersOnly.substring(3, 7)}-${numbersOnly.substring(7, 11)}';
    }

    // 그 외의 경우는 원본 반환
    return phone;
  }

  /// ✅ 전화번호 유효성 검사
  static bool isValidPhoneNumber(String phone) {
    // 하이픈 제거 후 숫자만 추출
    String numbersOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // 010으로 시작하는 11자리 번호 확인
    return numbersOnly.length == 11 && numbersOnly.startsWith('010');
  }

  /// 🏠 주소 유효성 검사
  static bool isValidAddress(String address) {
    // 최소 5자 이상, 최대 100자 이하
    return address.trim().length >= 5 && address.trim().length <= 100;
  }

  /// 💼 경험 유효성 검사
  static bool isValidExperience(String experience) {
    // 최소 10자 이상, 최대 500자 이하
    return experience.trim().length >= 10 && experience.trim().length <= 500;
  }

  /// 🔍 입력값 전체 유효성 검사
  static Map<String, String?> validateUserInput({
    required String phone,
    required String address,
    required String experience,
  }) {
    Map<String, String?> errors = {};

    // 전화번호 검사
    if (phone.trim().isEmpty) {
      errors['phone'] = '전화번호를 입력해주세요';
    } else if (!isValidPhoneNumber(phone)) {
      errors['phone'] = '올바른 전화번호 형식이 아닙니다 (010-0000-0000)';
    }

    // 주소 검사
    if (address.trim().isEmpty) {
      errors['address'] = '주소를 입력해주세요';
    } else if (!isValidAddress(address)) {
      errors['address'] = '주소는 5자 이상 100자 이하로 입력해주세요';
    }

    // 경험 검사
    if (experience.trim().isEmpty) {
      errors['experience'] = '경험을 입력해주세요';
    } else if (!isValidExperience(experience)) {
      errors['experience'] = '경험은 10자 이상 500자 이하로 입력해주세요';
    }

    return errors;
  }
}