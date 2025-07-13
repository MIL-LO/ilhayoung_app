// ========================================
// lib/screens/home/jeju_home_screen.dart - 수정된 API 연동 홈 화면
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 컴포넌트 imports
import '../../components/common/unified_app_header.dart';
import '../../components/home/featured_jobs_widget.dart';
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
      print('=== 홈화면 근무 스케줄 로드 시작 ===');

      // 현재 월의 스케줄 조회
      final now = DateTime.now();
      final result = await WorkScheduleService.getMonthlySchedules(
        year: now.year,
        month: now.month,
      );

      if (result['success']) {
        setState(() {
          _allSchedules = result['data'] as List<WorkSchedule>;
        });

        _findUpcomingWork();
        print('✅ 홈화면 근무 스케줄 로드 성공: ${_allSchedules.length}개');
      } else {
        print('❌ 홈화면 근무 스케줄 로드 실패: ${result['error']}');
        setState(() {
          _allSchedules = [];
        });

        // 에러가 심각하지 않다면 계속 진행
        if (!result['error'].toString().contains('인증')) {
          // 계속 진행
        }
      }
    } catch (e) {
      print('❌ 홈화면 근무 스케줄 로드 예외: $e');
      setState(() {
        _allSchedules = [];
      });
    }
  }

  Future<void> _loadRecentApplications() async {
    try {
      print('=== 홈화면 지원내역 로드 시작 ===');

      // ApplicationApiService가 없다면 빈 리스트로 초기화
      // 실제 API 서비스가 구현되면 아래 주석을 해제하고 사용
      /*
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
      */

      // 임시로 빈 리스트 설정
      setState(() {
        _recentApplications = [];
      });
      print('✅ 지원내역 임시 초기화 완료');

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
      print('✅ 다가오는 근무 찾음: ${_upcomingWork!.company}');
    } else {
      setState(() {
        _upcomingWork = null;
      });
      print('ℹ️ 다가오는 근무 없음');
    }
  }

  void _calculateStats() {
    final now = DateTime.now();

    // 이번 주 근무시간 계산 (월요일 시작)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    _weeklyHours = _allSchedules
        .where((schedule) =>
    schedule.status == WorkStatus.completed &&
        schedule.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        schedule.date.isBefore(endOfWeek.add(const Duration(days: 1))))
        .fold(0, (sum, schedule) {
      // WorkSchedule에 workHours가 없다면 시간 계산
      return sum + _calculateWorkHours(schedule);
    });

    // 이번 달 근무시간 계산
    _monthlyHours = _allSchedules
        .where((schedule) =>
    schedule.status == WorkStatus.completed &&
        schedule.date.year == now.year &&
        schedule.date.month == now.month)
        .fold(0, (sum, schedule) {
      return sum + _calculateWorkHours(schedule);
    });

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
        .fold(0, (sum, schedule) {
      final hours = _calculateWorkHours(schedule);
      final hourlyRate = schedule.hourlyRate ?? 10000; // 기본 시급
      return sum + (hours * hourlyRate).toInt();
    });

    print('📊 통계 계산 완료: 주간 ${_weeklyHours}h, 월간 ${_monthlyHours}h, 완료 ${_completedJobs}개, 예상급여 ${_expectedSalary}원');
  }

  int _calculateWorkHours(WorkSchedule schedule) {
    try {
      // "09:00" - "18:00" 형식에서 시간 계산
      final startParts = schedule.startTime.split(':');
      final endParts = schedule.endTime.split(':');

      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);

      final startTotalMinutes = startHour * 60 + startMinute;
      final endTotalMinutes = endHour * 60 + endMinute;

      final workMinutes = endTotalMinutes - startTotalMinutes;
      return (workMinutes / 60).round(); // 시간으로 변환
    } catch (e) {
      print('시간 계산 오류: $e');
      return 8; // 기본 8시간
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

            // 추천 일자리
            SliverToBoxAdapter(
              child: FeaturedJobsWidget(
                title: "🔥 지금 인기있는 일자리",
                subtitle: "놓치기 전에 빨리 지원하세요!",
                onSeeAll: _onSeeAllJobs,
              ),
            ),

            // 최근 지원 현황
            if (_recentApplications.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildRecentApplicationsWidget(),
              ),

            // 빠른 액션 버튼들
            SliverToBoxAdapter(
              child: _buildQuickActionsWidget(),
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
              const Expanded(
                child: Text(
                  '최근 지원 현황',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A3A3),
                  ),
                ),
              ),
              TextButton(
                onPressed: _onViewAllApplications,
                child: const Text(
                  '전체보기',
                  style: TextStyle(
                    color: Color(0xFF00A3A3),
                    fontSize: 12,
                  ),
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
                      color: _getApplicationStatusColor(application.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.recruitTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${application.companyName} • ${_getApplicationStatusText(application.status)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatApplicationDate(application.appliedAt),
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

  Widget _buildQuickActionsWidget() {
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
          const Text(
            '빠른 바로가기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A3A3),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.work,
                  label: '일자리 찾기',
                  onTap: _onSeeAllJobs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.calendar_today,
                  label: '근무 일정',
                  onTap: _onViewWorkSchedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.account_balance_wallet,
                  label: '급여 내역',
                  onTap: _onViewSalaryDetails,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF00A3A3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF00A3A3),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00A3A3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 유틸리티 메소드들
  Color _getApplicationStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return const Color(0xFFFF9800);
      case ApplicationStatus.reviewing:
        return const Color(0xFF2196F3);
      case ApplicationStatus.interview:
        return const Color(0xFF9C27B0);
      case ApplicationStatus.offer:
        return const Color(0xFF4CAF50);
      case ApplicationStatus.hired:
        return const Color(0xFF4CAF50);
      case ApplicationStatus.rejected:
        return const Color(0xFFF44336);
      case ApplicationStatus.cancelled:
        return const Color(0xFF757575);
    }
  }

  String _getApplicationStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return '지원완료';
      case ApplicationStatus.reviewing:
        return '검토중';
      case ApplicationStatus.interview:
        return '면접예정';
      case ApplicationStatus.offer:
        return '제안받음';
      case ApplicationStatus.hired:
        return '채용확정';
      case ApplicationStatus.rejected:
        return '불합격';
      case ApplicationStatus.cancelled:
        return '취소됨';
    }
  }

  String _formatApplicationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '어제';
    } else if (difference < 7) {
      return '${difference}일 전';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  // 이벤트 핸들러들
  void _onWorkToggle() {
    HapticFeedback.lightImpact();
    // 출근/퇴근 토글 시 데이터 새로고침
    _loadWorkSchedules();
  }

  void _onViewWorkDetails() {
    if (_upcomingWork != null) {
      // 근무 상세 화면으로 이동
      print('근무 상세 보기: ${_upcomingWork!.company}');
    }
  }

  void _onViewWorkStats() {
    // 근무 통계 화면으로 이동
    print('근무 통계 보기');
  }

  void _onViewSalaryDetails() {
    // 급여 상세 화면으로 이동
    print('급여 상세 보기');
  }

  void _onSeeAllJobs() {
    // 전체 일자리 목록으로 이동
    print('전체 일자리 보기');
  }

  void _onViewAllApplications() {
    // 전체 지원내역으로 이동
    print('전체 지원내역 보기');
  }

  void _onViewWorkSchedule() {
    // 근무 일정 화면으로 이동
    print('근무 일정 보기');
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_upcomingWork != null)
                _buildNotificationItem(
                  '다가오는 근무 일정',
                  '${_upcomingWork!.company}에서 ${_formatWorkTime(_upcomingWork!)} 근무 예정',
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

  String _formatWorkTime(WorkSchedule schedule) {
    final now = DateTime.now();
    final workDate = schedule.date;
    final difference = workDate.difference(now).inDays;

    if (difference == 0) {
      return '오늘 ${schedule.startTime}';
    } else if (difference == 1) {
      return '내일 ${schedule.startTime}';
    } else {
      return '${difference}일 후 ${schedule.startTime}';
    }
  }
}