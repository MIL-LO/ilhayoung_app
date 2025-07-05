import 'package:flutter/material.dart';

import '../../core/enums/user_type.dart';
import '../../services/auth_service.dart'; // AuthService 추가
import '../../components/jeju/jeju_carousel_slider.dart';
import '../../components/login/user_type_selector.dart';
import '../../components/login/google_login_button.dart';
import '../../components/login/jeju_message_card.dart';

class JejuLoginScreen extends StatefulWidget {
  final Function(UserType)? onLoginSuccess;

  const JejuLoginScreen({Key? key, this.onLoginSuccess}) : super(key: key);

  @override
  State<JejuLoginScreen> createState() => _JejuLoginScreenState();
}

class _JejuLoginScreenState extends State<JejuLoginScreen> {
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
            // 뒤로 가기
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

  // 🔧 수정된 부분: 실제 AuthService 호출
  void _handleKakaoLogin() async {
    if (_isKakaoLoading) return;

    setState(() {
      _isKakaoLoading = true;
    });

    try {
      final userType = _isWorker ? UserType.worker : UserType.employer;

      // 실제 AuthService 호출
      final response = await AuthService.signInWithOAuth(
        context: context,
        provider: 'kakao',
        userType: userType,
      );

      if (mounted) {
        if (response.success && widget.onLoginSuccess != null) {
          // 로그인 성공 시 콜백 호출
          widget.onLoginSuccess!(userType);
        } else {
          // 로그인 실패 처리
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? '로그인에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
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

  // 🔧 수정된 부분: 실제 AuthService 호출
  void _handleGoogleLogin() async {
    if (_isGoogleLoading) return;

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final userType = _isWorker ? UserType.worker : UserType.employer;

      // 실제 AuthService 호출
      final response = await AuthService.signInWithOAuth(
        context: context,
        provider: 'google',
        userType: userType,
      );

      if (mounted) {
        if (response.success && widget.onLoginSuccess != null) {
          // 로그인 성공 시 콜백 호출
          widget.onLoginSuccess!(userType);
        } else {
          // 로그인 실패 처리
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? '로그인에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
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
}