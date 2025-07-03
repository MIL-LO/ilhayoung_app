import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/enums/user_type.dart';
import '../../components/common/unified_app_header.dart';
import '../auth/auth_wrapper.dart';
import 'worker_info_input_screen.dart';
import 'employer_info_input_screen.dart';

class MyPageScreen extends StatefulWidget {
  final UserType? userType;
  final Function? onLogout;

  const MyPageScreen({Key? key, this.userType, this.onLogout}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // 사용자 타입을 위젯에서 받거나 기본값 사용
  late UserType _currentUserType;
  String _userName = '김제주';
  String _userEmail = 'kimjeju@gmail.com';
  String _userPhone = '010-1234-5678';
  DateTime _joinDate = DateTime.now().subtract(const Duration(days: 30));
  String _birthDate = '1995년 3월 15일';
  String _address = '제주시 연동';
  String _experience = '카페 서빙 6개월, 음식점 주방 보조 3개월';

  @override
  void initState() {
    super.initState();
    _currentUserType = widget.userType ?? UserType.worker; // 기본값은 구직자
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '마이페이지',
        subtitle: '내 정보를 확인하고 관리하세요',
        emoji: '👤',
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 24),
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildMenuSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _currentUserType == UserType.worker
              ? [const Color(0xFF00A3A3), const Color(0xFF00D4AA)]
              : [const Color(0xFFFF6B35), const Color(0xFFFF8A50)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_currentUserType == UserType.worker
                ? const Color(0xFF00A3A3)
                : const Color(0xFFFF6B35)).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              _currentUserType == UserType.worker ? '🌊' : '🏔️',
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentUserType == UserType.worker ? '구직자' : '자영업자',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 6),
              Text(
                '가입일: ${_joinDate.year}.${_joinDate.month}.${_joinDate.day}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '개인정보',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              GestureDetector(
                onTap: _editUserInfo,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _currentUserType == UserType.worker
                        ? const Color(0xFF00A3A3)
                        : const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        '수정',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.cake, '생년월일', _birthDate),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone, '연락처', _userPhone),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email, '이메일', _userEmail),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.location_on,
            _currentUserType == UserType.worker ? '거주지' : '사업지',
            _address
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.work_outline,
                size: 20,
                color: _currentUserType == UserType.worker
                    ? const Color(0xFF00A3A3)
                    : const Color(0xFFFF6B35),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUserType == UserType.worker ? '경력/경험' : '사업 경험',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _experience,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: _currentUserType == UserType.worker
              ? const Color(0xFF00A3A3)
              : const Color(0xFFFF6B35),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
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
          const Text(
            '설정 및 도움말',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          _buildMenuItem(
            Icons.notifications_outlined,
            '알림 설정',
            '푸시 알림, 이메일 알림 설정',
            () => _showComingSoon('알림 설정'),
          ),
          _buildMenuItem(
            Icons.privacy_tip_outlined,
            '개인정보 처리방침',
            '개인정보 보호 및 이용약관',
            () => _showComingSoon('개인정보 처리방침'),
          ),
          _buildMenuItem(
            Icons.help_outline,
            '고객센터',
            '문의사항 및 지원',
            () => _showCustomerService(),
          ),
          _buildMenuItem(
            Icons.info_outline,
            '앱 정보',
            '버전 1.0.0',
            () => _showAppInfo(),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildMenuItem(
            Icons.logout,
            '로그아웃',
            '계정에서 로그아웃',
            () => _logout(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : (_currentUserType == UserType.worker
                        ? const Color(0xFF00A3A3)
                        : const Color(0xFFFF6B35)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? Colors.red
                    : (_currentUserType == UserType.worker
                        ? const Color(0xFF00A3A3)
                        : const Color(0xFFFF6B35)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // 이벤트 핸들러들
  void _editUserInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          // 사용자 타입에 따라 다른 정보입력 화면으로 이동
          if (_currentUserType == UserType.worker) {
            return WorkerInfoInputScreen(
              onComplete: (userType) {
                Navigator.pop(context);
                _refreshUserData();
              },
            );
          } else {
            return EmployerInfoInputScreen(
              onComplete: (userType) {
                Navigator.pop(context);
                _refreshUserData();
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _refreshUserData() async {
    // 사용자 데이터 새로고침 로직
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        // 실제로는 API에서 데이터를 다시 가져옴
      });
    }
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature 준비 중'),
        content: const Text('해당 기능은 곧 업데이트될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showCustomerService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('고객센터'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📞 전화: 064-123-4567'),
            SizedBox(height: 8),
            Text('📧 이메일: support@jejujob.com'),
            SizedBox(height: 8),
            Text('🕒 운영시간: 평일 09:00-18:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🏝️ 제주 일자리 매칭 앱'),
            SizedBox(height: 8),
            Text('📱 버전: 1.0.0'),
            SizedBox(height: 8),
            Text('🏢 개발: 일하영 팀'),
            SizedBox(height: 8),
            Text('📧 문의: info@jejujob.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // 실제 로그아웃 로직 구현
    HapticFeedback.lightImpact();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthWrapper(),
      ),
      (route) => false,
    );
  }
}