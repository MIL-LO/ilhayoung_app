import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../components/jeju/jeju_button.dart';
import '../../components/jeju/jeju_login_header.dart';
import '../../components/jeju/jeju_text_field.dart';
import '../../components/jeju/jeju_user_type_selector.dart';
import '../../core/theme/app_theme.dart';

import '../../core/utils/responsive_helper.dart';

class JejuLoginScreen extends StatefulWidget {
  const JejuLoginScreen({Key? key}) : super(key: key);

  @override
  State<JejuLoginScreen> createState() => _JejuLoginScreenState();
}

class _JejuLoginScreenState extends State<JejuLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserType _userType = UserType.worker;
  bool _rememberMe = false;
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // 메인 애니메이션
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 플로팅 요소 애니메이션
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 시작
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: JejuTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // 배경 플로팅 요소들 (현무암과 바다 모티브)
            ..._buildFloatingElements(context),

            // 메인 콘텐츠
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.getScreenPadding(context),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveHelper.getMaxWidth(context),
                        ),
                        child: _buildLoginCard(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements(BuildContext context) {
    return [
      // 현무암 형태의 플로팅 요소들
      AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Positioned(
            top: 80 + _floatingAnimation.value,
            left: 40,
            child: Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    JejuTheme.basaltMedium.withOpacity(0.1),
                    JejuTheme.basaltDark.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: JejuTheme.basaltLight.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),

      // 에메랄드 바다 모티브
      AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Positioned(
            bottom: 120 - _floatingAnimation.value * 0.5,
            right: 50,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    JejuTheme.emeraldLight.withOpacity(0.15),
                    JejuTheme.emeraldBright.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: JejuTheme.emeraldBright.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),

      // 제주 감귤 모티브
      AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Positioned(
            top: MediaQuery.of(context).size.height * 0.35 + _floatingAnimation.value * 0.3,
            left: 30,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    JejuTheme.tangerineOrange.withOpacity(0.2),
                    JejuTheme.sunsetOrange.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: JejuTheme.tangerineOrange.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),

      // 하늘색 구름 모티브
      AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Positioned(
            top: 150 - _floatingAnimation.value * 0.8,
            right: 20,
            child: Container(
              width: 70,
              height: 35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    JejuTheme.skyBlue.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(17.5),
                border: Border.all(
                  color: JejuTheme.skyBlue.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: JejuTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: JejuTheme.basaltDark.withOpacity(0.1),
            blurRadius: ResponsiveHelper.getBlurRadius(context),
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: JejuTheme.emeraldBright.withOpacity(0.05),
            blurRadius: ResponsiveHelper.getBlurRadius(context) * 2,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          const JejuLoginHeader(),

          // 폼 영역
          Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 사용자 타입 선택
                  JejuUserTypeSelector(
                    selectedType: _userType,
                    onTypeChanged: (type) {
                      setState(() {
                        _userType = type;
                      });
                      // 햅틱 피드백
                      HapticFeedback.selectionClick();
                    },
                  ),

                  const SizedBox(height: 32),

                  // 이메일 입력
                  JejuTextField(
                    label: '이메일',
                    placeholder: 'your@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: CupertinoIcons.mail_solid,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 24),

                  // 비밀번호 입력
                  JejuTextField(
                    label: '비밀번호',
                    placeholder: '안전한 비밀번호를 입력하세요',
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: CupertinoIcons.lock_fill,
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 24),

                  // 로그인 유지 & 비밀번호 찾기
                  _buildRememberAndForgot(),

                  const SizedBox(height: 32),

                  // 로그인 버튼
                  JejuButton(
                    text: _userType == UserType.worker ? '구직자로 시작하기' : '자영업자로 시작하기',
                    style: _userType == UserType.worker ? JejuButtonStyle.ocean : JejuButtonStyle.sunset,
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    icon: _userType == UserType.worker ? CupertinoIcons.briefcase_fill : CupertinoIcons.building_2_fill,
                  ),

                  const SizedBox(height: 20),

                  // 또는 구분선
                  _buildOrDivider(),

                  const SizedBox(height: 20),

                  // Apple ID로 로그인
                  _buildAppleSignIn(),

                  const SizedBox(height: 28),

                  // 회원가입 링크
                  _buildSignUpLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 로그인 유지
        Row(
          children: [
            Transform.scale(
              scale: 0.85,
              child: CupertinoSwitch(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value;
                  });
                  HapticFeedback.selectionClick();
                },
                activeColor: _userType == UserType.worker
                    ? JejuTheme.emeraldBright
                    : JejuTheme.sunsetOrange,
                trackColor: JejuTheme.stoneBeige,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '로그인 유지',
              style: TextStyle(
                fontSize: 15,
                color: JejuTheme.basaltMedium,
                fontFamily: '.SF Pro Text',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        // 비밀번호 찾기
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _handleForgotPassword,
          child: Text(
            '비밀번호 찾기',
            style: TextStyle(
              fontSize: 15,
              color: _userType == UserType.worker
                  ? JejuTheme.emeraldBright
                  : JejuTheme.sunsetOrange,
              fontFamily: '.SF Pro Text',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  JejuTheme.basaltLight.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: JejuTheme.stoneBeige.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: JejuTheme.basaltLight.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Text(
              '또는',
              style: TextStyle(
                fontSize: 14,
                color: JejuTheme.basaltMedium,
                fontFamily: '.SF Pro Text',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  JejuTheme.basaltLight.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppleSignIn() {
    return JejuButton(
      text: 'Apple로 계속하기',
      style: JejuButtonStyle.basalt,
      onPressed: _handleAppleSignIn,
      icon: Icons.apple,
      height: 52,
    );
  }

  Widget _buildSignUpLink() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            JejuTheme.stoneBeige.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: JejuTheme.basaltLight.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '아직 계정이 없으신가요? ',
            style: TextStyle(
              fontSize: 15,
              color: JejuTheme.basaltMedium,
              fontFamily: '.SF Pro Text',
              fontWeight: FontWeight.w400,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _handleSignUp,
            child: Text(
              '회원가입',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _userType == UserType.worker
                    ? JejuTheme.emeraldBright
                    : JejuTheme.sunsetOrange,
                fontFamily: '.SF Pro Text',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 유효성 검사 함수들
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '올바른 이메일 형식을 입력해주세요';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다';
    }
    return null;
  }

  // 이벤트 핸들러들
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 햅틱 피드백
      HapticFeedback.mediumImpact();

      // 로그인 로직 구현 예정
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        _showSuccessDialog();
      });
    } else {
      HapticFeedback.heavyImpact();  // 강한 진동으로 에러 표현
    }
  }

  void _handleAppleSignIn() {
    HapticFeedback.selectionClick();
    _showInfoDialog('Apple로 로그인', 'Apple Sign In 기능을 준비 중입니다.');
  }

  void _handleForgotPassword() {
    HapticFeedback.selectionClick();
    _showInfoDialog('비밀번호 찾기', '비밀번호 재설정 링크를 이메일로 보내드릴게요.');
  }

  void _handleSignUp() {
    HapticFeedback.selectionClick();
    _showInfoDialog('회원가입', '회원가입 페이지로 이동합니다.');
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          '로그인 성공! 🌊',
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            color: _userType == UserType.worker
                ? JejuTheme.emeraldBright
                : JejuTheme.sunsetOrange,
          ),
        ),
        content: Text(
          '${_userType == UserType.worker ? "구직자" : "자영업자"}로 로그인되었습니다.\n제주에서의 새로운 시작을 응원합니다!',
          style: const TextStyle(
            fontFamily: '.SF Pro Text',
            color: JejuTheme.basaltDark,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                color: _userType == UserType.worker
                    ? JejuTheme.emeraldBright
                    : JejuTheme.sunsetOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: '.SF Pro Text',
            color: JejuTheme.basaltDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: '.SF Pro Text',
            color: JejuTheme.basaltMedium,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '확인',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                color: JejuTheme.emeraldBright,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}