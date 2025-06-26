// lib/main.dart (경고 완전 제거)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const JejuApp());
}

class JejuApp extends StatelessWidget {
  const JejuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '일하영',
      theme: ThemeData(
        useMaterial3: true,
        // 폰트 설정 제거 - Flutter 기본 폰트 사용 (경고 없음)
      ),
      home: const JejuLoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class JejuLoginScreen extends StatefulWidget {
  const JejuLoginScreen({Key? key}) : super(key: key);

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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

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

            const SizedBox(height: 60),

            // 🎯 사용자 타입 선택
            _buildUserTypeSelector(),

            const Spacer(),

            // 구글 로그인 버튼
            _buildGoogleLoginButton(),

            const SizedBox(height: 30),

            // 하단 링크들
            _buildBottomLinks(),

            const SizedBox(height: 40),

            // 제주 감성 메시지
            _buildJejuMessage(),

            const SizedBox(height: 40),
          ],
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
        padding: const EdgeInsets.symmetric(vertical: 16),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return Container(
      width: double.infinity,
      height: 54,
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
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(
          Icons.g_mobiledata,
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          _isLoading ? '' : 'Google로 시작하기',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTextButton('회원가입'),
        Container(
          width: 1,
          height: 12,
          color: Colors.grey[300],
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        _buildTextButton('문의하기'),
      ],
    );
  }

  Widget _buildTextButton(String text) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$text 기능 준비 중입니다'),
            backgroundColor: _primaryColor,
          ),
        );
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildJejuMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isWorker ? Colors.teal[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _isWorker ? '🌊 제주 바다에서 꿈을 펼치세요' : '🏔️ 현무암 위에서 사업을 키우세요',
            style: TextStyle(
              fontSize: 16,
              color: _primaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isWorker
                ? '청정 제주에서 새로운 시작을 도와드릴게요'
                : '든든한 파트너와 함께 성장해보세요',
            style: TextStyle(
              fontSize: 14,
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

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Text(_isWorker ? '🌊' : '🏔️', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text(
                '로그인 성공!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            '${_isWorker ? "제주 바다만큼 넓은 기회가" : "현무암만큼 든든한 파트너십이"} 기다리고 있어요!',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  '시작하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}