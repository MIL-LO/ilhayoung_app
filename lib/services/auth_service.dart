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

      // 사용자 정보 저장
      await saveUserInfo(
        userType: userType,
        status: status,
        email: email,
      );

      print('사용자 정보 저장 완료');

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

  /// 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final hasToken = prefs.getString(_accessTokenKey) != null;
    print('로그인 상태 확인: $hasToken');
    return hasToken;
  }

  /// 회원가입이 필요한지 확인
  static Future<bool> needsSignup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final status = prefs.getString(_userStatusKey) ?? 'PENDING';
      final userType = prefs.getString(_userTypeKey) ?? 'PENDING';

      print('=== needsSignup 확인 ===');
      print('현재 상태: $status');
      print('사용자 타입: $userType');

      // PENDING이거나 userType이 PENDING이면 회원가입 필요
      final needsSignup = status == 'PENDING' || userType == 'PENDING';
      print('회원가입 필요: $needsSignup');

      return needsSignup;
    } catch (e) {
      print('needsSignup 오류: $e');
      return true; // 기본값으로 회원가입 필요
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
        return UserType.manager;
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

  /// 액세스 토큰 가져오기
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// 서버 로그아웃 API 호출
  static Future<bool> logoutFromServer() async {
    try {
      print('=== 서버 로그아웃 시작 ===');

      final accessToken = await getAccessToken();
      if (accessToken == null) {
        print('액세스 토큰이 없음');
        return false;
      }

      final url = Uri.parse('${AppConfig.baseUrl}/api/v1/auth/logout');
      print('로그아웃 요청 URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('로그아웃 응답 상태: ${response.statusCode}');
      print('로그아웃 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        print('서버 로그아웃 성공');
        return true;
      } else {
        print('서버 로그아웃 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('서버 로그아웃 오류: $e');
      return false;
    }
  }

  /// 로그아웃 (서버 + 로컬)
  static Future<bool> logout() async {
    try {
      print('=== 로그아웃 시작 ===');

      // 1. 서버 로그아웃 API 호출
      final serverLogoutSuccess = await logoutFromServer();

      // 2. 로컬 토큰 및 사용자 정보 삭제 (서버 로그아웃 실패해도 로컬은 삭제)
      await _clearLocalData();

      print('로그아웃 완료 - 서버 로그아웃: $serverLogoutSuccess');

      // 서버 로그아웃이 실패해도 로컬 데이터는 삭제되므로 true 반환
      return true;
    } catch (e) {
      print('로그아웃 오류: $e');

      // 오류가 발생해도 로컬 데이터는 삭제
      await _clearLocalData();
      return false;
    }
  }

  /// 로컬 데이터 삭제
  static Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userTypeKey);
    await prefs.remove(_userStatusKey);
    await prefs.remove(_userEmailKey);
    print('로컬 데이터 삭제 완료 - 모든 토큰 및 사용자 정보 삭제됨');
  }
}