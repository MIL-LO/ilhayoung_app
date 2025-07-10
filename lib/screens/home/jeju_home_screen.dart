// lib/screens/home/jeju_home_screen.dart - API 연동된 홈 화면

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 컴포넌트 imports
import '../../components/common/unified_app_header.dart';
import '../../components/work/work_status_bar.dart';
import '../../components/home/upcoming_work_card.dart';
import '../../components/home/work_stats_widget.dart';
import '../../components/home/salary_calculation_widget.dart';

// 서비스 imports
import '../../services/user_info_service.dart';
import '../../services/work_schedule_service.dart';
import '../../services/application_api_service.dart';

// 모델 imports
import '../../models/work_schedule.dart';
import '../../models/application_model.dart';

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

  // 사용자 정보
  String _userName = '';

  // 근무 관련 데이터
  WorkSchedule? _upcomingWork;
  List<WorkSchedule> _allSchedules = [];
  List<JobApplication> _recentApplications = [];

  // 근무 통계
  int _weeklyHours = 0;
  int _monthlyHours = 0;
  int _completedJobs = 0;

  // 급여 정산
  int _expectedSalary = 0;
  String _currentMonth = '';
  DateTime? _nextPaymentDate;

  // 로딩 상태
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadAllData();
    _setCurrentMonth();
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

  void _setCurrentMonth() {
    final now = DateTime.now();
    _currentMonth = '${now.month}월';
    // 다음 급여일은 매월 10일로 가정
    _nextPaymentDate = DateTime(now.year, now.month + 1, 10);
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 병렬로 데이터 로드
      await Future.wait([
        _loadUserInfo(),
        _loadWorkSchedules(),
        _loadRecentApplications(),
      ]);

      _calculateStats();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '데이터를 불러오는데 실패했습니다';
      });
      print('❌ 홈 데이터 로딩 실패: $e');
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await UserInfoService.getUserInfo();
      if (userInfo != null) {
        setState(() {
          _userName = userInfo['name'] ?? '사용자';
        });
        print('✅ 사용자 정보 로드 성공: $_userName');
      }
    } catch (e) {
      print('❌ 사용자 정보 로드 실패: $e');
      setState(() {
        _userName = '사용자';
      });
    }
  }

  Future<void> _loadWorkSchedules() async {
    try {
      // 최근 3개월 스케줄 조회
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 2, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      final result = await WorkScheduleService.getMyWorkSchedules(
        startDate: startDate.toIso8601String().split('T')[0],
        endDate: endDate.toIso8601String().split('T')[0],
      );

      if (result['success']) {
        setState(() {
          _allSchedules = result['data'] as List<WorkSchedule>;
        });

        _findUpcomingWork();
        print('✅ 근무 스케줄 로드 성공: ${_allSchedules.length}개');
      } else {
        print('❌ 근무 스케줄 로드 실패: ${result['error']}');
        setState(() {
          _allSchedules = [];
        });
      }
    } catch (e) {
      print('❌ 근무 스케줄 로드 예외: $e');
      setState(() {
        _allSchedules = [];
      });
    }
  }

  Future<void> _loadRecentApplications() async {
    try {
      final result = await ApplicationApiService.getMyApplications(
        page: 0,
        size: 10,
      );

      if (result['success']) {
        setState(() {
          _recentApplications = result['data'] as List<JobApplication>;
        });
        print('✅ 지원내역 로드 성공: ${_recentApplications.length}개');
      } else {
        print('❌ 지원내역 로드 실패: ${result['error']}');
        setState(() {
          _recentApplications = [];
        });
      }
    } catch (e) {
      print('❌ 지원내역 로드 예외: $e');
      setState(() {
        _recentApplications = [];
      });
    }
  }

  void _findUpcomingWork() {
    final now = DateTime.now();
    final scheduledWorks = _allSchedules
        .where((schedule) =>
    schedule.status == WorkStatus.scheduled &&
        schedule.date.isAfter(now))
        .toList();

    if (scheduledWorks.isNotEmpty) {
      scheduledWorks.sort((a, b) => a.date.compareTo(b.date));
      setState(() {
        _upcomingWork = scheduledWorks.first;
      });
    } else {
      setState(() {
        _upcomingWork = null;
      });
    }
  }

  void _calculateStats() {
    final now = DateTime.now();

    // 이번 주 근무시간 계산
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    _weeklyHours = _allSchedules
        .where((schedule) =>
    schedule.status == WorkStatus.completed &&
        schedule.date.isAfter(startOfWeek) &&
        schedule.date.isBefore(endOfWeek))
        .fold(0, (sum, schedule) => sum + schedule.workHours);

    // 이번 달 근무시간 계산
    _monthlyHours = _allSchedules
        .where((schedule) =>
    schedule.status == WorkStatus.completed &&
        schedule.date.year == now.year &&
        schedule.date.month == now.month)
        .fold(0, (sum, schedule) => sum + schedule.workHours);

    // 완료된 일자리 수
    _completedJobs = _allSchedules
        .where((schedule) => schedule.status == WorkStatus.completed)
        .length;

    // 예상 급여 계산 (이번 달 완료된 근무 + 예정된 근무)
    final thisMonthSchedules = _allSchedules
        .where((schedule) =>
    (schedule.status == WorkStatus.completed ||
        schedule.status == WorkStatus.scheduled) &&
        schedule.date.year == now.year &&
        schedule.date.month == now.month)
        .toList();

    _expectedSalary = thisMonthSchedules
        .fold(0, (sum, schedule) => sum + schedule.expectedPay);

    print('📊 통계 계산 완료: 주간 ${_weeklyHours}h, 월간 ${_monthlyHours}h, 완료 ${_completedJobs}개, 예상급여 ${_expectedSalary}원');
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
        subtitle: _userName.isNotEmpty
            ? '$_userName님, 반갑습니다!'
            : '바다처럼 넓은 기회의 세상',
        emoji: '🌊',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF00A3A3), size: 20),
            onPressed: _showNotifications,
            tooltip: '알림',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00A3A3), size: 20),
            onPressed: () => _loadAllData(),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A3A3)),
            ),
            SizedBox(height: 16),
            Text(
              '데이터를 불러오는 중...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF00A3A3),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A3A3),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadAllData,
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

            // 급여 계산
            SliverToBoxAdapter(
              child: SalaryCalculationWidget(
                monthlyHours: _monthlyHours,
                expectedSalary: _expectedSalary,
                currentMonth: _currentMonth,
                nextPaymentDate: _nextPaymentDate,
              ),
            ),

            // 최근 지원 현황 (새로 추가)
            if (_recentApplications.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildRecentApplicationsWidget(),
              ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentApplicationsWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A3A3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Color(0xFF00A3A3),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '최근 지원 현황',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A3A3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...(_recentApplications.take(3).map((application) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: application.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.jobTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${application.company} • ${application.statusText}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    application.formattedAppliedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
        ],
      ),
    );
  }

  // 이벤트 핸들러들
  void _onWorkToggle() {
    // 출근/퇴근 토글 시 데이터 새로고침
    _loadWorkSchedules();
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
            if (_upcomingWork != null)
              _buildNotificationItem(
                '다가오는 근무 일정',
                '${_upcomingWork!.company}에서 ${_upcomingWork!.timeUntilWork} 근무 예정',
                '알림',
              ),
            if (_recentApplications.isNotEmpty) ...[
              const Divider(),
              _buildNotificationItem(
                '최근 지원 현황',
                '${_recentApplications.where((app) => app.status == ApplicationStatus.reviewing).length}개 지원서가 검토 중입니다',
                '정보',
              ),
            ],
            if (_completedJobs > 0) ...[
              const Divider(),
              _buildNotificationItem(
                '이번 달 근무 완료',
                '$_completedJobs개의 근무를 완료했습니다',
                '성과',
              ),
            ],
            if (_upcomingWork == null && _recentApplications.isEmpty) ...[
              _buildNotificationItem(
                '새로운 기회를 찾아보세요!',
                '제주 지역의 다양한 일자리를 확인해보세요',
                '추천',
              ),
            ],
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