// lib/services/oauth_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
      final role = userType == UserType.worker ? 'STAFF' : 'OWNER';
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
      final uri = Uri.parse(url);

      // 백엔드 호스트이고 OAuth 콜백 경로인지 확인
      final isBackendHost = uri.host == 'ilhayoung.com';
      final isCallbackPath = uri.path.contains('/login/oauth2/code/') ||
          uri.path.contains('/oauth/callback') ||
          uri.path.contains('/login/success');

      print('Host: ${uri.host}, Path: ${uri.path}');
      print('Backend Host: $isBackendHost, Callback Path: $isCallbackPath');

      if (isBackendHost && isCallbackPath) {
        print('성공 URL 감지');
        _hasFoundResult = true;
        _extractOAuthResponse();
        return;
      }

      // 에러 파라미터 처리
      if (uri.queryParameters.containsKey('error')) {
        print('오류 URL 감지: ${uri.queryParameters['error']}');
        _handleErrorResponse(uri.queryParameters['error_description'] ??
            uri.queryParameters['error'] ??
            'OAuth 인증에 실패했습니다.');
        return;
      }

    } catch (e) {
      print('URL 파싱 오류: $e');
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
        pageText = result?.toString() ?? '';
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

        // 패턴 1: JSON 형태의 응답 찾기
        final jsonPatterns = [
          RegExp(r'\{[^}]*"success"[^}]*"accessToken"[^}]*\}'),
          RegExp(r'\{[^}]*success[^}]*accessToken[^}]*\}'),
          RegExp(r'\{[\s\S]*success[\s\S]*accessToken[\s\S]*\}'),
        ];

        for (final pattern in jsonPatterns) {
          final match = pattern.firstMatch(pageText);
          if (match != null) {
            String jsonStr = match.group(0)!;
            print('JSON 패턴 발견: $jsonStr');

            try {
              if (!jsonStr.contains('"success"')) {
                jsonStr = jsonStr
                    .replaceAll(RegExp(r'(\w+):'), r'"\1":')
                    .replaceAll(RegExp(r':([a-zA-Z0-9\.\-_]+)([,}])'), r':"\1"\2')
                    .replaceAll(':"true"', ':true')
                    .replaceAll(':"false"', ':false');
                print('수정된 JSON: $jsonStr');
              }

              final responseData = json.decode(jsonStr);
              final oauthResponse = OAuthResponse.fromJson(responseData);
              print('JSON 파싱 성공!');
              _handleOAuthResponse(oauthResponse);
              return;
            } catch (e) {
              print('JSON 파싱 실패: $e');
            }
          }
        }

        // 패턴 2: 토큰만 직접 추출
        final tokenPatterns = [
          RegExp(r'"accessToken"\s*:\s*"([^"]+)"'),
          RegExp(r'accessToken\s*:\s*"([^"]+)"'),
          RegExp(r'accessToken["\s]*:["\s]*([a-zA-Z0-9\.\-_]+)'),
          RegExp(r'eyJ[a-zA-Z0-9\.\-_]{20,}'),
          RegExp(r'"accessToken"[^"]*"([^"]{50,})"'),
          RegExp(r'accessToken[^"]*([a-zA-Z0-9\.\-_]{50,})'),
        ];

        for (int i = 0; i < tokenPatterns.length; i++) {
          final pattern = tokenPatterns[i];
          final matches = pattern.allMatches(pageText);

          for (final match in matches) {
            final token = match.group(1) ?? match.group(0);
            if (token != null && token.length > 20) {
              print('토큰 패턴 ${i + 1}로 추출 성공: ${token.substring(0, 30)}...');
              _handleTokenResponse(token);
              return;
            }
          }
        }

        // 패턴 3: JWT 형태 찾기
        final jwtMatches = RegExp(r'eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+').allMatches(pageText);
        for (final match in jwtMatches) {
          final token = match.group(0);
          if (token != null && token.length > 50) {
            print('JWT 형태 토큰 발견: ${token.substring(0, 30)}...');
            _handleTokenResponse(token);
            return;
          }
        }

        print('=== 모든 토큰 추출 패턴 실패 ===');
        print('페이지에 success가 있는가: ${pageText.toLowerCase().contains('success')}');
        print('페이지에 accessToken이 있는가: ${pageText.toLowerCase().contains('accesstoken')}');
        print('페이지에 token이 있는가: ${pageText.toLowerCase().contains('token')}');

        print('실제 토큰 추출 실패 - 백엔드 페이지 형식 확인 필요');
        _handleErrorResponse('백엔드에서 토큰을 찾을 수 없습니다. 페이지 내용을 확인해주세요.');
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

  void _handleTokenResponse(String token) {
    if (!mounted) return;

    final response = OAuthResponse(
      success: true,
      message: 'OAuth 인증이 완료되었습니다.',
      accessToken: token,
    );

    Navigator.of(context).pop(response);
  }

  void _handleSuccessResponse() {
    if (!mounted) return;

    print('OAuth 성공 처리 - 실제 토큰 없이 성공으로 처리');

    final response = OAuthResponse(
      success: true,
      message: 'OAuth 인증이 완료되었습니다. 회원가입을 진행해주세요.',
      accessToken: null, // 실제 토큰이 없으면 null로 설정
    );

    Navigator.of(context).pop(response);
  }

  void _handleOAuthResponse(OAuthResponse response) {
    if (!mounted) return;
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