// lib/screens/oauth/oauth_webview_screen.dart - 수정된 WebView OAuth 화면
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../../config/app_config.dart'; // 🔥 AppConfig import 추가

class OAuthWebViewScreen extends StatefulWidget {
  final String url;
  final String provider;

  const OAuthWebViewScreen({
    Key? key,
    required this.url,
    required this.provider,
  }) : super(key: key);

  @override
  State<OAuthWebViewScreen> createState() => _OAuthWebViewScreenState();
}

class _OAuthWebViewScreenState extends State<OAuthWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Page started loading: $url');
            _checkForCallback(url);
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
            _checkForCallback(url);
            _tryExtractTokenFromPage();
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation request: ${request.url}');
            _checkForCallback(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            print('OAuth WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  /// OAuth 콜백 URL 확인 (수정된 버전)
  void _checkForCallback(String url) {
    print('URL 체크: $url');

    try {
      final uri = Uri.parse(url);

      // 🔥 API 서버 호스트로 변경 (api.ilhayoung.com)
      final isBackendHost = uri.host == 'api.ilhayoung.com';

      // 2️⃣ 경로가 실제 콜백 패턴인지 확인 (쿼리스트링 제외)
      final isCallbackPath = uri.path.contains('/login/oauth2/code/') ||
          uri.path.contains('/oauth/callback') ||
          uri.path.contains('/login/success');

      print('Host: ${uri.host}, Path: ${uri.path}');
      print('Backend Host: $isBackendHost, Callback Path: $isCallbackPath');

      if (isBackendHost && isCallbackPath) {
        print('성공 URL 감지');
        _extractTokenFromCallback(url);
        return;
      }

      // 에러 파라미터 처리
      if (uri.queryParameters.containsKey('error')) {
        print('오류 URL 감지: ${uri.queryParameters['error']}');
        _handleOAuthError(url);
        return;
      }

    } catch (e) {
      print('URL 파싱 오류: $e');
    }
  }

  /// OAuth 콜백에서 토큰 추출 (수정된 버전)
  void _extractTokenFromCallback(String url) async {
    try {
      final uri = Uri.parse(url);

      // 방법 1: URL 쿼리 파라미터에서 직접 토큰 추출
      final accessToken = uri.queryParameters['token'] ?? uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh'] ?? uri.queryParameters['refresh_token'];

      print('URL 파라미터 토큰 확인: access=$accessToken, refresh=$refreshToken');

      if (accessToken != null) {
        print('토큰을 URL 파라미터에서 찾음');
        _returnSuccess({
          'accessToken': accessToken,
          'refreshToken': refreshToken,
        });
        return;
      }

      // 방법 2: authorization code로 토큰 교환
      final code = uri.queryParameters['code'];
      if (code != null) {
        print('Authorization code 발견: $code');
        final tokens = await _exchangeCodeForTokens(code);
        if (tokens != null) {
          _returnSuccess(tokens);
          return;
        }
      }

      // 방법 3: 페이지에서 토큰 추출 시도
      print('페이지에서 토큰 추출 시도');
      await _tryExtractTokenFromPage();

    } catch (e) {
      print('토큰 추출 오류: $e');
      _returnError('토큰 추출 중 오류가 발생했습니다: $e');
    }
  }

  /// 페이지에서 토큰 추출 시도
  Future<void> _tryExtractTokenFromPage() async {
    try {
      // 페이지 텍스트 추출
      final pageText = await _controller.runJavaScriptReturningResult(
          'document.body.innerText || document.body.textContent || ""'
      );

      print('페이지 텍스트 추출 성공: ${pageText.toString().substring(0, pageText.toString().length > 100 ? 100 : pageText.toString().length)}...');

      // JSON 형태의 토큰 찾기
      if (pageText.toString().contains('AccessToken') || pageText.toString().contains('access_token')) {
        // 정규식으로 토큰 패턴 찾기
        final tokenRegex = RegExp(r'AccessToken[=:]\s*([^,\s\}]+)');
        final refreshRegex = RegExp(r'RefreshToken[=:]\s*([^,\s\}]+)');

        final tokenMatch = tokenRegex.firstMatch(pageText.toString());
        final refreshMatch = refreshRegex.firstMatch(pageText.toString());

        if (tokenMatch != null) {
          final accessToken = tokenMatch.group(1)?.replaceAll('"', '');
          final refreshToken = refreshMatch?.group(1)?.replaceAll('"', '');

          print('정규식으로 토큰 추출: access=$accessToken');

          _returnSuccess({
            'accessToken': accessToken,
            'refreshToken': refreshToken,
          });
          return;
        }
      }

      // JavaScript 변수에서 토큰 추출 시도
      final jsResult = await _controller.runJavaScriptReturningResult(
          '''
          (function() {
            try {
              if (window.accessToken) return JSON.stringify({accessToken: window.accessToken, refreshToken: window.refreshToken});
              if (window.tokens) return JSON.stringify(window.tokens);
              if (window.authResult) return JSON.stringify(window.authResult);
              return null;
            } catch(e) {
              return null;
            }
          })()
          '''
      );

      if (jsResult != null && jsResult.toString() != 'null' && jsResult.toString().isNotEmpty) {
        final tokens = json.decode(jsResult.toString().replaceAll('"', ''));
        if (tokens['accessToken'] != null) {
          print('JavaScript에서 토큰 추출 성공');
          _returnSuccess(tokens);
          return;
        }
      }

      // 현재 URL이 콜백 URL이라면 성공으로 처리 (토큰은 나중에 서버에서 가져오기)
      final currentUrl = await _controller.currentUrl();
      if (currentUrl != null && currentUrl.contains('login/oauth2/code')) {
        print('토큰 추출 실패했지만 OAuth callback URL에 도달, 성공으로 처리');
        _returnSuccess({'message': 'OAuth 인증 완료'});
      }

    } catch (e) {
      print('페이지 토큰 추출 실패: $e');
    }
  }

  /// Authorization Code를 토큰으로 교환
  Future<Map<String, dynamic>?> _exchangeCodeForTokens(String code) async {
    try {
      print('토큰 교환 API 호출 시작');

      // 🔥 AppConfig를 사용하여 API URL 구성
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/oauth/token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'code': code,
          'provider': widget.provider,
        }),
      );

      print('토큰 교환 응답: ${response.statusCode}');
      print('토큰 교환 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'accessToken': data['accessToken'] ?? data['access_token'],
          'refreshToken': data['refreshToken'] ?? data['refresh_token'],
        };
      }

      print('토큰 교환 실패: ${response.statusCode}');
      return null;

    } catch (e) {
      print('토큰 교환 오류: $e');
      return null;
    }
  }

  /// OAuth 에러 처리
  void _handleOAuthError(String url) {
    final uri = Uri.parse(url);
    final error = uri.queryParameters['error'];
    final errorDescription = uri.queryParameters['error_description'];

    print('OAuth 에러: $error - $errorDescription');
    _returnError(errorDescription ?? error ?? 'OAuth 인증에 실패했습니다.');
  }

  /// 성공 결과 반환
  void _returnSuccess(Map<String, dynamic> result) {
    print('OAuth 성공 결과 반환: $result');
    Navigator.pop(context, {
      'success': true,
      'message': result['message'] ?? 'OAuth 인증 성공',
      'accessToken': result['accessToken'],
      'refreshToken': result['refreshToken'],
    });
  }

  /// 에러 결과 반환
  void _returnError(String message) {
    print('OAuth 에러 결과 반환: $message');
    Navigator.pop(context, {
      'success': false,
      'message': message,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.provider} 로그인'),
        backgroundColor: widget.provider == 'kakao' ? Colors.yellow : Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, {
            'success': false,
            'message': '사용자가 로그인을 취소했습니다.',
          }),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.provider} 로그인 페이지를 불러오는 중...',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}