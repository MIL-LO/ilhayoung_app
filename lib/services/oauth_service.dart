// lib/services/oauth_service.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../core/enums/user_type.dart';
import '../core/models/oauth_response.dart';
import '../config/app_config.dart';

class OAuthService {
  static Future<OAuthResponse> signInWithOAuth({
    required BuildContext context,
    required String provider,
    required UserType userType,
  }) async {
    try {
      // OAuth URL 생성
      final oauthUrl = _buildOAuthUrl(provider, userType);

      print('OAuth URL: $oauthUrl');

      // TODO: 실제 OAuth 인증 로직 구현
      // 예: 웹뷰나 외부 브라우저를 통한 OAuth 인증
      // 실제 HTTP 요청을 시뮬레이션하기 위해 약간의 지연 추가
      await Future.delayed(const Duration(milliseconds: 500));

      // 임시로 성공 응답 반환 (실제 구현에서는 제거)
      return OAuthResponse(
        success: true,
        message: 'OAuth 인증 성공',
        accessToken: 'temp_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'temp_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      print('OAuth 인증 오류: $e');
      return OAuthResponse(
        success: false,
        message: 'OAuth 인증 중 오류가 발생했습니다: $e',
      );
    }
  }

  static String _buildOAuthUrl(String provider, UserType userType) {
    final baseUrl = AppConfig.baseUrl;
    final role = userType.serverValue;
    return '$baseUrl/oauth2/authorization/$provider?role=$role';
  }
}