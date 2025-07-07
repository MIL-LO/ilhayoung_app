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

      // 🔧 안전한 토큰 로깅 (RangeError 방지)
      if (tempToken != null && tempToken.isNotEmpty) {
        final tokenPreview = tempToken.length > 20
            ? '${tempToken.substring(0, 20)}...'
            : '$tempToken...';
        print('임시 토큰: $tokenPreview');
      } else {
        print('❌ 임시 토큰이 없습니다');
        return {'success': false, 'error': '임시 토큰이 없습니다. 다시 로그인해주세요.'};
      }

      // 🔧 입력 데이터 검증 및 정리
      final cleanedData = _validateAndCleanData(
        birthDate: birthDate,
        phone: phone,
        address: address,
        experience: experience,
      );

      if (!cleanedData['isValid']) {
        print('❌ 입력 데이터 검증 실패: ${cleanedData['error']}');
        return {'success': false, 'error': cleanedData['error']};
      }

      // 백엔드 API 스펙에 맞는 요청 데이터
      final requestData = {
        'birthDate': cleanedData['birthDate'],
        'phone': cleanedData['phone'],
        'address': cleanedData['address'],
        'experience': cleanedData['experience'],
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
      ).timeout(const Duration(seconds: 30)); // 🔧 타임아웃 추가

      print('STAFF 회원가입 응답 상태: ${response.statusCode}');
      print('STAFF 회원가입 응답 헤더: ${response.headers}');
      print('STAFF 회원가입 응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ STAFF 회원가입 성공');

        // 새로운 토큰이 있다면 저장
        await _saveTokensFromResponse(data, prefs);

        // 사용자 상태 업데이트 (PENDING -> ACTIVE)
        await _updateUserStatus(data, prefs);

        return {
          'success': true,
          'data': data,
          'message': 'STAFF 회원가입이 완료되었습니다! 🎉'
        };

      } else {
        print('❌ STAFF 회원가입 실패: ${response.statusCode}');
        print('❌ 오류 내용: ${response.body}');

        return _handleErrorResponse(response);
      }

    } catch (e) {
      print('❌ STAFF 회원가입 처리 중 오류: $e');
      return {
        'success': false,
        'error': '회원가입 처리 중 오류가 발생했습니다. 다시 시도해주세요.'
      };
    }
  }

  /// 🔧 입력 데이터 검증 및 정리
  static Map<String, dynamic> _validateAndCleanData({
    required String birthDate,
    required String phone,
    required String address,
    required String experience,
  }) {
    try {
      // 생년월일 검증
      if (birthDate.trim().isEmpty) {
        return {'isValid': false, 'error': '생년월일을 입력해주세요.'};
      }

      // 날짜 형식 검증 (YYYY-MM-DD)
      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (!dateRegex.hasMatch(birthDate.trim())) {
        return {'isValid': false, 'error': '생년월일 형식이 올바르지 않습니다.'};
      }

      // 전화번호 검증
      if (phone.trim().isEmpty) {
        return {'isValid': false, 'error': '전화번호를 입력해주세요.'};
      }

      // 주소 검증
      if (address.trim().isEmpty) {
        return {'isValid': false, 'error': '주소를 입력해주세요.'};
      }
      if (address.trim().length < 5) {
        return {'isValid': false, 'error': '주소를 더 자세히 입력해주세요.'};
      }

      // 경험 검증 (빈 값이면 기본값 설정)
      String cleanedExperience = experience.trim();
      if (cleanedExperience.isEmpty) {
        cleanedExperience = '경험 없음';
      }

      return {
        'isValid': true,
        'birthDate': birthDate.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'experience': cleanedExperience,
      };
    } catch (e) {
      print('❌ 데이터 검증 중 오류: $e');
      return {'isValid': false, 'error': '입력 데이터 처리 중 오류가 발생했습니다.'};
    }
  }

  /// 🔧 응답에서 토큰 저장
  static Future<void> _saveTokensFromResponse(Map<String, dynamic> data, SharedPreferences prefs) async {
    try {
      // 새로운 액세스 토큰 저장
      if (data['access_token'] != null || data['accessToken'] != null) {
        final newToken = data['access_token'] ?? data['accessToken'];
        if (newToken != null && newToken.toString().isNotEmpty) {
          await prefs.setString('access_token', newToken.toString());
          print('✅ 새로운 액세스 토큰 저장됨');
        }
      }

      // 리프레시 토큰 저장
      if (data['refresh_token'] != null || data['refreshToken'] != null) {
        final refreshToken = data['refresh_token'] ?? data['refreshToken'];
        if (refreshToken != null && refreshToken.toString().isNotEmpty) {
          await prefs.setString('refresh_token', refreshToken.toString());
          print('✅ 리프레시 토큰 저장됨');
        }
      }
    } catch (e) {
      print('❌ 토큰 저장 중 오류: $e');
    }
  }

  /// 🔧 사용자 상태 업데이트
  static Future<void> _updateUserStatus(Map<String, dynamic> data, SharedPreferences prefs) async {
    try {
      // 사용자 상태 업데이트 (PENDING -> ACTIVE)
      if (data['status'] != null && data['status'].toString().isNotEmpty) {
        await prefs.setString('user_status', data['status'].toString());
        print('✅ 사용자 상태 업데이트: ${data['status']}');
      } else {
        // 회원가입 성공 시 상태를 ACTIVE로 가정
        await prefs.setString('user_status', 'ACTIVE');
        print('✅ 사용자 상태를 ACTIVE로 설정');
      }

      // 추가 사용자 정보 저장
      if (data['userId'] != null) {
        await prefs.setString('user_id', data['userId'].toString());
        print('✅ 사용자 ID 저장: ${data['userId']}');
      }
    } catch (e) {
      print('❌ 사용자 상태 업데이트 중 오류: $e');
    }
  }

  /// 🔧 에러 응답 처리
  static Map<String, dynamic> _handleErrorResponse(http.Response response) {
    try {
      String errorMessage;

      switch (response.statusCode) {
        case 400:
          errorMessage = '입력 정보를 확인해주세요.';
          break;
        case 401:
          errorMessage = '인증이 만료되었습니다. 다시 로그인해주세요.';
          break;
        case 409:
          errorMessage = '이미 등록된 정보입니다.';
          break;
        case 500:
          errorMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
          break;
        default:
          errorMessage = 'STAFF 회원가입에 실패했습니다.';
      }

      // 응답 본문에서 더 구체적인 오류 메시지 추출 시도
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null && errorData['message'].toString().isNotEmpty) {
          errorMessage = errorData['message'].toString();
        } else if (errorData['error'] != null && errorData['error'].toString().isNotEmpty) {
          errorMessage = errorData['error'].toString();
        }
      } catch (e) {
        print('❌ 오류 메시지 파싱 실패: $e');
      }

      return {
        'success': false,
        'error': errorMessage,
        'statusCode': response.statusCode,
        'details': response.body
      };
    } catch (e) {
      print('❌ 에러 응답 처리 중 오류: $e');
      return {
        'success': false,
        'error': '회원가입에 실패했습니다.',
        'details': response.body
      };
    }
  }

  /// 현재 사용자 상태 확인
  static Future<String?> getCurrentUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_status');
    } catch (e) {
      print('❌ 사용자 상태 확인 오류: $e');
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
      bool hasToken = accessToken != null && accessToken.isNotEmpty;
      bool isActive = userStatus == 'ACTIVE' || userStatus == 'VERIFIED';

      return hasToken && isActive;
    } catch (e) {
      print('❌ 로그인 상태 확인 오류: $e');
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
      bool hasToken = accessToken != null && accessToken.isNotEmpty;
      bool isPending = userStatus == 'PENDING';

      return hasToken && isPending;
    } catch (e) {
      print('❌ 회원가입 필요 확인 오류: $e');
      return false;
    }
  }
}