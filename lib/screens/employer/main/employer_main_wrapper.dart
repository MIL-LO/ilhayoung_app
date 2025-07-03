// lib/screens/employer/main/employer_main_wrapper.dart

import 'package:flutter/material.dart';
import '../../../core/enums/user_type.dart';
import '../../profile/mypage_screen.dart';
import 'employer_main_screen.dart';
import '../jobs/job_posting_create_screen.dart';
// import '../attendance/attendance_management_screen.dart';
import '../../../components/navigation/jeju_employer_navbar.dart';

class EmployerMainWrapper extends StatefulWidget {
  final Function? onLogout;

  const EmployerMainWrapper({Key? key, this.onLogout}) : super(key: key);

  @override
  State<EmployerMainWrapper> createState() => _EmployerMainWrapperState();
}

class _EmployerMainWrapperState extends State<EmployerMainWrapper> {
  EmployerNavTab _selectedTab = EmployerNavTab.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(),
      bottomNavigationBar: JejuEmployerNavBar(
        selectedTab: _selectedTab,
        onTabChanged: (tab) {
          setState(() {
            _selectedTab = tab;
          });
        },
        applicationCount: 12,
        hasActiveJobs: true,
        showBadge: true,
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedTab) {
      case EmployerNavTab.home:
        return EmployerMainScreen(onLogout: widget.onLogout);
      case EmployerNavTab.createJob:
        return const JobPostingCreateScreen();
      case EmployerNavTab.manageStaff:
//         return const AttendanceManagementScreen();
      case EmployerNavTab.myJobs:
        return _buildComingSoonScreen('내 공고', '📋', '등록된 공고를 확인하고 관리하세요');
      case EmployerNavTab.mypage:
        return MyPageScreen(
          userType: UserType.employer,
          onLogout: widget.onLogout,
        );
    }
  }

  Widget _buildComingSoonScreen(String title, String emoji, String subtitle) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2D3748), // 현무암색
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF8FFFE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 이모지
              Text(
                emoji,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 32),

              // 제목
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748), // 현무암색
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // 서브타이틀
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 준비 중 카드
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.construction,
                      size: 48,
                      color: Color(0xFF2D3748), // 현무암색
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '준비 중',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748), // 현무암색
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '이 기능은 곧 추가될 예정입니다\n메인 화면에서 다른 기능을 확인해보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 메인으로 이동 버튼
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedTab = EmployerNavTab.home;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3748), // 현무암색
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '메인으로 돌아가기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}