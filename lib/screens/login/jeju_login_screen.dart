// lib/screens/login/jeju_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../core/enums/user_type.dart';
import '../../services/oauth_service.dart';
import '../../providers/auth_state_provider.dart';
import '../../components/jeju/jeju_carousel_slider.dart';
import '../../components/login/user_type_selector.dart';
import '../../components/login/google_login_button.dart';
import '../../components/login/jeju_message_card.dart';

class JejuLoginScreen extends ConsumerStatefulWidget {
  final Function(UserType) onLoginSuccess;

  const JejuLoginScreen({
    Key? key,
    required this.onLoginSuccess,
  }) : super(key: key);

  @override
  ConsumerState<JejuLoginScreen> createState() => _JejuLoginScreenState();
}

class _JejuLoginScreenState extends ConsumerState<JejuLoginScreen> {
  bool _isWorker = true;
  bool _isGoogleLoading = false;
  bool _isKakaoLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // 뒤로 가기 (필요시 구현)
          },
        ),
        title: const Text(
          '일하영',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 적절한 상단 여백
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),

                // 메인 타이틀
                Text(
                  _isWorker
                      ? '제주 바다처럼 넓은\n일자리를 찾아볼까요?'
                      : '현무암처럼 든든한\n인재를 찾아볼까요?',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),

                // 적응형 간격
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                // 사용자 타입 선택
                UserTypeSelector(
                  isWorker: _isWorker,
                  onTypeChanged: (isWorker) {
                    setState(() {
                      _isWorker = isWorker;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // 제주 캐러셀 슬라이더
                const JejuCarouselSlider(
                  height: 140,
                  autoPlayDuration: Duration(seconds: 4),
                  showText: false,
                ),

                // 화면 크기에 따른 동적 간격
                SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                // 카카오 로그인 버튼
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE812), // 카카오 노란색
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFE812).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isKakaoLoading ? null : _handleKakaoLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isKakaoLoading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3A1D1D)),
                      ),
                    )
                        : Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A1D1D),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          'K',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFE812),
                          ),
                        ),
                      ),
                    ),
                    label: Text(
                      _isKakaoLoading ? '' : '카카오로 시작하기',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3A1D1D),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 구글 로그인 버튼
                GoogleLoginButton(
                  isLoading: _isGoogleLoading,
                  isWorker: _isWorker,
                  onPressed: _handleGoogleLogin,
                ),

                const SizedBox(height: 20),

                // 제주 감성 메시지
                JejuMessageCard(isWorker: _isWorker),

                // 하단 안전 여백
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 카카오 로그인 처리 (Riverpod 상태 관리 연동)
  void _handleKakaoLogin() async {
    if (_isKakaoLoading) return;

    setState(() {
      _isKakaoLoading = true;
    });

    try {
      final userType = _isWorker ? UserType.worker : UserType.employer;
      print('=== 카카오 ${_isWorker ? '구직자' : '사업자'} 로그인 시작 ===');

      // OAuth 로그인 실행
      final result = await OAuthService.signInWithOAuth(
        context: context,
        provider: 'kakao',
        userType: userType,
      );

      if (mounted) {
        if (result.success) {
          print('=== 카카오 OAuth 로그인 성공 ===');

          // JWT 토큰에서 이메일 추출
          String? email = _extractEmailFromToken(result.accessToken);

          // AuthState Provider에 OAuth 결과 업데이트
          await ref.read(authStateProvider.notifier).updateAfterOAuth(
            accessToken: result.accessToken ?? '',
            userType: userType,
            email: email,
          );

          // 성공 콜백 호출
          widget.onLoginSuccess(userType);

        } else {
          print('=== 카카오 OAuth 로그인 실패 ===');
          print('오류 메시지: ${result.message}');

          // 실패 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? '카카오 로그인에 실패했습니다'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('=== 카카오 로그인 처리 중 오류 ===');
      print('오류: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('카카오 로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isKakaoLoading = false;
        });
      }
    }
  }

  // 구글 로그인 처리 (Riverpod 상태 관리 연동)
  void _handleGoogleLogin() async {
    if (_isGoogleLoading) return;

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final userType = _isWorker ? UserType.worker : UserType.employer;
      print('=== 구글 ${_isWorker ? '구직자' : '사업자'} 로그인 시작 ===');

      // OAuth 로그인 실행
      final result = await OAuthService.signInWithOAuth(
        context: context,
        provider: 'google',
        userType: userType,
      );

      if (mounted) {
        if (result.success) {
          print('=== 구글 OAuth 로그인 성공 ===');

          // JWT 토큰에서 이메일 추출
          String? email = _extractEmailFromToken(result.accessToken);

          // AuthState Provider에 OAuth 결과 업데이트
          await ref.read(authStateProvider.notifier).updateAfterOAuth(
            accessToken: result.accessToken ?? '',
            userType: userType,
            email: email,
          );

          // 성공 콜백 호출
          widget.onLoginSuccess(userType);

        } else {
          print('=== 구글 OAuth 로그인 실패 ===');
          print('오류 메시지: ${result.message}');

          // 실패 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? '구글 로그인에 실패했습니다'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('=== 구글 로그인 처리 중 오류 ===');
      print('오류: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구글 로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  /// JWT 토큰에서 이메일 추출하는 헬퍼 함수
  String? _extractEmailFromToken(String? token) {
    if (token == null) return null;

    try {
      // JWT 토큰은 header.payload.signature 형식
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // payload 부분 디코딩
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = json.decode(decoded);

      return claims['email'] as String?;
    } catch (e) {
      print('토큰에서 이메일 추출 실패: $e');
      return null;
    }
  }
}