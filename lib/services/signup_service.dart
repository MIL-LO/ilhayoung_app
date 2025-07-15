// lib/services/signup_service.dart - 업데이트된 버전

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import 'auth_service.dart';

class SignupService {
  static String get _baseUrl => AppConstants.baseUrl;

  /// 구직자(STAFF) 회원가입 완료
  static Future<Map<String, dynamic>> completeStaffSignup({
    required String birthDate,
    required String phone,
    required String address,
    required String experience,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/users/staff/signup');
      final headers = await _getHeaders();

      final requestBody = {
        'birthDate': birthDate,
        'phone': phone,
        'address': address,
        'experience': experience,
      };

      print('=== 구직자 회원가입 API 호출 ===');
      print('URL: $uri');
      print('Request Body: $requestBody');

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          // 🎯 회원가입 성공 시 새로운 토큰 저장
          final data = jsonResponse['data'];
          if (data != null && data['accessToken'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', data['accessToken']);
            if (data['refreshToken'] != null) {
              await prefs.setString('refresh_token', data['refreshToken']);
            }
            print('✅ 회원가입 완료 후 새로운 토큰 저장됨');
          }
          
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '구직자 회원가입이 완료되었습니다.',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '회원가입에 실패했습니다.',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('구직자 회원가입 API 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 사업자(MANAGER) 회원가입 완료
  static Future<Map<String, dynamic>> completeManagerSignup({
    required String birthDate,
    required String phone,
    required String businessName,
    required String businessAddress,
    required String businessNumber,
    required String businessType,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/users/manager/signup');
      final headers = await _getHeaders();

      final requestBody = {
        'birthDate': birthDate,
        'phone': phone,
        'companyName': businessName,
        'businessAddress': businessAddress,
        'businessNumber': businessNumber,
        'businessType': businessType,
      };

      print('=== 사업자 회원가입 API 호출 ===');
      print('URL: $uri');
      print('Request Body: $requestBody');

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          // 🎯 회원가입 성공 시 새로운 토큰 저장
          final data = jsonResponse['data'];
          if (data != null && data['accessToken'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', data['accessToken']);
            if (data['refreshToken'] != null) {
              await prefs.setString('refresh_token', data['refreshToken']);
            }
            print('✅ 회원가입 완료 후 새로운 토큰 저장됨');
          }
          
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '사업자 회원가입이 완료되었습니다.',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '회원가입에 실패했습니다.',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('사업자 회원가입 API 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 공통 헤더 생성
  static Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 인증 토큰 추가
    final token = await AuthService.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// 전화번호 포맷팅 (하이픈 제거)
  static String formatPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// 사업자등록번호 포맷팅 (하이픈 제거)
  static String formatBusinessNumber(String businessNumber) {
    return businessNumber.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// 생년월일 유효성 검사
  static bool isValidBirthDate(String birthDate) {
    try {
      final date = DateTime.parse(birthDate);
      final now = DateTime.now();
      final age = now.year - date.year;

      // 14세 이상, 100세 이하 확인
      return age >= 14 && age <= 100;
    } catch (e) {
      return false;
    }
  }

  /// 전화번호 유효성 검사
  static bool isValidPhoneNumber(String phone) {
    final cleanPhone = formatPhoneNumber(phone);

    // 한국 휴대폰 번호 패턴 (010, 011, 016, 017, 018, 019)
    final phoneRegex = RegExp(r'^01[0-9]{8,9}$');
    return phoneRegex.hasMatch(cleanPhone);
  }

  /// 사업자등록번호 API 검증
  static Future<Map<String, dynamic>> verifyBusinessNumber(String businessNumber) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/users/verify-business');
      final headers = await _getHeaders();

      final cleanNumber = formatBusinessNumber(businessNumber);

      final requestBody = {
        'businessNumber': cleanNumber,
      };

      print('=== 사업자등록번호 검증 API 호출 ===');
      print('URL: $uri');
      print('Request Body: $requestBody');

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestBody),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '유효한 사업자등록번호입니다.',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '유효하지 않은 사업자등록번호입니다.',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('사업자등록번호 검증 API 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 사업자등록번호 로컬 유효성 검사 (체크섬 검증)
  static bool isValidBusinessNumberFormat(String businessNumber) {
    final cleanNumber = formatBusinessNumber(businessNumber);

    // 사업자등록번호는 10자리
    if (cleanNumber.length != 10) return false;

    // 체크섬 검증 (간단한 버전)
    final digits = cleanNumber.split('').map(int.parse).toList();
    final checkArray = [1, 3, 7, 1, 3, 7, 1, 3, 5];

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * checkArray[i];
    }

    sum += ((digits[8] * 5) ~/ 10);
    int checkDigit = (10 - (sum % 10)) % 10;

    return checkDigit == digits[9];
  }
}