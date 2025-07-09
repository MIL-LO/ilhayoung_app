// lib/screens/login/jeju_login_screen.dart - validate API 활용 버전

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // 🎯 카카오 로그인 처리 - validate API 활용
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
        print('OAuth 결과 데이터: ${result.toString()}');

        // 🎯 핵심: OAuth 결과를 즉시 SharedPreferences에 저장
        await _saveOAuthResult(result, userType);

        // 🎯 핵심: AuthStateProvider에서 validate API로 회원가입 여부 확인
        await ref.read(authStateProvider.notifier).handleOAuthSuccess(userType);

        // AuthWrapper가 자동으로 상태에 따라 화면을 전환할 것임
        print('✅ 카카오 로그인 처리 완료');
      } else if (mounted) {
        print('❌ 카카오 OAuth 실패: ${result.message}');
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

  // 🎯 구글 로그인 처리 - validate API 활용
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
        print('OAuth 결과 데이터: ${result.toString()}');

        // 🎯 핵심: OAuth 결과를 즉시 SharedPreferences에 저장
        await _saveOAuthResult(result, userType);

        // 🎯 핵심: AuthStateProvider에서 validate API로 회원가입 여부 확인
        await ref.read(authStateProvider.notifier).handleOAuthSuccess(userType);

        // AuthWrapper가 자동으로 상태에 따라 화면을 전환할 것임
        print('✅ 구글 로그인 처리 완료');
      } else if (mounted) {
        print('❌ 구글 OAuth 실패: ${result.message}');
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

  /// 🎯 OAuth 결과를 SharedPreferences에 저장 (validate API 활용 준비)
  Future<void> _saveOAuthResult(dynamic result, UserType userType) async {
    try {
      print('=== 🔐 OAuth 토큰 저장 시작 (validate API 활용 준비) ===');
      final prefs = await SharedPreferences.getInstance();

      // 1️⃣ 액세스 토큰 저장 (안전한 방법)
      String? accessToken;

      try {
        // result 객체에서 토큰 추출 시도 (hasAccessToken으로 확인)
        if (result.hasAccessToken && result.accessToken != null && result.accessToken.isNotEmpty) {
          accessToken = result.accessToken;
          print('✅ result.accessToken에서 토큰 발견: ${accessToken?.substring(0, 20)}...');
        }
      } catch (e) {
        print('⚠️ result.accessToken 접근 실패: $e');
      }

      // result가 Map인 경우도 확인
      if (accessToken == null && result is Map) {
        if (result['access_token'] != null) {
          accessToken = result['access_token'].toString();
        } else if (result['accessToken'] != null) {
          accessToken = result['accessToken'].toString();
        }
      }

      if (accessToken != null && accessToken.isNotEmpty) {
        await prefs.setString('access_token', accessToken);
        print('✅ 액세스 토큰 저장 완료: ${accessToken.substring(0, 20)}...');
      } else {
        print('❌ OAuth 결과에서 토큰을 찾을 수 없음');
        return; // 토큰이 없으면 저장 중단
      }

      // 2️⃣ 리프레시 토큰 저장 (안전한 방법)
      try {
        if (result.hasRefreshToken && result.refreshToken != null && result.refreshToken.isNotEmpty) {
          await prefs.setString('refresh_token', result.refreshToken);
          print('✅ 리프레시 토큰 저장 완료');
        }
      } catch (e) {
        print('⚠️ result.refreshToken 접근 실패: $e');
        // Map에서 확인
        if (result is Map && result['refresh_token'] != null) {
          await prefs.setString('refresh_token', result['refresh_token'].toString());
          print('✅ 리프레시 토큰 저장 완료 (Map에서)');
        }
      }

      // 3️⃣ 사용자 타입 저장
      final userTypeString = userType == UserType.worker ? 'STAFF' : 'MANAGER';
      await prefs.setString('user_type', userTypeString);
      print('✅ 사용자 타입 저장: $userTypeString');

      // 4️⃣ 이메일 저장 (토큰에서 추출)
      final email = _extractEmailFromToken(accessToken);
      if (email != null && email.isNotEmpty) {
        await prefs.setString('user_email', email);
        print('✅ 이메일 저장: $email');
      } else {
        print('⚠️ 토큰에서 이메일을 추출할 수 없음');
      }

      // 5️⃣ 🎯 핵심: 초기 상태를 PENDING으로 설정 (validate API가 실제 상태 결정)
      // JWT의 status는 OAuth 성공을 의미할 뿐, 실제 회원가입 완료를 의미하지 않음
      await prefs.setString('user_status', 'PENDING');
      print('📋 초기 상태를 PENDING으로 설정 - validate API가 실제 상태 결정');

      // 6️⃣ 저장 확인
      final savedToken = prefs.getString('access_token');
      final savedType = prefs.getString('user_type');
      final savedEmail = prefs.getString('user_email');
      final savedStatus = prefs.getString('user_status');

      print('=== 저장 확인 ===');
      print('저장된 토큰: ${savedToken != null ? "${savedToken.substring(0, 20)}..." : "없음"}');
      print('저장된 타입: $savedType');
      print('저장된 이메일: $savedEmail');
      print('저장된 상태: $savedStatus');
      print('=== OAuth 토큰 저장 완료 (validate API 검증 대기) ===');

    } catch (e) {
      print('❌ OAuth 결과 저장 실패: $e');
      print('에러 스택 트레이스: ${StackTrace.current}');
      // 오류가 발생해도 계속 진행 (토큰은 이미 저장됨)
    }
  }

  /// JWT 토큰에서 이메일 추출
  String? _extractEmailFromToken(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      // JWT 토큰 형식 확인 (3개 부분으로 구성)
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ JWT 토큰 형식이 아님: ${parts.length}개 부분');
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = json.decode(decoded);

      print('🔍 토큰 페이로드 확인: ${claims.keys.toList()}');

      // 다양한 이메일 필드명 확인
      String? email;
      if (claims['email'] != null) {
        email = claims['email'] as String?;
      } else if (claims['user_email'] != null) {
        email = claims['user_email'] as String?;
      } else if (claims['mail'] != null) {
        email = claims['mail'] as String?;
      }

      if (email != null) {
        print('✅ 토큰에서 이메일 추출 성공: $email');
      } else {
        print('❌ 토큰에서 이메일을 찾을 수 없음');
      }

      return email;
    } catch (e) {
      print('❌ 토큰에서 이메일 추출 실패: $e');
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
        duration: const Duration(seconds: 3),
      ),
    );
  }
}