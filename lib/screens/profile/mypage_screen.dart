import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/enums/user_type.dart';
import '../../components/common/unified_app_header.dart';
import '../../services/auth_service.dart'; // AuthService import 추가

class MyPageScreen extends StatefulWidget {
  final UserType userType;
  final Function? onLogout;

  const MyPageScreen({
    Key? key,
    required this.userType,
    this.onLogout,
  }) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoggingOut = false; // 로그아웃 상태 변수 추가

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmployer = widget.userType == UserType.employer;
    final Color primaryColor = isEmployer
        ? const Color(0xFF2D3748) // 사업자용 현무암색
        : const Color(0xFF00A3A3); // 구직자용 제주 바다색

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '마이페이지',
        subtitle: isEmployer ? '사업자 정보 관리' : '내 정보 관리',
        emoji: isEmployer ? '🏢' : '👤',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileCard(primaryColor, isEmployer),
              const SizedBox(height: 24),
              _buildMenuSection(primaryColor, isEmployer),
              const SizedBox(height: 24),
              _buildSettingsSection(primaryColor),
              const SizedBox(height: 32),
              _buildLogoutButton(primaryColor),
              const SizedBox(height: 100), // 네비게이션 바 여백
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(Color primaryColor, bool isEmployer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEmployer
              ? [const Color(0xFF2D3748), const Color(0xFF4A5568)] // 사업자용
              : [const Color(0xFF00A3A3), const Color(0xFF00B8B8)], // 구직자용
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              isEmployer ? Icons.business : Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            isEmployer ? '김사업자' : '홍길동',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            isEmployer ? '제주카페 대표' : '구직자',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),

          if (isEmployer) ...[
            Row(
              children: [
                Expanded(
                  child: _buildProfileStat('활성 공고', '3', Icons.work),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProfileStat('근무자', '8', Icons.people),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildProfileStat('지원 완료', '12', Icons.send),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProfileStat('진행 중', '3', Icons.schedule),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(Color primaryColor, bool isEmployer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEmployer ? '사업자 메뉴' : '내 활동',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          if (isEmployer) ...[
            _buildMenuItem(
              '내 공고 관리',
              '등록된 공고를 확인하고 관리하세요',
              Icons.work_outline,
              primaryColor,
                  () => _showFeatureDialog('내 공고 관리'),
            ),
            _buildMenuItem(
              '지원자 관리',
              '지원자 현황을 확인하고 관리하세요',
              Icons.people_outline,
              primaryColor,
                  () => _showFeatureDialog('지원자 관리'),
            ),
            _buildMenuItem(
              '급여 관리',
              '근무자 급여를 계산하고 관리하세요',
              Icons.account_balance_wallet_outlined,
              primaryColor,
                  () => _showFeatureDialog('급여 관리'),
            ),
            _buildMenuItem(
              '사업장 정보',
              '사업장 정보를 수정하세요',
              Icons.store_outlined,
              primaryColor,
                  () => _showFeatureDialog('사업장 정보'),
            ),
          ] else ...[
            _buildMenuItem(
              '지원 내역',
              '내가 지원한 공고를 확인하세요',
              Icons.send_outlined,
              primaryColor,
                  () => _showFeatureDialog('지원 내역'),
            ),
            _buildMenuItem(
              '근무 내역',
              '내 근무 기록을 확인하세요',
              Icons.schedule_outlined,
              primaryColor,
                  () => _showFeatureDialog('근무 내역'),
            ),
            _buildMenuItem(
              '급여 내역',
              '급여 지급 내역을 확인하세요',
              Icons.account_balance_wallet_outlined,
              primaryColor,
                  () => _showFeatureDialog('급여 내역'),
            ),
            _buildMenuItem(
              '개인 정보',
              '개인 정보를 수정하세요',
              Icons.person_outline,
              primaryColor,
                  () => _showFeatureDialog('개인 정보'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          _buildMenuItem(
            '알림 설정',
            '알림 수신 설정을 변경하세요',
            Icons.notifications_outlined,
            primaryColor,
                () => _showFeatureDialog('알림 설정'),
          ),
          _buildMenuItem(
            '계정 설정',
            '비밀번호 변경 및 계정 관리',
            Icons.security_outlined,
            primaryColor,
                () => _showFeatureDialog('계정 설정'),
          ),
          _buildMenuItem(
            '고객센터',
            '문의사항이나 도움이 필요하시면 연락하세요',
            Icons.help_outline,
            primaryColor,
                () => _showFeatureDialog('고객센터'),
          ),
          _buildMenuItem(
            '앱 정보',
            '버전 정보 및 이용약관',
            Icons.info_outline,
            primaryColor,
                () => _showFeatureDialog('앱 정보'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(Color primaryColor) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoggingOut ? null : _handleLogout, // 로딩 중일 때 비활성화
          child: Center(
            child: _isLoggingOut
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '로그아웃 중...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeatureDialog(String feature) {
    final bool isEmployer = widget.userType == UserType.employer;
    final Color primaryColor = isEmployer
        ? const Color(0xFF2D3748)
        : const Color(0xFF00A3A3);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.construction,
              color: primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('준비 중'),
          ],
        ),
        content: Text('$feature 기능은 곧 추가될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    final bool isEmployer = widget.userType == UserType.employer;
    final Color primaryColor = isEmployer
        ? const Color(0xFF2D3748)
        : const Color(0xFF00A3A3);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // 로그아웃 진행 중 상태 표시
              setState(() {
                _isLoggingOut = true;
              });

              try {
                // 서버 + 카카오 로그아웃 API 호출
                final success = await AuthService.logout();

                // 스낵바 메시지 표시 (화면이 사라지기 전에)
                if (mounted) {
                  String message;
                  Color backgroundColor;

                  if (success) {
                    message = '로그아웃되었습니다';
                    backgroundColor = primaryColor;
                  } else {
                    message = '로그아웃되었습니다 (일부 서버 연결 오류)';
                    backgroundColor = Colors.orange;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: backgroundColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(milliseconds: 1500), // 짧게 표시
                    ),
                  );
                }

                // 잠깐 기다린 후 로그아웃 콜백 실행 (스낵바가 표시된 후)
                await Future.delayed(const Duration(milliseconds: 500));

                if (widget.onLogout != null) {
                  widget.onLogout!();
                }

              } catch (e) {
                // 완전히 실패한 경우도 일단 로그아웃 처리
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('로그아웃 중 오류가 발생했지만 로그아웃됩니다'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: const Duration(milliseconds: 1500),
                    ),
                  );
                }

                // 오류가 발생해도 로그아웃 콜백 실행
                await Future.delayed(const Duration(milliseconds: 500));
                if (widget.onLogout != null) {
                  widget.onLogout!();
                }
              } finally {
                // 로딩 상태 해제
                if (mounted) {
                  setState(() {
                    _isLoggingOut = false;
                  });
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}