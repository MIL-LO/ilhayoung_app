import 'package:flutter/material.dart';

// 화면 imports
import '../jobs/jeju_job_list_screen.dart';
import '../main/jeju_staff_main_screen.dart';
import '../../home/jeju_home_screen.dart';
import '../../applications/applications_screen.dart';
import '../../profile/mypage_screen.dart';

// 컴포넌트 imports
import '../../../components/navigation/jeju_worker_navbar.dart';
import '../../../core/enums/user_type.dart';

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