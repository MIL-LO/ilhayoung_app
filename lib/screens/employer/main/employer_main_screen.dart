import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/common/unified_app_header.dart';
import '../../../services/employer_dashboard_service.dart';

class EmployerMainScreen extends StatefulWidget {
  final Function? onLogout;

  const EmployerMainScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<EmployerMainScreen> createState() => _EmployerMainScreenState();
}

class _EmployerMainScreenState extends State<EmployerMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // API 연동을 위한 상태 변수
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String _errorMessage = '';

  // 기본 데이터 (API 실패 시 fallback)
  final String _businessName = "제주카페";
  final String _ownerName = "김사업";
  final int _todayAttendance = 5;
  final int _totalStaff = 8;
  final int _activeJobs = 3;
  final int _pendingApplications = 12;
  final int _thisWeekWages = 680000;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDashboardData();
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

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await EmployerDashboardService.getDashboardData();
      
      if (result['success']) {
        setState(() {
          _dashboardData = result['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? '데이터를 불러오는데 실패했습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '네트워크 오류가 발생했습니다.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '내 사업장 대시보드',
        subtitle: '오늘도 성공적인 사업을 위해',
        emoji: '🏢',
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _isLoading
                ? _buildLoadingView()
                : _errorMessage.isNotEmpty
                    ? _buildErrorView()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeCard(),
                            const SizedBox(height: 24),
                            _buildStatusDashboard(),
                            const SizedBox(height: 24),
                            _buildQuickActions(),
                            const SizedBox(height: 24),
                            _buildTodaysTasks(),
                            const SizedBox(height: 24),
                            _buildRecentActivity(),
                            const SizedBox(height: 100), // 네비게이션 바 여백
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
          ),
          SizedBox(height: 16),
          Text(
            '데이터를 불러오는 중...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3748),
              foregroundColor: Colors.white,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    String emoji;

    if (hour < 12) {
      greeting = "좋은 아침이에요";
      emoji = "🌅";
    } else if (hour < 18) {
      greeting = "좋은 오후에요";
      emoji = "☀️";
    } else {
      greeting = "오늘도 수고하셨어요";
      emoji = "🌙";
    }

    // 현재 로그인한 매니저의 데이터 사용
            final businessName = _dashboardData?['companyName'] ?? _businessName;
    final ownerName = _dashboardData?['ownerName'] ?? _ownerName;
    final todayAttendance = _dashboardData?['todayAttendance'] ?? _todayAttendance;
    final totalStaff = _dashboardData?['totalStaff'] ?? _totalStaff;
    final activeJobs = _dashboardData?['activeJobs'] ?? _activeJobs;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)], // 현무암색 그라데이션
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3748).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $ownerName님!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$businessName 운영 현황',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildWelcomeStatItem(
                  '오늘 출근',
                  '$todayAttendance/$totalStaff명',
                  Icons.people,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildWelcomeStatItem(
                  '활성 공고',
                  '${activeJobs}개',
                  Icons.work,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDashboard() {
    // 현재 로그인한 매니저의 데이터 사용
    final pendingApplications = _dashboardData?['pendingApplications'] ?? _pendingApplications;
    final thisWeekWages = _dashboardData?['thisWeekWages'] ?? _thisWeekWages;
    final todayAttendance = _dashboardData?['todayAttendance'] ?? _todayAttendance;
    final totalStaff = _dashboardData?['totalStaff'] ?? _totalStaff;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 현황 대시보드',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748), // 현무암색
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDashboardCard(
                '내 공고 지원서',
                pendingApplications.toString(),
                '건',
                Icons.inbox,
                Colors.red,
                showBadge: pendingApplications > 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDashboardCard(
                '이번 주 급여 지급',
                _formatCurrency(thisWeekWages),
                '원',
                Icons.account_balance_wallet,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDashboardCard(
                '출근율',
                '${_safeAttendanceRate(todayAttendance, totalStaff)}',
                '%',
                Icons.access_time,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDashboardCard(
                '활성 공고',
                (_dashboardData?['activeJobs'] ?? _activeJobs).toString(),
                '개',
                Icons.work,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color, {
    bool showBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (showBadge)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    // 현재 로그인한 매니저의 데이터 사용
    final pendingApplications = _dashboardData?['pendingApplications'] ?? _pendingApplications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚡ 빠른 액션',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748), // 현무암색
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                '공고 작성',
                '새로운 인재 모집',
                Icons.add_circle_outline,
                const Color(0xFF2D3748), // 현무암색
                () => _navigateToCreateJob(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                '근무자 관리',
                '출근/퇴근 현황',
                Icons.people_outline,
                const Color(0xFF3498DB),
                () => _navigateToManageStaff(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                '내 공고 지원',
                '새로운 지원자 확인',
                Icons.inbox_outlined,
                const Color(0xFFE74C3C),
                () => _navigateToApplications(),
                badge: pendingApplications > 0 ? pendingApplications : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                '급여 계산',
                '이번 주 급여 미리보기',
                Icons.calculate_outlined,
                const Color(0xFF27AE60),
                () => _navigateToWageCalculator(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    int? badge,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysTasks() {
    // 현재 로그인한 매니저의 데이터 사용
    final pendingApplications = _dashboardData?['pendingApplications'] ?? _pendingApplications;
    final todayAttendance = _dashboardData?['todayAttendance'] ?? _todayAttendance;
    final totalStaff = _dashboardData?['totalStaff'] ?? _totalStaff;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 오늘의 할 일',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748), // 현무암색
          ),
        ),
        const SizedBox(height: 16),
        if (pendingApplications > 0)
          _buildTaskCard(
            '내 공고 지원서 확인',
            '새로운 지원서가 ${pendingApplications}건 있어요',
            Icons.mail_outline,
            Colors.red,
            isUrgent: true,
          ),
        if (pendingApplications > 0) const SizedBox(height: 12),
        _buildTaskCard(
          '오늘 출근 현황',
          '현재 ${todayAttendance}/${totalStaff}명이 출근했어요',
          Icons.schedule,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildTaskCard(
          '급여 지급 준비',
          '이번 주 급여 지급을 준비해주세요',
          Icons.account_balance_wallet,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildTaskCard(
    String title,
    String description,
    IconData icon,
    Color color, {
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? Colors.red.withOpacity(0.3) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (isUrgent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '긴급',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[400],
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    // 현재 로그인한 매니저의 최근 활동 가져오기 (기본값 제공)
    final activities = _dashboardData?['recentActivities'] as List? ?? [
      {
        'activity': '김○○님이 출근했어요',
        'time': '30분 전',
        'icon': 'login',
        'color': 'green',
      },
      {
        'activity': '새로운 지원이 있어요',
        'time': '1시간 전',
        'icon': 'person_add',
        'color': 'blue',
      },
      {
        'activity': '이○○님이 퇴근했어요',
        'time': '2시간 전',
        'icon': 'logout',
        'color': 'orange',
      },
      {
        'activity': '공고가 게시되었어요',
        'time': '3시간 전',
        'icon': 'work',
        'color': 'purple',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔔 최근 활동',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748), // 현무암색
          ),
        ),
        const SizedBox(height: 16),
        ...activities.map((activity) => _buildActivityItem(
          activity['activity'] as String,
          activity['time'] as String,
          _getIconFromString(activity['icon'] as String),
          _getColorFromString(activity['color'] as String),
        )).toList(),
      ],
    );
  }

  Widget _buildActivityItem(
    String activity,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748), // 현무암색
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return (amount / 10000).round().toString() + '만';
  }

  // String을 IconData로 변환하는 헬퍼 메서드
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'person_add':
        return Icons.person_add;
      case 'work':
        return Icons.work;
      case 'schedule':
        return Icons.schedule;
      case 'event':
        return Icons.event;
      case 'local_offer':
        return Icons.local_offer;
      case 'check_circle':
        return Icons.check_circle;
      case 'cancel':
        return Icons.cancel;
      case 'close':
        return Icons.close;
      default:
        return Icons.info;
    }
  }

  // String을 Color로 변환하는 헬퍼 메서드
  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'teal':
        return const Color(0xFF00A3A3); // 제주 바다색
      default:
        return Colors.grey;
    }
  }

  // 네비게이션 메서드들
  void _navigateToCreateJob() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('공고 작성 화면으로 이동'),
        backgroundColor: const Color(0xFF2D3748), // 현무암색
        duration: const Duration(seconds: 1),
      ),
    );
    // TODO: 공고 작성 화면으로 이동
  }

  void _navigateToManageStaff() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('근무자 관리 화면으로 이동'),
        backgroundColor: const Color(0xFF2D3748), // 현무암색
        duration: const Duration(seconds: 1),
      ),
    );
    // TODO: 근무자 관리 화면으로 이동
  }

  void _navigateToApplications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('지원 현황 화면으로 이동'),
        backgroundColor: const Color(0xFF2D3748), // 현무암색
        duration: const Duration(seconds: 1),
      ),
    );
    // TODO: 지원 현황 화면으로 이동
  }

  void _navigateToWageCalculator() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('급여 계산 화면으로 이동'),
        backgroundColor: const Color(0xFF2D3748), // 현무암색
        duration: const Duration(seconds: 1),
      ),
    );
    // TODO: 급여 계산 화면으로 이동
  }
}

int _safeAttendanceRate(int todayAttendance, int totalStaff) {
  if (totalStaff == 0) return 0;
  final rate = (todayAttendance / totalStaff) * 100;
  if (rate.isNaN || rate.isInfinite) return 0;
  return rate.round();
}

int safeToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) {
    if (value.isNaN || value.isInfinite) return 0;
    return value.toInt();
  }
  return int.tryParse(value.toString()) ?? 0;
}