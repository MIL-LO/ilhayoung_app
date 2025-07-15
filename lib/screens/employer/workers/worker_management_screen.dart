import 'package:flutter/material.dart';
import 'schedule_management_screen.dart';

class WorkerManagementScreen extends StatelessWidget {
  final dynamic jobPosting;

  const WorkerManagementScreen({
    Key? key,
    required this.jobPosting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 새로운 스케줄 관리 화면으로 완전히 교체
    return const ScheduleManagementScreen();
  }
} 