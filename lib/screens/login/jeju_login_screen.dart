// lib/screens/login/jeju_login_screen.dart - 정리된 로그인 화면

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

                SizedBox(height: MediaQuery.of(context).size.height * 0.06),

                // 카카오 로그인 버튼
                _buildKakaoLoginButton(),

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

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKakaoLoginButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE812),
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
    );
  }

  // 🎯 카카오 로그인 처리 - 간소화된 버전
  Future<void> _handleKakaoLogin() async {
    if (_isKakaoLoading) return;

    setState(() {
      _isKakaoLoading = true;
    });

    try {
      final userType = _isWorker ? UserType.worker : UserType.employer;
      print('=== 카카오 로그인 시작: $userType ===');

      final result = await OAuthService.signInWithOAuth(
        context: context,
        provider: 'kakao',
        userType: userType,
      );

      if (mounted && result.success) {
        print('✅ 카카오 OAuth 성공');

        // AuthStateProvider에 OAuth 결과 업데이트
        await ref.read(authStateProvider.notifier).updateAfterOAuth(
          accessToken: result.accessToken ?? '',
          userType: userType,
          email: _extractEmailFromToken(result.accessToken),
        );

        // 성공 콜백 호출
        widget.onLoginSuccess(userType);
      } else if (mounted) {
        _showErrorSnackBar('카카오 로그인에 실패했습니다: ${result.message}');
      }
    } catch (e) {
      print('❌ 카카오 로그인 오류: $e');
      if (mounted) {
        _showErrorSnackBar('카카오 로그인 중 오류가 발생했습니다');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isKakaoLoading = false;
        });
      }
    }
  }

  // 🎯 구글 로그인 처리 - 간소화된 버전
  Future<void> _handleGoogleLogin() async {
    if (_isGoogleLoading) return;

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final userType = _isWorker ? UserType.worker : UserType.employer;
      print('=== 구글 로그인 시작: $userType ===');

      final result = await OAuthService.signInWithOAuth(
        context: context,
        provider: 'google',
        userType: userType,
      );

      if (mounted && result.success) {
        print('✅ 구글 OAuth 성공');

        // AuthStateProvider에 OAuth 결과 업데이트
        await ref.read(authStateProvider.notifier).updateAfterOAuth(
          accessToken: result.accessToken ?? '',
          userType: userType,
          email: _extractEmailFromToken(result.accessToken),
        );

        // 성공 콜백 호출
        widget.onLoginSuccess(userType);
      } else if (mounted) {
        _showErrorSnackBar('구글 로그인에 실패했습니다: ${result.message}');
      }
    } catch (e) {
      print('❌ 구글 로그인 오류: $e');
      if (mounted) {
        _showErrorSnackBar('구글 로그인 중 오류가 발생했습니다');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  /// JWT 토큰에서 이메일 추출
  String? _extractEmailFromToken(String? token) {
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

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

  /// 에러 스낵바 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}