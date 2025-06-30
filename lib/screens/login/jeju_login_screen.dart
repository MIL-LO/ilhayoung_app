import 'package:flutter/material.dart';

import '../../core/enums/user_type.dart';
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
  bool _isLoading = false;

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
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                // 구글 로그인 버튼
                GoogleLoginButton(
                  isLoading: _isLoading,
                  isWorker: _isWorker,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 40),

                // 제주 감성 메시지
                JejuMessageCard(isWorker: _isWorker),

                // 하단 안전 여백
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    setState(() {
      _isLoading = true;
    });

    // 2초 후 로그인 성공 콜백 실행
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && widget.onLoginSuccess != null) {
        final userType = _isWorker ? UserType.worker : UserType.employer;
        widget.onLoginSuccess!(userType);
      }
    });
  }
}