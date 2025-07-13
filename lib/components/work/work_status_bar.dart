import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';

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
  bool _isLoading = false;
  DateTime? _workStartTime;
  DateTime? _workEndTime;
  Timer? _timer;
  Duration _workDuration = Duration.zero;
  String? _workStatus;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _debugAndLoadData();
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

    _pulseController.repeat(reverse: true);
  }

  // 디버깅과 함께 데이터 로드
  Future<void> _debugAndLoadData() async {
    print('=== 🚀 WorkStatusBar 초기화 시작 ===');

    // 1. Auth 상태 전체 확인 (디버깅)
    await AuthService.checkFullAuthStatus();

    // 2. 실제 데이터 로드
    await _loadTodayAttendance();

    print('=== ✅ WorkStatusBar 초기화 완료 ===');
  }

  Future<void> _loadTodayAttendance() async {
    try {
      print('=== 📅 오늘 출근 상태 로드 시작 ===');

      // 1. 로그인 상태 먼저 확인
      final isLoggedIn = await AuthService.isLoggedIn();
      print('🔍 로그인 상태: $isLoggedIn');

      if (!isLoggedIn) {
        print('❌ 로그인되지 않음 - AUTH 상태로 설정');
        setState(() {
          _isWorking = false;
          _workStatus = null; // 인증 필요
          _workStartTime = null;
          _workEndTime = null;
        });
        return;
      }

      // 2. API 호출
      final result = await AttendanceService.getTodayAttendance();
      print('📡 API 호출 결과: ${result['success'] ? "성공" : "실패"}');

      if (result['success']) {
        final data = result['data'];
        print('📋 받은 데이터: $data');

        // 데이터가 null이거나 빈 경우 스케줄 없음으로 처리
        if (data == null) {
          print('📅 데이터가 null - 오늘 예정된 근무 스케줄이 없음');
          setState(() {
            _isWorking = false;
            _workStatus = 'NO_SCHEDULE'; // 스케줄 없음
            _workStartTime = null;
            _workEndTime = null;
          });
          return;
        }

        // 데이터가 있는 경우 처리
        Map<String, dynamic>? scheduleData;

        // content 배열이 있는 경우 (일자리 목록 응답)
        if (data is Map && data.containsKey('content')) {
          final content = data['content'];
          if (content is List && content.isNotEmpty) {
            // 일자리 목록에서 첫 번째 항목 사용 (실제로는 스케줄 API가 아님)
            print('⚠️ 일자리 목록 API 응답 - 스케줄 API가 아님');
            setState(() {
              _isWorking = false;
              _workStatus = 'NO_SCHEDULE'; // 스케줄 없음
              _workStartTime = null;
              _workEndTime = null;
            });
            return;
          } else {
            print('📅 content 배열이 비어있음 - 스케줄 없음');
            setState(() {
              _isWorking = false;
              _workStatus = 'NO_SCHEDULE'; // 스케줄 없음
              _workStartTime = null;
              _workEndTime = null;
            });
            return;
          }
        }

        // 일반적인 스케줄 데이터 처리
        if (data is List && data.isNotEmpty) {
          scheduleData = data[0];
          print('📝 스케줄 데이터 (List): ${scheduleData}');
        } else if (data is Map<String, dynamic>) {
          scheduleData = data;
          print('📝 스케줄 데이터 (Map): ${scheduleData}');
        }

        if (scheduleData != null) {
          setState(() {
            _workStatus = scheduleData!['status'];

            // 체크인 시간이 있으면 근무 중으로 설정
            if (scheduleData['checkInTime'] != null) {
              _workStartTime = DateTime.parse(scheduleData['checkInTime']);
              _isWorking = true;
              print('✅ 체크인 시간 발견: $_workStartTime');
            }

            // 체크아웃 시간이 있으면 근무 완료
            if (scheduleData['checkOutTime'] != null) {
              _workEndTime = DateTime.parse(scheduleData['checkOutTime']);
              _isWorking = false;
              print('✅ 체크아웃 시간 발견: $_workEndTime');
            }

            // 근무 중이면 애니메이션 중지
            if (_isWorking) {
              _pulseController.stop();
            }
          });

          print('✅ 출근 상태 로드 완료: $_workStatus, 근무중: $_isWorking');
          return;
        }

        // 스케줄 데이터가 없는 경우
        print('📅 스케줄 데이터 없음 - 오늘 예정된 근무가 없음');
        setState(() {
          _isWorking = false;
          _workStatus = 'NO_SCHEDULE'; // 스케줄 없음
          _workStartTime = null;
          _workEndTime = null;
        });

      } else {
        // API 호출 실패
        final error = result['error'] ?? 'Unknown error';
        final errorType = result['errorType'];

        print('❌ 출근 상태 조회 실패: $error (타입: $errorType)');

        // 인증 에러인 경우
        if (errorType == 'AUTH' || error.contains('인증') || error.contains('토큰')) {
          setState(() {
            _isWorking = false;
            _workStatus = null; // 인증 필요
            _workStartTime = null;
            _workEndTime = null;
          });
          print('🔐 인증 필요 상태로 설정');
        } else {
          // 기타 에러 (서버 오류 등)
          setState(() {
            _isWorking = false;
            _workStatus = 'ERROR';
            _workStartTime = null;
            _workEndTime = null;
          });
          print('⚠️ 에러 상태로 설정');
        }
      }
    } catch (e) {
      print('❌ 출근 상태 로드 예외: $e');
      setState(() {
        _isWorking = false;
        _workStatus = 'ERROR';
        _workStartTime = null;
        _workEndTime = null;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isWorking && _workStartTime != null && _workEndTime == null) {
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
          colors: _getGradientColors(),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getGradientColors()[0].withOpacity(0.3),
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
                                _getStatusTitle(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (_isWorking && !_isLoading)
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
                            _getStatusDescription(),
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
                        _getStatusIcon(),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 출근/퇴근 버튼 (하단)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isWorking ? 1.0 : _pulseAnimation.value * 0.02 + 0.98,
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoading ? null : _toggleWork,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getButtonText(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // 디버그 모드 표시 (개발 중에만)
                                    if (_workStatus == null) ...[
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _showDebugInfo,
                                        child: Icon(
                                          Icons.bug_report,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ],
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

  List<Color> _getGradientColors() {
    if (_workEndTime != null) {
      // 근무 완료
      return [const Color(0xFF9C27B0), const Color(0xFFBA68C8)];
    } else if (_isWorking) {
      // 근무 중
      return [const Color(0xFF00A3A3), const Color(0xFF00D4AA)];
    } else {
      // 대기 중 또는 기타 상태
      switch (_workStatus) {
        case null:
          return [const Color(0xFFFF6B35), const Color(0xFFFF8A50)]; // 로그인 필요
        case 'NO_SCHEDULE':
          return [const Color(0xFF2196F3), const Color(0xFF42A5F5)]; // 스케줄 없음
        case 'ERROR':
          return [const Color(0xFFF44336), const Color(0xFFEF5350)]; // 에러
        default:
          return [const Color(0xFFFF6B35), const Color(0xFFFF8A50)]; // 기본 대기
      }
    }
  }

  String _getStatusTitle() {
    if (_workEndTime != null) {
      return '✅ 근무 완료';
    } else if (_isWorking) {
      return '🌊 근무 중';
    } else {
      // 상태별 타이틀 구분
      switch (_workStatus) {
        case null:
          return '🔐 로그인 필요';
        case 'NO_SCHEDULE':
          return '📅 스케줄 없음';
        case 'ERROR':
          return '⚠️ 연결 오류';
        default:
          return '🍊 대기 중';
      }
    }
  }

  String _getStatusDescription() {
    if (_workEndTime != null) {
      return '오늘 근무를 완료했습니다. 수고하셨어요!';
    } else if (_isWorking && _workStartTime != null) {
      return '근무 시간: ${_formatDuration(_workDuration)}';
    } else {
      // 상태별 설명 구분
      switch (_workStatus) {
        case null:
          return '로그인 후 출근 체크를 해주세요';
        case 'NO_SCHEDULE':
          return '오늘 예정된 근무가 없습니다';
        case 'ERROR':
          return '서버 연결에 문제가 있습니다';
        default:
          return '오늘도 화이팅하세요! 💪';
      }
    }
  }

  IconData _getStatusIcon() {
    if (_workEndTime != null) {
      return Icons.check_circle;
    } else if (_isWorking) {
      return Icons.work;
    } else {
      // 상태별 아이콘 구분
      switch (_workStatus) {
        case null:
          return Icons.login;
        case 'NO_SCHEDULE':
          return Icons.event_busy;
        case 'ERROR':
          return Icons.error_outline;
        default:
          return Icons.schedule;
      }
    }
  }

  String _getButtonText() {
    if (_workEndTime != null) {
      return '✅ 근무 완료됨';
    } else if (_isWorking) {
      return '🌅 퇴근하기';
    } else {
      // 상태별 버튼 텍스트 구분
      switch (_workStatus) {
        case null:
          return '🔐 로그인 필요';
        case 'NO_SCHEDULE':
          return '📅 스케줄 없음';
        case 'ERROR':
          return '🔄 다시 시도';
        default:
          return '🌊 출근하기';
      }
    }
  }

  Future<void> _toggleWork() async {
    if (_isLoading || _workEndTime != null) return;

    print('=== 🖱️ 버튼 클릭: ${_getButtonText()} ===');

    // 상태별 동작 처리
    if (_workStatus == null) {
      // 로그인 필요
      print('🔐 로그인 필요 상태');
      _showLoginRequiredMessage();
      return;
    } else if (_workStatus == 'NO_SCHEDULE') {
      // 오늘 스케줄 없음
      print('📅 스케줄 없음 상태');
      _showNoScheduleMessage();
      return;
    } else if (_workStatus == 'ERROR') {
      // 에러 상태 - 다시 로드 시도
      print('🔄 에러 상태 - 재로딩');
      _loadTodayAttendance();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.mediumImpact();

      final checkType = _isWorking ? CheckType.checkOut : CheckType.checkIn;
      print('📡 API 호출: ${checkType.name}');

      final result = await AttendanceService.checkInOut(checkType: checkType);

      if (result['success']) {
        // 성공 시 상태 업데이트
        final now = DateTime.now();

        setState(() {
          if (checkType == CheckType.checkIn) {
            _isWorking = true;
            _workStartTime = now;
            _workDuration = Duration.zero;
            _pulseController.stop();
            print('✅ 출근 처리 완료');
          } else {
            _isWorking = false;
            _workEndTime = now;
            _pulseController.repeat(reverse: true);
            print('✅ 퇴근 처리 완료');
          }
        });

        // 성공 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '처리되었습니다'),
              backgroundColor: checkType == CheckType.checkIn
                  ? const Color(0xFF00A3A3)
                  : const Color(0xFF9C27B0),
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

        // 콜백 호출
        widget.onWorkToggle?.call();

      } else {
        // 에러 처리
        final errorMessage = result['error'] ?? '오류가 발생했습니다';
        final errorType = result['errorType'];

        print('❌ API 호출 실패: $errorMessage (타입: $errorType)');

        if (mounted) {
          // 인증 에러인 경우 특별한 처리
          if (errorType == 'AUTH' || errorMessage.contains('인증') || errorMessage.contains('토큰')) {
            // 로그인 상태 다시 확인
            setState(() {
              _workStatus = null;
            });
            _showLoginRequiredMessage();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
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
        }
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('네트워크 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLoginRequiredMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('로그인이 필요합니다. 다시 로그인해주세요.'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 80,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: '로그인',
            textColor: Colors.white,
            onPressed: () {
              // 로그인 화면으로 이동하는 로직
              // Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
      );
    }
  }

  void _showNoScheduleMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('오늘 예정된 근무 스케줄이 없습니다.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2196F3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 80,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: '일자리 찾기',
            textColor: Colors.white,
            onPressed: () {
              // 일자리 목록 페이지로 이동
              // Navigator.pushNamed(context, '/jobs');
            },
          ),
        ),
      );
    }
  }

  // 디버그 정보 표시
  void _showDebugInfo() async {
    print('=== 🔧 디버그 정보 표시 ===');

    // Auth 상태 체크
    await AuthService.checkFullAuthStatus();

    // API 테스트
    final result = await AttendanceService.debugCheckAuthAndAPI();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🔧 디버그 정보'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('현재 상태: $_workStatus'),
                Text('근무 중: $_isWorking'),
                Text('로딩 중: $_isLoading'),
                const SizedBox(height: 16),
                Text('API 결과: ${result['success'] ? "성공" : "실패"}'),
                if (!result['success'])
                  Text('에러: ${result['error']}'),
                const SizedBox(height: 16),
                const Text('콘솔 로그를 확인해주세요.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadTodayAttendance(); // 다시 로드
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
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