// lib/services/employer_signup_service.dart - 개선된 사업자 회원가입 서비스

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/auth_service.dart';

class EmployerSignupService {
  /// 🎯 사업자 회원가입 API (완전히 새로운 버전)
  static Future<Map<String, dynamic>> completeManagerSignup({
    required String businessName,
    required String businessNumber,
    required String businessType,
    required String businessAddress,
    required String ownerName,
    required String phone,
  }) async {
    try {
      print('=== 🏢 사업자 회원가입 시작 ===');
      print('사업장명: $businessName');
      print('사업자번호: $businessNumber');
      print('업종: $businessType');
      print('주소: $businessAddress');
      print('대표자명: $ownerName');
      print('연락처: $phone');

      // 1️⃣ 액세스 토큰 확인
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ 액세스 토큰 없음');
        return {
          'success': false,
          'error': '인증 토큰이 없습니다. 다시 로그인해주세요.',
        };
      }

      // 2️⃣ API 엔드포인트 설정
      final url = Uri.parse('${AppConfig.apiBaseUrl}/users/manager/signup');
      print('📡 API URL: $url');

      // 3️⃣ 요청 데이터 구성 - API 스펙에 맞춤
      final requestBody = {
        'companyName': businessName.trim(),
        'businessNumber': businessNumber.replaceAll('-', ''), // 하이픈 제거
        'businessType': businessType.trim(),
        'businessAddress': businessAddress.trim(),
        'representativeName': ownerName.trim(),
        'phone': phone.trim(),
      };

      print('📤 요청 데이터: $requestBody');

      // 4️⃣ API 호출
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API 호출 시간 초과 (30초)');
        },
      );

      print('📥 응답 상태: ${response.statusCode}');
      print('📥 응답 헤더: ${response.headers}');
      print('📥 응답 본문: ${response.body}');

      // 5️⃣ 응답 처리
      return _handleSignupResponse(response);

    } catch (e) {
      print('❌ 사업자 회원가입 오류: $e');
      return _handleSignupError(e);
    }
  }

  /// 📥 회원가입 응답 처리
  static Map<String, dynamic> _handleSignupResponse(http.Response response) {
    try {
      // JSON 파싱
      final responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
        case 201:
        // 성공 응답
          if (responseData['code'] == 'SUCCESS' || responseData['success'] == true) {
            print('✅ 사업자 회원가입 성공');
            return {
              'success': true,
              'message': responseData['message'] ?? '사업자 회원가입이 완료되었습니다! 🎉',
              'data': responseData['data'] ?? {},
            };
          } else {
            print('❌ API 로직 오류: ${responseData['message']}');
            return {
              'success': false,
              'error': responseData['message'] ?? '회원가입 처리 중 오류가 발생했습니다.',
            };
          }

        case 400:
        // 잘못된 요청
          print('❌ 잘못된 요청 (400)');
          return {
            'success': false,
            'error': responseData['message'] ?? '입력 정보를 확인해주세요.',
          };

        case 401:
        // 인증 오류
          print('❌ 인증 오류 (401)');
          return {
            'success': false,
            'error': '인증이 만료되었습니다. 다시 로그인해주세요.',
          };

        case 409:
        // 중복 데이터
          print('❌ 중복 데이터 (409)');
          return {
            'success': false,
            'error': responseData['message'] ?? '이미 등록된 사업자등록번호입니다.',
          };

        case 500:
        // 서버 오류
          print('❌ 서버 오류 (500)');
          return {
            'success': false,
            'error': '서버에서 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
          };

        default:
          print('❌ 예상치 못한 HTTP 상태: ${response.statusCode}');
          return {
            'success': false,
            'error': 'HTTP ${response.statusCode}: ${responseData['message'] ?? '알 수 없는 오류가 발생했습니다.'}',
          };
      }
    } catch (e) {
      print('❌ 응답 파싱 오류: $e');
      return {
        'success': false,
        'error': '서버 응답을 처리할 수 없습니다.',
      };
    }
  }

  /// ❌ 회원가입 오류 처리
  static Map<String, dynamic> _handleSignupError(dynamic error) {
    final errorMessage = error.toString();

    if (errorMessage.contains('TimeoutException') || errorMessage.contains('시간 초과')) {
      return {
        'success': false,
        'error': '네트워크 연결이 느립니다. 잠시 후 다시 시도해주세요.',
      };
    }

    if (errorMessage.contains('SocketException') || errorMessage.contains('NetworkException')) {
      return {
        'success': false,
        'error': '인터넷 연결을 확인해주세요.',
      };
    }

    if (errorMessage.contains('FormatException')) {
      return {
        'success': false,
        'error': '서버에서 잘못된 응답을 받았습니다.',
      };
    }

    return {
      'success': false,
      'error': '회원가입 중 오류가 발생했습니다: ${errorMessage.length > 100 ? '${errorMessage.substring(0, 100)}...' : errorMessage}',
    };
  }

  /// ✅ 입력값 유효성 검사 - 강화된 버전
  static Map<String, String?> validateManagerInfo({
    required String ownerName,
    required String businessName,
    required String businessNumber,
    required String businessAddress,
    required String phone,
    required String businessType,
  }) {
    Map<String, String?> errors = {};

    // 대표자명 검사
    final ownerNameTrimmed = ownerName.trim();
    if (ownerNameTrimmed.isEmpty) {
      errors['ownerName'] = '대표자명을 입력해주세요.';
    } else if (ownerNameTrimmed.length < 2) {
      errors['ownerName'] = '대표자명을 2글자 이상 입력해주세요.';
    } else if (ownerNameTrimmed.length > 20) {
      errors['ownerName'] = '대표자명은 20글자 이하로 입력해주세요.';
    } else if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(ownerNameTrimmed)) {
      errors['ownerName'] = '대표자명은 한글 또는 영문만 입력 가능합니다.';
    }

    // 사업장명 검사
    final businessNameTrimmed = businessName.trim();
    if (businessNameTrimmed.isEmpty) {
      errors['businessName'] = '사업장명을 입력해주세요.';
    } else if (businessNameTrimmed.length < 2) {
      errors['businessName'] = '사업장명을 2글자 이상 입력해주세요.';
    } else if (businessNameTrimmed.length > 50) {
      errors['businessName'] = '사업장명은 50글자 이하로 입력해주세요.';
    }

    // 사업자등록번호 검사 - 개선된 버전
    final businessNumberCleaned = businessNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (businessNumber.trim().isEmpty) {
      errors['businessNumber'] = '사업자등록번호를 입력해주세요.';
    } else if (businessNumberCleaned.length != 10) {
      errors['businessNumber'] = '사업자등록번호는 10자리 숫자여야 합니다.';
    } else if (!_isValidBusinessNumber(businessNumberCleaned)) {
      errors['businessNumber'] = '유효하지 않은 사업자등록번호입니다.';
    }

    // 사업장 주소 검사
    final businessAddressTrimmed = businessAddress.trim();
    if (businessAddressTrimmed.isEmpty) {
      errors['businessAddress'] = '사업장 주소를 입력해주세요.';
    } else if (businessAddressTrimmed.length < 10) {
      errors['businessAddress'] = '사업장 주소를 더 자세히 입력해주세요. (최소 10글자)';
    } else if (businessAddressTrimmed.length > 200) {
      errors['businessAddress'] = '사업장 주소는 200글자 이하로 입력해주세요.';
    }

    // 전화번호 검사 - 강화된 버전
    final phoneTrimmed = phone.trim();
    if (phoneTrimmed.isEmpty) {
      errors['phone'] = '연락처를 입력해주세요.';
    } else if (!_isValidPhoneNumber(phoneTrimmed)) {
      errors['phone'] = '올바른 전화번호 형식이 아닙니다. (예: 010-1234-5678)';
    }

    // 업종 검사
    final businessTypeTrimmed = businessType.trim();
    if (businessTypeTrimmed.isEmpty) {
      errors['businessType'] = '업종을 선택해주세요.';
    }

    return errors;
  }

  /// 📞 전화번호 유효성 검사
  static bool _isValidPhoneNumber(String phone) {
    // 기본 패턴 (010-1234-5678)
    if (RegExp(r'^010-\d{4}-\d{4}$').hasMatch(phone)) {
      return true;
    }

    // 하이픈 없는 패턴 (01012345678)
    if (RegExp(r'^010\d{8}$').hasMatch(phone)) {
      return true;
    }

    // 일반 전화번호 패턴 (02-123-4567, 064-123-4567)
    if (RegExp(r'^0\d{1,2}-\d{3,4}-\d{4}$').hasMatch(phone)) {
      return true;
    }

    return false;
  }

  /// 🏢 사업자등록번호 체크섬 검증
  static bool _isValidBusinessNumber(String businessNumber) {
    if (businessNumber.length != 10) return false;

    try {
      List<int> digits = businessNumber.split('').map(int.parse).toList();
      List<int> weights = [1, 3, 7, 1, 3, 7, 1, 3, 5];

      int sum = 0;
      for (int i = 0; i < 9; i++) {
        sum += digits[i] * weights[i];
      }

      int remainder = sum % 10;
      int checkDigit = remainder == 0 ? 0 : 10 - remainder;

      return checkDigit == digits[9];
    } catch (e) {
      return false;
    }
  }

  /// 📱 전화번호 포맷 자동 변환 - 개선된 버전
  static String formatPhoneNumber(String input) {
    // 숫자만 추출
    String numbers = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.isEmpty) return '';

    // 휴대폰 번호 (010-1234-5678)
    if (numbers.length == 11 && numbers.startsWith('010')) {
      return '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7)}';
    }

    // 서울 지역번호 (02-123-4567)
    if (numbers.length == 9 && numbers.startsWith('02')) {
      return '02-${numbers.substring(2, 5)}-${numbers.substring(5)}';
    }

    // 기타 지역번호 (064-123-4567)
    if (numbers.length == 10 && (numbers.startsWith('031') || numbers.startsWith('032') ||
        numbers.startsWith('033') || numbers.startsWith('041') || numbers.startsWith('042') ||
        numbers.startsWith('043') || numbers.startsWith('051') || numbers.startsWith('052') ||
        numbers.startsWith('053') || numbers.startsWith('054') || numbers.startsWith('055') ||
        numbers.startsWith('061') || numbers.startsWith('062') || numbers.startsWith('063') ||
        numbers.startsWith('064'))) {
      return '${numbers.substring(0, 3)}-${numbers.substring(3, 6)}-${numbers.substring(6)}';
    }

    return input; // 형식이 맞지 않으면 원본 반환
  }

  /// 🏢 사업자등록번호 포맷 변환 (123-45-67890)
  static String formatBusinessNumber(String input) {
    String numbers = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length == 10) {
      return '${numbers.substring(0, 3)}-${numbers.substring(3, 5)}-${numbers.substring(5)}';
    }

    return input;
  }
}