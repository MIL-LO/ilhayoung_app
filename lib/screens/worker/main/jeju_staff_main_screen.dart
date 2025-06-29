import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

// 네비게이션 바 import
import '../../../components/navigation/jeju_worker_navbar.dart';
// 공통 헤더 import
import '../../../components/common/jeju_common_header.dart';

class JejuStaffMainScreen extends StatefulWidget {
  final Function? onLogout;

  const JejuStaffMainScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<JejuStaffMainScreen> createState() => _JejuStaffMainScreenState();
}

class _JejuStaffMainScreenState extends State<JejuStaffMainScreen>
    with TickerProviderStateMixin {
  WorkerNavTab _selectedTab = WorkerNavTab.work;
  bool _isWorking = false;
  String _workStatus = 'standby';
  DateTime? _workStartTime;
  Timer? _timer;
  Duration _workDuration = Duration.zero;

  // 애니메이션 컨트롤러들
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  // 근무 정보
  final String _workerName = '홍길동';
  final String _companyName = '제주 오션뷰 카페';
  final String _nextWorkTime = '14:00';
  final String _timeUntilWork = '1시간 15분';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startTimer();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isWorking && _workStartTime != null) {
        setState(() {
          _workDuration = DateTime.now().difference(_workStartTime!);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 🎯 공통 헤더 컴포넌트 사용
            JejuCommonHeader(
              emoji: '🌊',
              title: '근무관리',
              subtitle: '안녕하세요, $_workerName님! 🏔️',
              expandedHeight: 80,
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: Color(0xFF00A3A3), size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('알림 기능 준비 중입니다 🔔'),
                        backgroundColor: Color(0xFF00A3A3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.all(4),
                ),
              ],
            ),

            // 메인 컨텐츠
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 근무 상태 카드
                      _buildWorkStatusCard(),

                      SizedBox(height: 16),

                      // 다음 근무 안내
                      if (!_isWorking) _buildNextWorkCard(),

                      SizedBox(height: 16),

                      // 출근/퇴근 버튼
                      _buildWorkButton(),

                      SizedBox(height: 20),

                      // 오늘의 일정
                      _buildTodaySchedule(),

                      SizedBox(height: 16),

                      // 최근 활동
                      _buildRecentActivity(),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isWorking
              ? [Color(0xFF00A3A3), Color(0xFF00D4AA)]
              : [Color(0xFFFF6B35), Color(0xFFFF8A50)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_isWorking ? Color(0xFF00A3A3) : Color(0xFFFF6B35)).withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 파도 애니메이션
          Positioned.fill(
            child: CustomPaint(
              painter: WavePatternPainter(_waveAnimation.value),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _companyName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Spacer(),
                  if (_isWorking)
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),

              SizedBox(height: 12),

              Text(
                _isWorking ? '🌊 근무 중' : '🍊 대기 중',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 6),

              if (_isWorking) ...[
                Text(
                  '근무 시간: ${_formatDuration(_workDuration)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ] else ...[
                Text(
                  '제주 바다처럼 맑은 하루 되세요!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextWorkCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF00A3A3).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color(0xFF00A3A3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.schedule,
                  color: Color(0xFF00A3A3),
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '다음 근무 일정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF00A3A3).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_workerName님, 출근까지',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '$_timeUntilWork 남았어요!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00A3A3),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '오늘 $_nextWorkTime 출근',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '⏰',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isWorking ? 1.0 : _pulseAnimation.value * 0.03 + 0.97,
          child: Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _toggleWork,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isWorking ? Color(0xFFFF6B35) : Color(0xFF00A3A3),
                foregroundColor: Colors.white,
                elevation: _isWorking ? 4 : 6,
                shadowColor: (_isWorking ? Color(0xFFFF6B35) : Color(0xFF00A3A3)).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isWorking ? Icons.logout : Icons.login,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _isWorking ? '🌅 퇴근하기' : '🌊 출근하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodaySchedule() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🗓️ 오늘의 일정',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          _buildScheduleItem('14:00 - 22:00', '카페 서빙', '8시간', true),
          _buildScheduleItem('22:00 - 22:30', '정리 및 마감', '30분', false),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String time, String task, String duration, bool isMain) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMain ? Color(0xFF00A3A3).withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isMain ? Color(0xFF00A3A3).withOpacity(0.3) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 30,
            decoration: BoxDecoration(
              color: isMain ? Color(0xFF00A3A3) : Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '$time • $duration',
                  style: TextStyle(
                    fontSize: 10,
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

  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 최근 활동',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildActivityStat('이번 주', '32시간', Color(0xFF00A3A3)),
              SizedBox(width: 12),
              _buildActivityStat('이번 달', '128시간', Color(0xFFFF6B35)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleWork() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isWorking = !_isWorking;
      if (_isWorking) {
        _workStartTime = DateTime.now();
        _workDuration = Duration.zero;
      } else {
        _workStartTime = null;
      }
    });

    // 피드백 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWorking ? '🌊 출근 완료! 오늘도 화이팅!' : '🌅 수고하셨습니다!',
        ),
        backgroundColor: _isWorking ? Color(0xFF00A3A3) : Color(0xFFFF6B35),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

// 파도 패턴 페인터
class WavePatternPainter extends CustomPainter {
  final double animationValue;

  WavePatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final waveHeight = 15.0;
    final waveLength = size.width / 2;

    for (double x = -waveLength; x <= size.width + waveLength; x += 2) {
      final y = size.height * 0.7 +
          waveHeight * math.sin((x / waveLength) * 2 * math.pi + animationValue * 2 * math.pi);

      if (x == -waveLength) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}