import 'package:flutter/material.dart';

// 화면 imports
import '../jobs/jeju_job_list_screen.dart';
import '../main/jeju_staff_main_screen.dart';
import '../../home/jeju_home_screen.dart';
import '../../applications/applications_screen.dart';


// 컴포넌트 imports
import '../../../components/navigation/jeju_worker_navbar.dart';

class WorkerMainScreen extends StatefulWidget {
  final Function? onLogout;

  const WorkerMainScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<WorkerMainScreen> createState() => _WorkerMainScreenState();
}

class _WorkerMainScreenState extends State<WorkerMainScreen> {
  WorkerNavTab _selectedTab = WorkerNavTab.home; // 홈을 기본값으로

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(),
      bottomNavigationBar: JejuWorkerNavBar(
        selectedTab: _selectedTab,
        onTabChanged: _onTabChanged,
        applicationCount: 3, // 임시 데이터
        hasActiveWork: true, // 임시 데이터
        showBadge: false,
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedTab) {
      case WorkerNavTab.jobs:
        return JejuJobListScreen(onLogout: widget.onLogout);

      case WorkerNavTab.applications:
        return ApplicationsScreen(onLogout: widget.onLogout);

      case WorkerNavTab.home:
        return JejuHomeScreen(onLogout: widget.onLogout);

      case WorkerNavTab.work:
        return JejuStaffMainScreen(onLogout: widget.onLogout);

      case WorkerNavTab.mypage:
        return _buildMyPageScreen();
    }
  }

  void _onTabChanged(WorkerNavTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  // 임시 마이페이지 화면
  Widget _buildMyPageScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text('👤 ', style: TextStyle(fontSize: 20)),
            Text(
              '마이페이지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF00A3A3)),
            onPressed: () {
              if (widget.onLogout != null) {
                widget.onLogout!();
              }
            },
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outlined,
              size: 80,
              color: Color(0xFF00A3A3),
            ),
            SizedBox(height: 16),
            Text(
              '마이페이지',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A3A3),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '준비 중입니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}