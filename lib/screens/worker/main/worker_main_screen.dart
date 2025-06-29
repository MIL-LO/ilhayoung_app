import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 네비게이션 바 import
import '../../../components/navigation/jeju_worker_navbar.dart';
// 일자리 리스트 화면 import
import '../jobs/jeju_job_list_screen.dart';
// 스태프 메인 화면 import
import 'jeju_staff_main_screen.dart';

class WorkerMainScreen extends StatefulWidget {
  final Function? onLogout;

  const WorkerMainScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<WorkerMainScreen> createState() => _WorkerMainScreenState();
}

class _WorkerMainScreenState extends State<WorkerMainScreen> {
  WorkerNavTab _selectedTab = WorkerNavTab.jobs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: JejuWorkerNavBar(
        selectedTab: _selectedTab,
        onTabChanged: (tab) {
          setState(() {
            _selectedTab = tab;
          });
          HapticFeedback.selectionClick();
        },
        applicationCount: 3,        // 지원 내역 개수
        hasActiveWork: true,        // 현재 근무 중 여부
        showBadge: true,           // 새 알림 여부
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedTab) {
      case WorkerNavTab.jobs:
        return JejuJobListScreen(onLogout: widget.onLogout);

      case WorkerNavTab.applications:
        return _buildApplicationsScreen();

      case WorkerNavTab.work:
        return JejuStaffMainScreen(onLogout: widget.onLogout);

      case WorkerNavTab.mypage:
        return _buildMyPageScreen();
    }
  }

  Widget _buildApplicationsScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '지원내역',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              '지원내역 화면',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '총 3건의 지원 내역이 있습니다',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF00A3A3),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFF00A3A3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '곧 구현될 예정입니다 🌊',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 기존 _buildWorkScreen 메서드는 제거 (이제 JejuStaffMainScreen 사용)

  Widget _buildMyPageScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '마이페이지',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 프로필 카드
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF00A3A3),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '제주 구직자',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'jeju.worker@email.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '새로운 알림이 있습니다',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 메뉴 리스트
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.person_outline, '프로필 수정'),
                  _buildMenuItem(Icons.description_outlined, '이력서 관리'),
                  _buildMenuItem(Icons.notifications_outlined, '알림 설정'),
                  _buildMenuItem(Icons.help_outline, '고객센터'),
                  _buildMenuItem(Icons.settings_outlined, '설정'),
                ],
              ),
            ),

            SizedBox(height: 20),

            // 로그아웃 버튼
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.onLogout != null) {
                    widget.onLogout!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title 기능 준비 중입니다'),
            backgroundColor: Color(0xFF00A3A3),
          ),
        );
      },
    );
  }
}