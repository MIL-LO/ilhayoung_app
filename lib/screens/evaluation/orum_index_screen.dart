import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/evaluation_models.dart';
import '../../components/common/unified_app_header.dart';

class OrumIndexScreen extends StatefulWidget {
  final Function? onLogout;

  const OrumIndexScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<OrumIndexScreen> createState() => _OrumIndexScreenState();
}

class _OrumIndexScreenState extends State<OrumIndexScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  StaffRating? _staffRating;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadStaffRating();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _loadStaffRating() async {
    // 임시 데이터 생성
    await Future.delayed(const Duration(seconds: 1));

    final mockEvaluations = _generateMockEvaluations();
    final mockAttendance = _generateMockAttendance();

    setState(() {
      _staffRating = StaffRating(
        staffId: 'staff_001',
        staffName: '홍길동',
        evaluations: mockEvaluations,
        attendanceRecords: mockAttendance,
        lastUpdated: DateTime.now(),
      );
      _isLoading = false;
    });

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });
  }

  List<WorkplaceEvaluation> _generateMockEvaluations() {
    final evaluations = <WorkplaceEvaluation>[];
    final companies = ['제주 오션뷰 카페', '한라산 펜션', '성산일출호텔', '애월해변카페'];
    final positions = ['바리스타', '프론트데스크', '서빙', '하우스키핑'];

    for (int i = 0; i < 8; i++) {
      final items = EvaluationItemFactory.createDefaultItems();

      // 랜덤 점수 할당 (대체로 좋은 점수)
      for (var item in items) {
        final minScore = (item.maxScore * 0.6).round(); // 최소 60%
        final maxScore = item.maxScore;
        item.currentScore = minScore + (i % (maxScore - minScore + 1));
      }

      evaluations.add(WorkplaceEvaluation(
        id: 'eval_$i',
        workScheduleId: 'schedule_$i',
        company: companies[i % companies.length],
        position: positions[i % positions.length],
        workDate: DateTime.now().subtract(Duration(days: i * 15)),
        evaluationItems: items,
        evaluatedAt: DateTime.now().subtract(Duration(days: i * 15)),
        isSubmitted: true,
      ));
    }

    return evaluations;
  }

  List<AttendanceRecord> _generateMockAttendance() {
    final records = <AttendanceRecord>[];
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final scheduledTime = now.subtract(Duration(days: i)).copyWith(hour: 9, minute: 0);
      AttendanceStatus status;
      DateTime? actualTime;

      // 90% 정시, 8% 지각, 2% 결근
      final random = i % 50;
      if (random < 45) {
        status = AttendanceStatus.onTime;
        actualTime = scheduledTime.subtract(Duration(minutes: i % 10));
      } else if (random < 49) {
        status = AttendanceStatus.late;
        actualTime = scheduledTime.add(Duration(minutes: 10 + (i % 20)));
      } else {
        status = AttendanceStatus.absent;
        actualTime = null;
      }

      records.add(AttendanceRecord(
        id: 'attendance_$i',
        workScheduleId: 'schedule_$i',
        scheduledTime: scheduledTime,
        actualTime: actualTime,
        status: status,
      ));
    }

    return records;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '오름지수',
        subtitle: '나의 근무 신뢰도를 확인하세요',
        emoji: '🏆',
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF00A3A3), size: 20),
            onPressed: _showHelpDialog,
            tooltip: '도움말',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: const Color(0xFF00A3A3),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildOrumIndexCard(),
                      const SizedBox(height: 16),
                      _buildStatsGrid(),
                      const SizedBox(height: 16),
                      _buildRecentEvaluations(),
                      const SizedBox(height: 16),
                      _buildAttendanceChart(),
                      const SizedBox(height: 16),
                      _buildTipsCard(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF00A3A3),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            '오름지수를 계산하는 중...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF00A3A3),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrumIndexCard() {
    if (_staffRating == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _staffRating!.orumColor,
            _staffRating!.orumColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _staffRating!.orumColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 오름지수 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.trending_up,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 오름지수 제목
          const Text(
            '오름지수',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // 오름지수 점수
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  final animatedValue = _staffRating!.orumIndex * _progressAnimation.value;
                  return Text(
                    animatedValue.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const Text(
                ' / 5.0',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 진행률 바
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_staffRating!.orumIndex / 5.0) * _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '평가 점수와 출근 성실도를 종합한 신뢰도 지수',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_staffRating == null) return const SizedBox();

    final stats = _staffRating!.statistics;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          '평가 점수',
          '${(_staffRating!.overallRating).toStringAsFixed(1)}/5.0',
          Icons.star,
          const Color(0xFFFFD700),
        ),
        _buildStatCard(
          '출근 성실도',
          '${(stats['attendanceRate'] * 100).toStringAsFixed(0)}%',
          Icons.schedule,
          const Color(0xFF4CAF50),
        ),
        _buildStatCard(
          '총 평가 수',
          '${stats['totalEvaluations']}개',
          Icons.assignment,
          const Color(0xFF2196F3),
        ),
        _buildStatCard(
          '최근 평가',
          '${stats['recentEvaluations']}개',
          Icons.new_releases,
          const Color(0xFFFF6B35),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEvaluations() {
    if (_staffRating == null || _staffRating!.evaluations.isEmpty) {
      return const SizedBox();
    }

    final recentEvaluations = _staffRating!.evaluations.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 평가',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...recentEvaluations.map((evaluation) => _buildEvaluationCard(evaluation)),
      ],
    );
  }

  Widget _buildEvaluationCard(WorkplaceEvaluation evaluation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: evaluation.gradeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evaluation.company,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  evaluation.position,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: evaluation.gradeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${evaluation.totalScore}점',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: evaluation.gradeColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Icon(
                    index < evaluation.averageStarRating
                        ? Icons.star
                        : Icons.star_border,
                    size: 12,
                    color: const Color(0xFFFFD700),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart() {
    if (_staffRating == null) return const SizedBox();

    final onTimeCount = _staffRating!.attendanceRecords
        .where((r) => r.status == AttendanceStatus.onTime).length;
    final lateCount = _staffRating!.attendanceRecords
        .where((r) => r.status == AttendanceStatus.late).length;
    final absentCount = _staffRating!.attendanceRecords
        .where((r) => r.status == AttendanceStatus.absent).length;

    final total = _staffRating!.attendanceRecords.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '출근 현황 (최근 30일)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildAttendanceStat('정시출근', onTimeCount, total, const Color(0xFF4CAF50)),
              const SizedBox(width: 12),
              _buildAttendanceStat('지각', lateCount, total, const Color(0xFFFF9800)),
              const SizedBox(width: 12),
              _buildAttendanceStat('결근', absentCount, total, const Color(0xFFF44336)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Expanded(
      child: Column(
        children: [
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A3A3), Color(0xFF00D4AA)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                '오름지수 높이는 팁',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            '정시 출근을 꾸준히 유지하세요',
            '근무 완료 후 성실하게 평가에 참여하세요',
            '장기간 근무할수록 신뢰도가 높아집니다',
            '다양한 업종에서 경험을 쌓아보세요',
          ].map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // 이벤트 핸들러들
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadStaffRating();
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help, color: Color(0xFF00A3A3)),
            SizedBox(width: 8),
            Text(
              '오름지수란?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A3A3),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오름지수는 구직자의 근무 신뢰도를 나타내는 지표입니다.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              '• 평가 점수 (70%): 고용주 평가 결과',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '• 출근 성실도 (30%): 정시출근, 지각, 결근 기록',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 12),
            Text(
              '높은 오름지수는 더 좋은 일자리 기회로 이어집니다!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A3A3),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: Color(0xFF00A3A3)),
            ),
          ),
        ],
      ),
    );
  }

  // Helper 메서드들 - 등급 관련 삭제
}