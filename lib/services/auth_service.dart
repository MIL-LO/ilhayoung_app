import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../core/enums/user_type.dart';
import '../../core/models/oauth_response.dart';
import '../../services/oauth_service.dart';
import '../../config/app_config.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userTypeKey = 'user_type';
  static const String _userStatusKey = 'user_status';
  static const String _userEmailKey = 'user_email';

  /// 실제 OAuth 로그인
  static Future<OAuthResponse> signInWithOAuth({
    required BuildContext context,
    required String provider,
    required UserType userType,
  }) async {
    try {
      print('=== 실제 OAuth 로그인 시작 ===');
      print('Provider: $provider');
      print('UserType: $userType');

      final response = await OAuthService.signInWithOAuth(
        context: context,
        provider: provider,
        userType: userType,
      );

      print('=== OAuth 응답 처리 ===');
      print('Success: ${response.success}');

      if (response.success && response.accessToken != null) {
        // 실제 토큰 저장
        await saveToken(response.accessToken!, response.refreshToken);
        print('실제 토큰 저장 완료');

        // 실제 JWT 파싱 및 사용자 정보 저장
        await _parseJWTAndSaveUserInfo(response.accessToken!);

        print('=== OAuth 최종 응답 ===');
        print('Success: ${response.success}');
        print('Message: ${response.message}');

        // 저장된 사용자 정보 확인
        final status = await getUserStatus();
        final type = await getUserType();
        print('저장된 User Status: $status');
        print('저장된 User Type: $type');

        return response;
      }

      return response;
    } catch (e) {
      print('OAuth 로그인 에러: $e');
      return OAuthResponse(
        success: false,
        message: 'OAuth 로그인 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 실제 JWT 토큰 파싱 및 사용자 정보 저장
  static Future<void> _parseJWTAndSaveUserInfo(String accessToken) async {
    try {
      print('=== JWT 파싱 시작 ===');
      print('AccessToken: ${accessToken.substring(0, 50)}...');

      final parts = accessToken.split('.');
      if (parts.length != 3) {
        throw Exception('잘못된 JWT 형식: 3개 부분이 필요하지만 ${parts.length}개가 있음');
      }

      // JWT payload 디코딩
      String payload = parts[1];

      // Base64 패딩 추가 (필요한 경우)
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      print('JWT Payload (raw): $payload');

      final decodedBytes = base64Decode(payload);
      final decodedString = utf8.decode(decodedBytes);
      print('JWT Payload (decoded): $decodedString');

      final payloadData = json.decode(decodedString);
      print('JWT Payload (parsed): $payloadData');

      // 백엔드에서 보내는 실제 필드명에 맞춰 파싱
      final userType = payloadData['userType'] ?? payloadData['role'] ?? 'PENDING';
      final status = payloadData['status'] ?? 'PENDING';
      final email = payloadData['email'] ?? payloadData['sub'] ?? 'unknown@example.com';

      print('추출된 정보:');
      print('- UserType: $userType');
      print('- Status: $status');
      print('- Email: $email');

      // 🔥 STAFF 타입이면 바로 ACTIVE 상태로 저장 (이미 회원가입 완료)
      String finalStatus = status;
      if (userType == 'STAFF' || userType == 'OWNER') {
        finalStatus = 'ACTIVE';
        print('🚀 ${userType} 타입 감지 - 자동으로 ACTIVE 상태로 설정');
      }

      // 사용자 정보 저장
      await saveUserInfo(
        userType: userType,
        status: finalStatus, // 🔥 ACTIVE 상태로 저장
        email: email,
      );

      print('사용자 정보 저장 완료 - 최종 상태: $finalStatus');

    } catch (e) {
      print('JWT 파싱 실패: $e');
      print('스택 트레이스: ${StackTrace.current}');
      throw Exception('JWT 토큰 파싱에 실패했습니다: $e');
    }
  }

  /// 토큰 저장
  static Future<void> saveToken(String accessToken, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    print('토큰 저장됨: AccessToken=${accessToken.substring(0, 20)}...');
  }

  /// 사용자 정보 저장
  static Future<void> saveUserInfo({
    required String userType,
    required String status,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, userType);
    await prefs.setString(_userStatusKey, status);
    await prefs.setString(_userEmailKey, email);
    print('사용자 정보 저장됨: Type=$userType, Status=$status, Email=$email');
  }

  /// 🔥 회원가입 완료 시 사용자 상태 업데이트 (자동 로그인 활성화)
  static Future<bool> updateUserStatusToVerified() async {
    try {
      print('=== 사용자 상태를 ACTIVE로 업데이트 ===');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStatusKey, 'ACTIVE');

      print('✅ 사용자 상태 ACTIVE로 업데이트 완료 (자동 로그인 활성화)');
      return true;
    } catch (e) {
      print('❌ 사용자 상태 업데이트 실패: $e');
      return false;
    }
  }

  /// 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.getString(_accessTokenKey) != null;
    print('로그인 상태 확인: $hasToken');
    return hasToken;
  }

  /// 🔥 회원가입이 필요한지 확인 (UserType 기반으로 간단하게)
  static Future<bool> needsSignup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString(_userTypeKey) ?? 'PENDING';

      print('=== needsSignup 확인 (UserType 기반) ===');
      print('사용자 타입: $userType');

      // 🔥 STAFF 또는 OWNER면 이미 회원가입 완료된 것으로 간주
      final needsSignup = !(userType == 'STAFF' || userType == 'OWNER');
      print('회원가입 필요: $needsSignup');

      return needsSignup;
    } catch (e) {
      print('needsSignup 오류: $e');
      return true; // 기본값으로 회원가입 필요
    }
  }

  /// 🔥 UserType 기반 자동 로그인 가능 여부 확인 (더 간단하게)
  static Future<bool> canAutoLogin() async {
    try {
      print('=== 자동 로그인 가능 여부 확인 (UserType 기반) ===');

      // 1. 토큰 존재 여부 확인
      final hasToken = await isLoggedIn();
      if (!hasToken) {
        print('❌ 토큰 없음 - 자동 로그인 불가');
        return false;
      }

      // 2. UserType 확인 (STAFF 또는 OWNER면 자동 로그인 허용)
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString(_userTypeKey) ?? 'PENDING';
      final isValidUserType = userType == 'STAFF' || userType == 'OWNER';

      print('자동 로그인 가능 여부:');
      print('- 토큰 존재: $hasToken');
      print('- 사용자 타입: $userType');
      print('- 유효한 사용자 타입: $isValidUserType');

      final canAuto = hasToken && isValidUserType;
      print('🎯 자동 로그인 가능: $canAuto');

      return canAuto;
    } catch (e) {
      print('❌ 자동 로그인 가능 여부 확인 실패: $e');
      return false;
    }
  }

  /// 사용자 타입 가져오기
  static Future<UserType?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final userTypeString = prefs.getString(_userTypeKey);
    print('저장된 UserType 문자열: $userTypeString');

    if (userTypeString == null) return null;

    switch (userTypeString.toUpperCase()) {
      case 'STAFF':
        return UserType.worker;
      case 'MANAGER':
      case 'OWNER': // 🔥 OWNER도 employer로 매핑
        return UserType.employer;
      default:
        print('알 수 없는 UserType: $userTypeString');
        return null;
    }
  }

  /// 사용자 상태 가져오기
  static Future<String?> getUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString(_userStatusKey);
    print('저장된 Status: $status');
    return status;
  }

  /// 사용자 이메일 가져오기
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_userEmailKey);
    print('저장된 Email: $email');
    return email;
  }

  /// 액세스 토큰 가져오기
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// 🔥 수정된 서버 로그아웃 API 호출
  static Future<bool> logoutFromServer() async {
    try {
      print('=== 서버 로그아웃 시작 ===');

      final accessToken = await getAccessToken();
      if (accessToken == null) {
        print('액세스 토큰이 없음 - 서버 로그아웃 건너뜀');
        return false;
      }

      // 🔥 올바른 API 엔드포인트 사용
      final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/logout'); // /api/v1/auth/logout
      print('로그아웃 요청 URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        // 🔥 body 제거 (API 스펙에 "No parameters"라고 되어 있음)
      );

      print('로그아웃 응답 상태: ${response.statusCode}');
      print('로그아웃 응답 본문: ${response.body}');

      // 🔥 성공 상태 코드 확장 (200 또는 204)
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ 서버 로그아웃 성공');
        return true;
      } else {
        print('❌ 서버 로그아웃 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ 서버 로그아웃 네트워크 오류: $e');
      return false;
    }
  }

  /// 🔥 강화된 로그아웃 (서버 + 로컬)
  static Future<bool> logout() async {
    try {
      print('=== 로그아웃 시작 ===');

      // 1. 서버 로그아웃 API 호출
      final serverLogoutSuccess = await logoutFromServer();

      // 2. 로컬 토큰 및 사용자 정보 삭제 (서버 로그아웃 실패해도 로컬은 삭제)
      await _clearLocalData();

      print('🎯 로그아웃 완료 - 서버 로그아웃: $serverLogoutSuccess');

      // 서버 로그아웃이 실패해도 로컬 데이터는 삭제되므로 true 반환
      return true;
    } catch (e) {
      print('❌ 로그아웃 처리 중 예외 발생: $e');

      // 오류가 발생해도 로컬 데이터는 삭제
      try {
        await _clearLocalData();
        print('✅ 예외 상황에서도 로컬 데이터 삭제 완료');
      } catch (localError) {
        print('❌ 로컬 데이터 삭제도 실패: $localError');
      }
      return false;
    }
  }

  /// 🔥 강화된 로컬 데이터 삭제
  static Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 모든 인증 관련 데이터 삭제
      final keysToRemove = [
        _accessTokenKey,
        _refreshTokenKey,
        _userTypeKey,
        _userStatusKey,
        _userEmailKey,
        'is_logged_in', // 추가 키
        'oauth_state',  // OAuth 캐시
        'oauth_nonce',  // OAuth 캐시
        'last_login_time', // 로그인 시간
        'kakao_user_id',   // 카카오 사용자 ID
      ];

      for (String key in keysToRemove) {
        final removed = await prefs.remove(key);
        if (removed) {
          print('🗑️ 삭제됨: $key');
        }
      }

      print('✅ 로컬 데이터 삭제 완료 - 모든 토큰 및 사용자 정보 삭제됨');
    } catch (e) {
      print('❌ 로컬 데이터 삭제 오류: $e');
      throw e;
    }
  }

  /// 🔥 토큰 새로고침
  static Future<bool> refreshToken() async {
    try {
      print('=== 토큰 새로고침 시작 ===');

      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);

      if (refreshToken == null || refreshToken.isEmpty) {
        print('❌ Refresh Token이 없음');
        return false;
      }

      final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/refresh');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 새로운 토큰 저장
        await prefs.setString(_accessTokenKey, data['access_token']);

        if (data['refresh_token'] != null) {
          await prefs.setString(_refreshTokenKey, data['refresh_token']);
        }

        print('✅ 토큰 새로고침 성공');
        return true;
      } else {
        print('❌ 토큰 새로고침 실패: ${response.statusCode}');
        return false;
      }

    } catch (e) {
      print('❌ 토큰 새로고침 중 예외 발생: $e');
      return false;
    }
  }

  /// 🔧 사용자 상태를 강제로 ACTIVE로 업데이트 (디버깅용)
  static Future<void> forceUpdateToVerified() async {
    try {
      print('=== 강제로 ACTIVE 상태로 업데이트 ===');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_status', 'ACTIVE');

      print('✅ 사용자 상태를 ACTIVE로 강제 업데이트 완료');

      // 업데이트 후 자동 로그인 가능 여부 재확인
      final canAuto = await canAutoLogin();
      print('🔍 업데이트 후 자동 로그인 가능: $canAuto');

    } catch (e) {
      print('❌ 강제 업데이트 실패: $e');
    }
  }

  /// 🔍 저장된 모든 인증 데이터 확인 (디버깅용)
  static Future<void> debugStoredData() async {
    try {
      print('=== 저장된 인증 데이터 전체 확인 ===');

      final prefs = await SharedPreferences.getInstance();

      // 모든 인증 관련 키 확인
      final keys = [
        'access_token',
        'refresh_token',
        'user_type',
        'user_status',
        'user_email',
        'is_logged_in',
        'oauth_state',
        'oauth_nonce',
        'last_login_time',
        'kakao_user_id',
      ];

      print('📋 저장된 데이터:');
      for (String key in keys) {
        final value = prefs.getString(key);
        if (value != null) {
          if (key == 'access_token') {
            print('✅ $key: ${value.substring(0, 20)}...');
          } else {
            print('✅ $key: $value');
          }
        } else {
          print('❌ $key: null');
        }
      }

      // 자동 로그인 조건 체크
      print('\n🔍 자동 로그인 조건 체크:');
      final hasToken = await isLoggedIn();
      final needsSignupResult = await needsSignup();
      final canAuto = await canAutoLogin();
      final userType = await getUserType();
      final userStatus = await getUserStatus();

      print('- 토큰 존재: $hasToken');
      print('- 회원가입 필요: $needsSignupResult');
      print('- 사용자 타입: $userType');
      print('- 사용자 상태: $userStatus');
      print('- 자동 로그인 가능: $canAuto');

      // 자동 로그인 실패 원인 분석
      if (!canAuto) {
        print('\n❌ 자동 로그인 실패 원인 분석:');
        if (!hasToken) {
          print('- 토큰이 없음');
        }
        if (needsSignupResult) {
          print('- 회원가입이 필요함 (UserType이 STAFF/OWNER가 아님)');
        }
      }

      print('=== 디버깅 완료 ===\n');

    } catch (e) {
      print('❌ 저장된 데이터 확인 실패: $e');
    }
  }
}