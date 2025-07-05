// lib/screens/employer/main/employer_main_wrapper.dart

import 'package:flutter/material.dart';
import '../../../core/enums/user_type.dart';
import '../../profile/mypage_screen.dart';
import 'employer_main_screen.dart';
import '../jobs/unified_employer_job_screen.dart';
import '../../../components/navigation/jeju_employer_navbar.dart';

class EmployerMainWrapper extends StatefulWidget {
  final VoidCallback? onLogout; // 로그아웃 콜백 추가

  const EmployerMainWrapper({
    Key? key,
    this.onLogout, // 옵셔널 파라미터로 추가
  }) : super(key: key);

  @override
  State<EmployerMainWrapper> createState() => _EmployerMainWrapperState();
}

class _EmployerMainWrapperState extends State<EmployerMainWrapper> {
  EmployerNavTab _selectedTab = EmployerNavTab.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: JejuEmployerNavBar(
        selectedTab: _selectedTab,
        onTabChanged: (tab) {
          setState(() {
            _selectedTab = tab;
          });
        },
        applicationCount: 5,    // 지원자 수
        hasActiveJobs: true,    // 활성 공고 여부
        showBadge: false,       // 마이페이지 배지
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedTab) {
      case EmployerNavTab.createJob:
      // 공고 작성 탭 - 통합 공고 화면의 전체 공고 탭으로 이동
        return const UnifiedEmployerJobScreen(initialTab: 0);

      case EmployerNavTab.manageStaff:
      // 근무자 관리 - 준비 중
        return _buildComingSoonScreen(
          title: '근무자 관리',
          subtitle: '지원자와 근무자를 관리하세요',
          emoji: '👥',
          description: '지원자 현황, 근무자 스케줄,\n출퇴근 관리 기능을 준비 중입니다',
        );

      case EmployerNavTab.home:
      // 홈 화면
        return const EmployerMainScreen();

      case EmployerNavTab.salary:
      // 급여 관리 - 준비 중
        return _buildComingSoonScreen(
          title: '급여 관리',
          subtitle: '급여 계산과 정산을 관리하세요',
          emoji: '💰',
          description: '근무시간 집계, 급여 계산,\n정산 및 지급 기능을 준비 중입니다',
        );

      case EmployerNavTab.mypage:
      // 마이페이지 - 로그아웃 콜백 전달
        return MyPageScreen(
          userType: UserType.employer,
          onLogout: widget.onLogout, // 로그아웃 콜백 전달
        );
    }
  }

  Widget _buildComingSoonScreen({
    required String title,
    required String subtitle,
    required String emoji,
    required String description,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FFFE),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$emoji $title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '준비 중입니다',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: const Color(0xFF2D3748).withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '곧 만나요!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}