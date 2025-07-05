// lib/screens/oauth/oauth_webview_screen.dart - WebView OAuth 화면
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('OAuth Page Started: $url');
            _checkForCallback(url);
          },
          onPageFinished: (String url) {
            print('OAuth Page Finished: $url');
            setState(() {
              _isLoading = false;
            });
            _checkForCallback(url);
          },
          onWebResourceError: (WebResourceError error) {
            print('OAuth WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  /// OAuth 콜백 URL 확인
  void _checkForCallback(String url) {
    print('Checking URL: $url');

    // OAuth 성공 콜백 패턴 확인
    if (url.contains('oauth/callback') || url.contains('login/oauth2/code')) {
      _extractTokenFromCallback(url);
    }

    // 에러 콜백 패턴 확인
    if (url.contains('error=')) {
      _handleOAuthError(url);
    }
  }

  /// OAuth 콜백에서 토큰 추출
  void _extractTokenFromCallback(String url) async {
    try {
      // URL에서 토큰 정보 추출 또는 서버 API 호출
      final uri = Uri.parse(url);

      // 방법 1: URL 파라미터에서 직접 추출
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];

      if (accessToken != null) {
        // 토큰이 URL에 있는 경우
        _returnSuccess({
          'accessToken': accessToken,
          'refreshToken': refreshToken,
        });
        return;
      }

      // 방법 2: authorization code로 토큰 교환
      final code = uri.queryParameters['code'];
      if (code != null) {
        final tokens = await _exchangeCodeForTokens(code);
        if (tokens != null) {
          _returnSuccess(tokens);
          return;
        }
      }

      // 방법 3: JavaScript로 토큰 정보 가져오기
      final result = await _controller.runJavaScriptReturningResult(
          'JSON.stringify({accessToken: window.accessToken, refreshToken: window.refreshToken})'
      );

      if (result != null && result != 'null') {
        final tokens = json.decode(result.toString());
        if (tokens['accessToken'] != null) {
          _returnSuccess(tokens);
          return;
        }
      }

      print('토큰을 찾을 수 없습니다. URL: $url');

    } catch (e) {
      print('토큰 추출 오류: $e');
      _returnError('토큰 추출 중 오류가 발생했습니다.');
    }
  }

  /// Authorization Code를 토큰으로 교환
  Future<Map<String, dynamic>?> _exchangeCodeForTokens(String code) async {
    try {
      // 백엔드 API 호출하여 토큰 교환
      final response = await http.post(
        Uri.parse('https://ilhayoung.com/api/v1/oauth/token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'code': code,
          'provider': widget.provider,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'accessToken': data['accessToken'],
          'refreshToken': data['refreshToken'],
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

    _returnError(errorDescription ?? error ?? 'OAuth 인증에 실패했습니다.');
  }

  /// 성공 결과 반환
  void _returnSuccess(Map<String, dynamic> tokens) {
    Navigator.pop(context, {
      'success': true,
      'message': 'OAuth 인증 성공',
      'accessToken': tokens['accessToken'],
      'refreshToken': tokens['refreshToken'],
    });
  }

  /// 에러 결과 반환
  void _returnError(String message) {
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
        leading: IconButton(
          icon: Icon(Icons.close),
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
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('${widget.provider} 로그인 페이지를 불러오는 중...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}