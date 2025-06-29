import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// UserType enum import
import '../../core/enums/user_type.dart';
// 제주 캐러셀 슬라이더 import
import '../../components/jeju/jeju_carousel_slider.dart';

class JejuLoginScreen extends StatefulWidget {
  final Function(UserType)? onLoginSuccess;

  const JejuLoginScreen({Key? key, this.onLoginSuccess}) : super(key: key);

  @override
  State<JejuLoginScreen> createState() => _JejuLoginScreenState();
}

class _JejuLoginScreenState extends State<JejuLoginScreen> {
  bool _isWorker = true;
  bool _isLoading = false;

  // 🎨 제주 색상 테마
  Color get _primaryColor => _isWorker
      ? const Color(0xFF00A3A3)  // 제주 바다색
      : const Color(0xFF2D2D2D);  // 현무암색

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

                // 🎯 사용자 타입 선택
                _buildUserTypeSelector(),

                const SizedBox(height: 24),

                // 🌊 제주 캐러셀 슬라이더
                const JejuCarouselSlider(
                  height: 140,
                  autoPlayDuration: Duration(seconds: 4),
                  showText: false, // 로그인 화면에서는 텍스트 없이 간단하게
                ),

                // 화면 크기에 따른 동적 간격
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                // 구글 로그인 버튼
                _buildGoogleLoginButton(),

                const SizedBox(height: 40), // 간격 조정

                // 제주 감성 메시지
                _buildJejuMessage(),

                // 하단 안전 여백
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            text: '🌊 구직자',
            isSelected: _isWorker,
            onTap: () => setState(() => _isWorker = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeButton(
            text: '🏔️ 자영업자',
            isSelected: !_isWorker,
            onTap: () => setState(() => _isWorker = false),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),  // 16 → 14로 줄임
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,  // 16 → 15로 줄임
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return Container(
      width: double.infinity,
      height: 50,  // 54 → 50으로 줄임
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: _isLoading
            ? const SizedBox(
          width: 18,  // 20 → 18로 줄임
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(
          Icons.g_mobiledata,
          color: Colors.white,
          size: 22,  // 24 → 22로 줄임
        ),
        label: Text(
          _isLoading ? '' : 'Google로 시작하기',
          style: const TextStyle(
            fontSize: 15,  // 16 → 15로 줄임
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildJejuMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),  // 20 → 16으로 줄임
      decoration: BoxDecoration(
        color: _isWorker ? Colors.teal[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _isWorker ? '🌊 제주 바다에서 꿈을 펼치세요' : '🏔️ 현무암 위에서 사업을 키우세요',
            style: TextStyle(
              fontSize: 15,  // 16 → 15로 줄임
              color: _primaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),  // 8 → 6으로 줄임
          Text(
            _isWorker
                ? '청정 제주에서 새로운 시작을 도와드릴게요'
                : '든든한 파트너와 함께 성장해보세요',
            style: TextStyle(
              fontSize: 13,  // 14 → 13으로 줄임
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  @override
  void dispose() {
    super.dispose();
  }
}