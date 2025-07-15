// lib/services/oauth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 추가
import '../config/app_config.dart';
import '../core/enums/user_type.dart';
import '../core/models/oauth_response.dart';

class OAuthService {
  // 쿠키 및 웹 데이터 삭제
  static Future<void> clearWebData() async {
    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      print('WebView 쿠키 삭제 완료');
    } catch (e) {
      print('쿠키 삭제 오류: $e');
    }
  }

  static Future<OAuthResponse> signInWithOAuth({
    required BuildContext context,
    required String provider,
    required UserType userType,
  }) async {
    try {
      print('=== OAuth 전체 화면 시작 ===');

      // 사용자 타입을 백엔드가 기대하는 형식으로 변환
      final role = userType.serverValue;
      final oauthUrl = AppConfig.getOAuthUrl(provider, role);

      print('OAuth URL: $oauthUrl');

      // 전체 화면으로 OAuth 로그인 화면 이동
      final result = await Navigator.push<OAuthResponse>(
        context,
        MaterialPageRoute(
          builder: (context) => _OAuthWebViewScreen(
            provider: provider,
            oauthUrl: oauthUrl,
          ),
        ),
      );

      return result ?? OAuthResponse(
        success: false,
        message: '로그인이 취소되었습니다.',
      );

    } catch (e) {
      print('OAuth 오류: $e');
      return OAuthResponse(
        success: false,
        message: '로그인 중 오류가 발생했습니다: $e',
      );
    }
  }
}

class _OAuthWebViewScreen extends StatefulWidget {
  final String provider;
  final String oauthUrl;

  const _OAuthWebViewScreen({
    required this.provider,
    required this.oauthUrl,
  });

  @override
  State<_OAuthWebViewScreen> createState() => _OAuthWebViewScreenState();
}

