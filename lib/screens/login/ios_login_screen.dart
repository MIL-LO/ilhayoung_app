import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../components/common/ios_text_field.dart';
import '../../components/common/ios_button.dart';
import '../../components/login/ios_user_type_selector.dart';
import '../../components/login/ios_login_header.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class IosLoginScreen extends StatefulWidget {
  const IosLoginScreen({Key? key}) : super(key: key);

  @override
  State<IosLoginScreen> createState() => _IosLoginScreenState();
}

class _IosLoginScreenState extends State<IosLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserType _userType = UserType.worker;
  bool _rememberMe = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.jejuGradient),
        child: Stack(
          children: [
            // 배경 플로팅 요소들
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
      // 플로팅 원들 - iOS 스타일
      Positioned(
        top: 100,
        left: 50,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryOrange.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 150,
        right: 30,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
      ),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: 20,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: ResponsiveHelper.getBlurRadius(context),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          const IosLoginHeader(),

          // 폼 영역
          Padding(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 사용자 타입 선택
                  IosUserTypeSelector(
                    selectedType: _userType,
                    onTypeChanged: (type) {
                      setState(() {
                        _userType = type;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // 이메일 입력
                  IosTextField(
                    label: '이메일',
                    placeholder: 'your@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: CupertinoIcons.mail,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 24),

                  // 비밀번호 입력
                  IosTextField(
                    label: '비밀번호',
                    placeholder: '비밀번호를 입력하세요',
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: CupertinoIcons.lock,
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 20),

                  // 로그인 유지 & 비밀번호 찾기
                  _buildRememberAndForgot(),

                  const SizedBox(height: 32),

                  // 로그인 버튼
                  IosButton(
                    text: _userType == UserType.worker ? '구직자로 시작하기' : '자영업자로 시작하기',
                    style: _userType == UserType.worker ? IosButtonStyle.worker : IosButtonStyle.employer,
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    icon: _userType == UserType.worker ? CupertinoIcons.briefcase : CupertinoIcons.building_2_fill,
                  ),

                  const SizedBox(height: 16),

                  // 또는 구분선
                  _buildOrDivider(),

                  const SizedBox(height: 16),

                  // Apple ID로 로그인 (iOS 스타일)
                  _buildAppleSignIn(),

                  const SizedBox(height: 24),

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
        // 로그인 유지 (iOS 스타일 스위치)
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: CupertinoSwitch(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value;
                  });
                },
                activeColor: _userType == UserType.worker
                    ? AppTheme.primaryBlue
                    : AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '로그인 유지',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                fontFamily: '.SF Pro Text',
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
                  ? AppTheme.primaryBlue
                  : AppTheme.primaryOrange,
              fontFamily: '.SF Pro Text',
              fontWeight: FontWeight.w500,
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
            color: AppTheme.separator,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '또는',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppTheme.separator,
          ),
        ),
      ],
    );
  }

  Widget _buildAppleSignIn() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(14),
        onPressed: _handleAppleSignIn,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apple, // Apple 아이콘 대체
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Apple로 계속하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: '.SF Pro Text',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '계정이 없으신가요? ',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            fontFamily: '.SF Pro Text',
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _handleSignUp,
          child: Text(
            '회원가입',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _userType == UserType.worker
                  ? AppTheme.primaryBlue
                  : AppTheme.primaryOrange,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ),
      ],
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

      // 로그인 로직 구현 예정
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        _showSuccessDialog();
      });
    }
  }

  void _handleAppleSignIn() {
    // Apple Sign In 로직 구현 예정
    _showInfoDialog('Apple로 로그인', 'Apple Sign In 기능을 준비 중입니다.');
  }

  void _handleForgotPassword() {
    _showInfoDialog('비밀번호 찾기', '비밀번호 재설정 링크를 이메일로 보내드릴게요.');
  }

  void _handleSignUp() {
    _showInfoDialog('회원가입', '회원가입 페이지로 이동합니다.');
  }

  void _showSuccessDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          '로그인 성공! 🎉',
          style: TextStyle(
            fontFamily: '.SF Pro Text',
            color: _userType == UserType.worker
                ? AppTheme.primaryBlue
                : AppTheme.primaryOrange,
          ),
        ),
        content: Text(
          '${_userType == UserType.worker ? "구직자" : "자영업자"}로 로그인되었습니다.\n제주에서의 새로운 시작을 응원합니다!',
          style: const TextStyle(fontFamily: '.SF Pro Text'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '확인',
              style: TextStyle(fontFamily: '.SF Pro Text'),
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
          style: const TextStyle(fontFamily: '.SF Pro Text'),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: '.SF Pro Text'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '확인',
              style: TextStyle(fontFamily: '.SF Pro Text'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}