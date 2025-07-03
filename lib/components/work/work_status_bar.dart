import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class WorkStatusBar extends StatefulWidget {
  final VoidCallback? onWorkToggle;

  const WorkStatusBar({
    Key? key,
    this.onWorkToggle,
  }) : super(key: key);

  @override
  State<WorkStatusBar> createState() => _WorkStatusBarState();
}

class _WorkStatusBarState extends State<WorkStatusBar>
    with TickerProviderStateMixin {

  bool _isWorking = false;
  DateTime? _workStartTime;
  Timer? _timer;
  Duration _workDuration = Duration.zero;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (!_isWorking) {
      _pulseController.repeat(reverse: true);
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isWorking
              ? [const Color(0xFF00A3A3), const Color(0xFF00D4AA)]
              : [const Color(0xFFFF6B35), const Color(0xFFFF8A50)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_isWorking ? const Color(0xFF00A3A3) : const Color(0xFFFF6B35))
                .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned.fill(
            child: CustomPaint(
              painter: WorkPatternPainter(),
            ),
          ),

          // 메인 콘텐츠
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 상태 정보 (상단)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _isWorking ? '🌊 근무 중' : '🍊 대기 중',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (_isWorking)
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            _isWorking
                              ? '근무 시간: ${_formatDuration(_workDuration)}'
                              : '오늘도 화이팅하세요! 💪',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 시계 아이콘 (장식용)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isWorking ? Icons.work : Icons.schedule,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 출근/퇴근 버튼 (하단) - 수정된 부분
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isWorking ? 1.0 : _pulseAnimation.value * 0.02 + 0.98,
                      child: SizedBox(
                        width: double.infinity,
                        height: 60, // 고정 높이 설정
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleWork,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                alignment: Alignment.center, // 중앙 정렬 명시
                                child: Text(
                                  _isWorking ? '🌅 퇴근하기' : '🌊 출근하기',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center, // 텍스트 중앙 정렬
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
        _pulseController.stop();
        _pulseController.repeat(reverse: true);
      } else {
        _workStartTime = null;
        _pulseController.repeat(reverse: true);
      }
    });

    // 콜백 호출
    widget.onWorkToggle?.call();

    // 피드백 메시지
    final message = _isWorking
      ? '🌊 출근 완료! 오늘도 화이팅!'
      : '🌅 수고하셨습니다!';

    final color = _isWorking
      ? const Color(0xFF00A3A3)
      : const Color(0xFFFF6B35);

    // 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 80,
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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

// 배경 패턴 페인터
class WorkPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 간단한 도트 패턴
    for (double x = 20; x < size.width; x += 40) {
      for (double y = 20; y < size.height; y += 20) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}