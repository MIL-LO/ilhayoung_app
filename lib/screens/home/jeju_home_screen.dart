import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 컴포넌트 imports
import '../../../components/common/unified_app_header.dart';
import '../../../components/work/work_status_bar.dart';
import '../../../components/home/upcoming_work_card.dart';
import '../../../components/home/work_stats_widget.dart';
import '../../../components/home/salary_calculation_widget.dart';
import '../../../models/work_schedule.dart';
import '../../../services/mock_schedule_service.dart';

class JejuHomeScreen extends StatefulWidget {
  final Function? onLogout;

  const JejuHomeScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<JejuHomeScreen> createState() => _JejuHomeScreenState();
}

class _JejuHomeScreenState extends State<JejuHomeScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final String _userName = '홍길동';
  WorkSchedule? _upcomingWork;

  // 근무 통계 (임시 데이터)
  final int _weeklyHours = 32;
  final int _monthlyHours = 165; // 이번 달 총 근무시간
  final int _completedJobs = 12;

  // 급여 정산 (임시 데이터)
  final int _expectedSalary = 1589500; // 예상 급여
  final String _currentMonth = '6월';
  final DateTime _nextPaymentDate = DateTime(2025, 7, 10); // 다음 급여일

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  void _loadData() async {
    try {
      // 다가오는 근무 일정 찾기
      final allSchedules = MockScheduleService.instance.generateSchedules(months: 2);
      final mySchedules = allSchedules.where((s) => s.isMyWork && s.status == 'scheduled').toList();

      if (mySchedules.isNotEmpty) {
        // 현재 시간 이후의 가장 가까운 일정 찾기
        final now = DateTime.now();
        final upcoming = mySchedules.where((s) {
          final workDateTime = DateTime(
            s.date.year,
            s.date.month,
            s.date.day,
            int.parse(s.startTime.split(':')[0]),
            int.parse(s.startTime.split(':')[1]),
          );
          return workDateTime.isAfter(now);
        }).toList();

        if (upcoming.isNotEmpty) {
          upcoming.sort((a, b) => a.date.compareTo(b.date));
          _upcomingWork = upcoming.first;
        }
      }

      setState(() {});
    } catch (e) {
      // 에러 처리
      print('데이터 로딩 에러: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '제주 일하영',
        subtitle: '바다처럼 넓은 기회의 세상',
        emoji: '🌊',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF00A3A3), size: 20),
            onPressed: _showNotifications,
            tooltip: '알림',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFF00A3A3),
          child: CustomScrollView(
            slivers: [
              // 출근/퇴근 상태 바
              SliverToBoxAdapter(
                child: WorkStatusBar(
                  onWorkToggle: _onWorkToggle,
                ),
              ),

              // 다가오는 근무 일정 카드
              SliverToBoxAdapter(
                child: UpcomingWorkCard(
                  upcomingWork: _upcomingWork,
                  userName: _userName,
                ),
              ),

              // 근무 통계
              SliverToBoxAdapter(
                child: WorkStatsWidget(
                  weeklyHours: _weeklyHours,
                  monthlyHours: _monthlyHours,
                  completedJobs: _completedJobs,
                ),
              ),

              // 급여 계산 (중복 제거)
              SliverToBoxAdapter(
                child: SalaryCalculationWidget(
                  monthlyHours: _monthlyHours,
                  expectedSalary: _expectedSalary,
                  currentMonth: _currentMonth,
                  nextPaymentDate: _nextPaymentDate,
                ),
              ),

              // 하단 여백
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 이벤트 핸들러들
  void _onWorkToggle() {
    // 출근/퇴근 토글 시 데이터 새로고침
    _loadData();
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadData();
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Color(0xFF00A3A3)),
            SizedBox(width: 8),
            Text(
              '알림',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A3A3),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem(
              '새로운 공고가 등록되었어요!',
              '제주 오션뷰 카페에서 바리스타를 모집합니다',
              '5분 전',
            ),
            const Divider(),
            _buildNotificationItem(
              '근무 일정 알림',
              '내일 14:00 출근 예정입니다',
              '1시간 전',
            ),
            const Divider(),
            _buildNotificationItem(
              '지원 결과 안내',
              '한라산 펜션 지원이 승인되었습니다',
              '2시간 전',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '닫기',
              style: TextStyle(color: Color(0xFF00A3A3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}