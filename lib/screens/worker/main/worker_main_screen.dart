import 'package:flutter/material.dart';

// 컴포넌트 imports
import '../../../components/navigation/jeju_worker_navbar.dart';
import '../../../core/enums/user_type.dart';
import '../../applications/applications_screen.dart';
import '../../home/jeju_home_screen.dart';
import '../../profile/mypage_screen.dart';
// 화면 imports
import '../jobs/jeju_job_list_screen.dart';
import '../main/jeju_staff_main_screen.dart';

class WorkerMainScreen extends StatefulWidget {
  final Function? onLogout;

  const WorkerMainScreen({super.key, this.onLogout});

  @override
  State<WorkerMainScreen> createState() => _WorkerMainScreenState();
}

class _WorkerMainScreenState extends State<WorkerMainScreen> {
  WorkerNavTab _selectedTab = WorkerNavTab.home; // 홈을 기본값으로

  // 탭 변경을 위한 콜백 메서드 추가
  void _changeTab(WorkerNavTab tab) {
    print('🔄 탭 변경 요청: $tab');
    setState(() {
      _selectedTab = tab;
    });
    print('✅ 탭 변경 완료: $_selectedTab');
  }

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
        return JejuHomeScreen(
          onLogout: widget.onLogout,
          onNavigateToJobs: () => _changeTab(WorkerNavTab.jobs), // 콜백 전달
        );

      case WorkerNavTab.work:
        return JejuStaffMainScreen(onLogout: widget.onLogout);

      case WorkerNavTab.mypage:
        return MyPageScreen(
          userType: UserType.worker,
          onLogout: widget.onLogout,
        );
    }
  }

  void _onTabChanged(WorkerNavTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }
}