class _OAuthWebViewScreenState extends State<_OAuthWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasFoundResult = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _hasFoundResult = true;
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted && !_hasFoundResult) {
              setState(() {
                _isLoading = true;
              });
            }
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            if (mounted && !_hasFoundResult) {
              setState(() {
                _isLoading = false;
              });
            }
            print('Page finished loading: $url');
            _checkForOAuthResponse(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation request: ${request.url}');

            // 카카오톡 앱 스킴 처리
            if (request.url.startsWith('kakaotalk://')) {
              print('카카오톡 앱 스킴 감지: ${request.url}');
              _launchKakaoTalkApp(request.url);
              return NavigationDecision.prevent;
            }

            _checkForOAuthResponse(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.oauthUrl));
  }

  void _checkForOAuthResponse(String url) {
    if (_hasFoundResult || !mounted) return;

    print('URL 체크: $url');

    try {
      // URL 디코딩 처리
      final decodedUrl = Uri.decodeFull(url);
      print('디코딩된 URL: $decodedUrl');
      
      final uri = Uri.parse(decodedUrl);

      // 🔥 백엔드 호스트 체크 (개발/배포 환경 모두 지원)
      final isBackendHost = (uri.host == 'localhost' && uri.port == 5000) ||
                           (uri.host == 'api.ilhayoung.com') ||
                           (uri.host.contains('ilhayoung.com'));
      final isCallbackPath = uri.path.contains('/login/oauth2/code/') ||
          uri.path.contains('/oauth/callback') ||
          uri.path.contains('/login/success');

      print('Host: ${uri.host}, Path: ${uri.path}');
      print('Backend Host: $isBackendHost, Callback Path: $isCallbackPath');

      if (isBackendHost && isCallbackPath) {
        print('✅ 성공 URL 감지');
        _hasFoundResult = true;
        _extractOAuthResponse();
        return;
      }

      // 에러 파라미터 처리
      if (uri.queryParameters.containsKey('error')) {
        print('❌ 오류 URL 감지: ${uri.queryParameters['error']}');
        _handleErrorResponse(uri.queryParameters['error_description'] ??
            uri.queryParameters['error'] ??
            'OAuth 인증에 실패했습니다.');
        return;
      }

    } catch (e) {
      print('❌ URL 파싱 오류: $e');
    }
  }

  /// 카카오톡 앱 실행
  void _launchKakaoTalkApp(String url) async {
    try {
      final uri = Uri.parse(url);
      print('카카오톡 앱 실행 시도: $url');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('카카오톡 앱 실행 성공');
      } else {
        print('카카오톡 앱 실행 실패 - 앱이 설치되지 않음');
        // 카카오톡 설치 페이지로 이동하거나 웹 로그인 계속 진행
      }
    } catch (e) {
      print('카카오톡 앱 실행 오류: $e');
    }
  }

  void _extractOAuthResponse() async {
    if (_hasFoundResult && !mounted) return;

    try {
      // 페이지 로딩 대기
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;

      // 페이지 텍스트 추출
      String? pageText;
      try {
        final result = await _controller.runJavaScriptReturningResult(
            'document.body.innerText || document.body.textContent || ""'
        );
        pageText = result.toString();
        print('페이지 텍스트 추출 성공: ${pageText.length > 200 ? pageText.substring(0, 200) : pageText}...');
      } catch (jsError) {
        print('JavaScript 실행 실패: $jsError');
        print('JavaScript 실패했지만 OAuth 성공 URL에 도달, 성공 처리');
        _handleSuccessResponse();
        return;
      }

      // 페이지 텍스트 분석
      if (pageText.isNotEmpty) {
        print('=== 페이지 전체 텍스트 분석 ===');
        print(pageText);
        print('=== 페이지 텍스트 끝 ===');

        // 🎯 패턴 1: 전체 페이지에서 JSON 추출 시도 (우선순위 높임)
        print('🎯 전체 페이지에서 JSON 추출 시도');
        try {
          // 페이지에서 JSON 부분만 추출
          final jsonStart = pageText.indexOf('{');
          final jsonEnd = pageText.lastIndexOf('}');
          
          if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
            final jsonStr = pageText.substring(jsonStart, jsonEnd + 1);
            print('추출된 JSON 문자열: $jsonStr');
            
            // JSON 유효성 검사
            if (jsonStr.contains('"success"') && jsonStr.contains('"accessToken"')) {
              final responseData = json.decode(jsonStr);
              print('전체 페이지 JSON 디코딩 성공: $responseData');
              
              // 백엔드 응답 형식에 맞춰 OAuthResponse 생성
              final oauthResponse = OAuthResponse(
                success: responseData['success'] ?? false,
                message: responseData['message'] ?? '',
                accessToken: responseData['accessToken'],
                refreshToken: responseData['refreshToken'],
              );
              
              print('전체 페이지에서 OAuthResponse 생성 성공!');
              _handleOAuthResponse(oauthResponse);
              return;
            } else {
              print('JSON에 필요한 필드가 없음: success=${jsonStr.contains('"success"')}, accessToken=${jsonStr.contains('"accessToken"')}');
            }
          }
        } catch (e) {
          print('전체 페이지 JSON 파싱 실패: $e');
        }

        // 패턴 2: JSON 형태의 응답 찾기 (정규식 패턴)
        final jsonPatterns = [
          // 완전한 JSON 객체 패턴 (백엔드 응답 형식에 맞춤)
          RegExp(r'\{[^{}]*"success"[^{}]*"message"[^{}]*"accessToken"[^{}]*"refreshToken"[^{}]*\}'),
          RegExp(r'\{[^{}]*"success"[^{}]*"accessToken"[^{}]*"refreshToken"[^{}]*\}'),
          RegExp(r'\{[^{}]*"success"[^{}]*"message"[^{}]*"accessToken"[^{}]*\}'),
          RegExp(r'\{[^{}]*"success"[^{}]*"accessToken"[^{}]*\}'),
          // 더 넓은 범위의 JSON 패턴
          RegExp(r'\{[\s\S]*?"success"[\s\S]*?"accessToken"[\s\S]*?\}'),
          RegExp(r'\{[\s\S]*?success[\s\S]*?accessToken[\s\S]*?\}'),
          // 가장 넓은 범위
          RegExp(r'\{[\s\S]*success[\s\S]*accessToken[\s\S]*\}'),
          // 백엔드 응답 형식에 맞춘 새로운 패턴
          RegExp(r'\{[^{}]*"success"[^{}]*"message"[^{}]*"accessToken"[^{}]*\}'),
          RegExp(r'\{[^{}]*"success"[^{}]*"accessToken"[^{}]*\}'),
        ];

        for (final pattern in jsonPatterns) {
          final match = pattern.firstMatch(pageText);
          if (match != null) {
            String jsonStr = match.group(0)!;
            print('JSON 패턴 발견: $jsonStr');

            try {
              // JSON 문자열 정규화 (백엔드 응답 형식에 맞춤)
              if (!jsonStr.contains('"success"')) {
                jsonStr = jsonStr
                    .replaceAll(RegExp(r'(\w+):'), r'"\1":')
                    .replaceAll(RegExp(r':([a-zA-Z0-9\.\-_]+)([,}])'), r':"\1"\2')
                    .replaceAll(':"true"', ':true')
                    .replaceAll(':"false"', ':false');
                print('수정된 JSON: $jsonStr');
              }

              final responseData = json.decode(jsonStr);
              print('JSON 디코딩 성공: $responseData');
              
              // 백엔드 응답 형식에 맞춰 OAuthResponse 생성
              final oauthResponse = OAuthResponse(
                success: responseData['success'] ?? false,
                message: responseData['message'] ?? '',
                accessToken: responseData['accessToken'],
                refreshToken: responseData['refreshToken'],
              );
              
              print('OAuthResponse 생성 성공!');
              _handleOAuthResponse(oauthResponse);
              return;
            } catch (e) {
              print('JSON 파싱 실패: $e');
              // 다음 패턴 시도
              continue;
            }
          }
        }



        // 🔥 토큰 패턴 추출 제거 - JSON 우선 처리
        print('JSON 패턴에서 토큰을 찾지 못함 - 성공 처리로 진행');
        
        // 🎯 백엔드 응답에서 직접 토큰 추출 시도
        if (pageText.contains('"accessToken"')) {
          print('🎯 백엔드 응답에서 직접 토큰 추출 시도');
          try {
            // JSON 부분만 추출
            final jsonStart = pageText.indexOf('{');
            final jsonEnd = pageText.lastIndexOf('}');
            
            if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
              final jsonStr = pageText.substring(jsonStart, jsonEnd + 1);
              print('추출된 JSON: $jsonStr');
              
              final responseData = json.decode(jsonStr);
              if (responseData['accessToken'] != null) {
                final oauthResponse = OAuthResponse(
                  success: responseData['success'] ?? false,
                  message: responseData['message'] ?? '',
                  accessToken: responseData['accessToken'],
                  refreshToken: responseData['refreshToken'],
                );
                
                print('✅ 백엔드 응답에서 토큰 추출 성공!');
                _handleOAuthResponse(oauthResponse);
                return;
              }
            }
          } catch (e) {
            print('❌ 백엔드 응답에서 토큰 추출 실패: $e');
          }
        }
        
        _handleSuccessResponse();
        return;
      }

      print('토큰 추출 실패했지만 OAuth callback URL에 도달, 성공으로 처리');
      _handleSuccessResponse();

    } catch (e) {
      print('OAuth 응답 추출 오류: $e');
      print('오류 발생했지만 OAuth 성공 URL이므로 성공 처리');
      _handleSuccessResponse();
    }
  }



  /// 🔥 OAuth 토큰 처리 (즉시 실행, 지연 없음)
  Future<void> _processOAuthToken(String accessToken) async {
    try {
      print('=== OAuth 토큰 즉시 처리 ===');

      // 1. 토큰 저장 (지연 없이)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      print('✅ 토큰 즉시 저장 완료');

      // 2. JWT 파싱 및 사용자 정보 저장 (지연 없이)
      await _parseJWTAndSaveUserInfo(accessToken);

      print('✅ OAuth 토큰 즉시 처리 완료');
    } catch (e) {
      print('❌ OAuth 토큰 처리 실패: $e');
      // 실패해도 throw하지 않음 (AuthWrapper에서 재처리)
    }
  }

  /// 🔥 JWT 토큰 파싱 및 사용자 정보 저장
  Future<void> _parseJWTAndSaveUserInfo(String accessToken) async {
    try {
      print('=== JWT 파싱 시작 ===');
      final displayLength = accessToken.length > 50 ? 50 : accessToken.length;
      print('AccessToken: ${accessToken.substring(0, displayLength)}...');

      final parts = accessToken.split('.');
      if (parts.length != 3) {
        throw Exception('잘못된 JWT 형식');
      }

      // JWT payload 디코딩
      String payload = parts[1];
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      final decodedBytes = base64Decode(payload);
      final decodedString = utf8.decode(decodedBytes);
      print('JWT Payload: $decodedString');

      final payloadData = json.decode(decodedString);

      // 사용자 정보 추출
      final userType = payloadData['userType'] ?? 'PENDING';
      final status = payloadData['status'] ?? 'PENDING';
      final email = payloadData['email'] ?? payloadData['sub'] ?? '';

      print('추출된 정보:');
      print('- UserType: $userType');
      print('- Status: $status');
      print('- Email: $email');

      // 🔥 STAFF/OWNER 타입이면 바로 ACTIVE 상태로 저장
      String finalStatus = status;
      if (userType == 'STAFF' || userType == 'OWNER') {
        finalStatus = 'ACTIVE';
        print('🚀 ${userType} 타입 감지 - 자동으로 ACTIVE 상태로 설정');
      }

      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', userType);
      await prefs.setString('user_status', finalStatus);
      await prefs.setString('user_email', email);

      print('✅ 사용자 정보 저장 완료 - 최종 상태: $finalStatus');

    } catch (e) {
      print('❌ JWT 파싱 실패: $e');
      throw Exception('JWT 토큰 파싱 실패: $e');
    }
  }

  void _handleSuccessResponse() async {
    if (!mounted) return;

    print('✅ OAuth 성공 처리 - 콜백 URL 도달');

    // 🔥 배포 환경에서는 토큰이 서버에서 처리되므로 임시 토큰으로 처리
    final response = OAuthResponse(
      success: true,
      message: 'OAuth 인증이 완료되었습니다. (토큰은 서버에서 처리)',
      accessToken: 'temp_token', // 임시 토큰으로 처리
    );

    Navigator.of(context).pop(response);
  }

  void _handleOAuthResponse(OAuthResponse response) async {
    if (!mounted) return;

    print('=== OAuth 응답 처리 시작 ===');
    print('Success: ${response.success}');
    print('Message: ${response.message}');
    print('Has AccessToken: ${response.accessToken != null}');
    print('Has RefreshToken: ${response.refreshToken != null}');

    // 🔥 실패 응답 처리 (역할 중복 등)
    if (response.success == false) {
      print('❌ OAuth 실패: ${response.message}');
      
      // 인증 만료 등의 특정 오류는 재시도 안내
      String userMessage = response.message ?? '로그인에 실패했습니다.';
      if (userMessage.contains('만료') || userMessage.contains('expired')) {
        userMessage = '로그인 시간이 만료되었습니다. 다시 시도해주세요.';
      }
      
      // 안내 다이얼로그 표시
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('로그인 실패'),
          content: Text(userMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      
      // 실패 응답을 반환하고 화면을 닫음
      Navigator.of(context).pop(response);
      return;
    }

    // 🔥 응답에 토큰이 있으면 JWT 파싱 수행
    if (response.success && response.accessToken != null && response.accessToken != 'temp_token') {
      try {
        print('=== OAuthResponse에서 토큰 처리 시작 ===');
        print('토큰 길이: ${response.accessToken!.length}');
        print('토큰 시작 부분: ${response.accessToken!.substring(0, response.accessToken!.length > 50 ? 50 : response.accessToken!.length)}...');
        
        await _processOAuthToken(response.accessToken!);
        print('✅ OAuthResponse 토큰 처리 완료');
        
        // 백엔드에서 보낸 메시지가 있으면 로그에 기록
        if (response.message != null && response.message!.isNotEmpty) {
          print('📝 백엔드 메시지: ${response.message}');
        }
        
      } catch (e) {
        print('❌ OAuthResponse 토큰 처리 실패: $e');
      }
    } else if (response.success) {
      // 토큰이 없거나 임시 토큰인 경우 (배포 환경)
      print('✅ OAuth 성공 (토큰 없음 또는 임시 토큰) - 서버에서 처리');
      if (response.message != null && response.message!.isNotEmpty) {
        print('📝 백엔드 메시지: ${response.message}');
      }
    }

    Navigator.of(context).pop(response);
  }

  void _handleErrorResponse(String message) {
    if (!mounted) return;

    final response = OAuthResponse(
      success: false,
      message: message,
    );

    Navigator.of(context).pop(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.provider.toUpperCase()} 로그인'),
        backgroundColor: widget.provider == 'kakao' ? const Color(0xFFFFEB3B) : const Color(0xFF2196F3),
        foregroundColor: widget.provider == 'kakao' ? Colors.black : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(OAuthResponse(
              success: false,
              message: '로그인이 취소되었습니다.',
            ));
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: widget.provider == 'kakao' ? const Color(0xFFFFEB3B) : const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.provider.toUpperCase()} 로그인 페이지를 불러오는 중...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}