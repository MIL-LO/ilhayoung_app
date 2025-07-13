import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 컴포넌트 imports
import '../../../components/common/unified_app_header.dart';
import '../../../components/work/work_calendar.dart';
import '../../../components/work/work_schedule_card.dart';

// 서비스 imports
import '../../../services/user_info_service.dart';
import '../../../services/work_schedule_service.dart';

// 모델 imports
import '../../../models/work_schedule.dart';

// 화면 imports
import '../../evaluation/workplace_evaluation_screen.dart';
import '../../evaluation/orum_index_screen.dart';

class JejuStaffMainScreen extends StatefulWidget {
  final Function? onLogout;

  const JejuStaffMainScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<JejuStaffMainScreen> createState() => _JejuStaffMainScreenState();
}

class _JejuStaffMainScreenState extends State<JejuStaffMainScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 날짜 관련
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  // 데이터 상태
  List<WorkSchedule> _allSchedules = [];
  List<WorkSchedule> _filteredSchedules = [];
  List<WorkSchedule> _selectedDateSchedules = [];

  // 사용자 정보
  String _userName = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadInitialData();
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

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 사용자 정보 로드
      await _loadUserInfo();

      // 근무 스케줄 로드 (새로운 API 호출)
      await _loadWorkSchedulesFromAPI();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '데이터를 불러오는데 실패했습니다';
      });
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

  // 🎯 새로운 API 연동 메서드
  Future<void> _loadWorkSchedulesFromAPI() async {
    try {
      print('=== 📅 /api/schedules API 호출 시작 ===');
      print('조회 월: ${_currentMonth.year}년 ${_currentMonth.month}월');

      // /api/schedules API 호출
      final result = await WorkScheduleService.getSchedulesByMonth(
        year: _currentMonth.year,
        month: _currentMonth.month,
      );

      if (result['success']) {
        final List<dynamic> scheduleData = result['data'] ?? [];

        // API 응답을 WorkSchedule 모델로 변환
        setState(() {
          _allSchedules = scheduleData.map((item) => _convertApiToWorkSchedule(item)).toList();
          _updateFilteredSchedules();
        });

        print('✅ 스케줄 로드 완료: ${_allSchedules.length}개');
        print('📋 스케줄 상세:');
        for (var schedule in _allSchedules) {
          print('  - ${schedule.company}: ${schedule.date} ${schedule.startTime}-${schedule.endTime} (${schedule.statusText})');
        }

      } else {
        print('❌ 스케줄 로드 실패: ${result['error']}');
        setState(() {
          _allSchedules = [];
          _updateFilteredSchedules();
        });

        // 에러 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? '스케줄을 불러오는데 실패했습니다'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ 스케줄 API 호출 실패: $e');
      setState(() {
        _allSchedules = [];
        _updateFilteredSchedules();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('네트워크 오류: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // 🎯 API 응답을 WorkSchedule 모델로 변환 (수정된 버전)
  WorkSchedule _convertApiToWorkSchedule(Map<String, dynamic> apiData) {
    try {
      print('변환할 데이터: $apiData');

      // API 응답 필드를 안전하게 추출
      final id = apiData['id']?.toString() ?? '0';
      final company = apiData['companyName']?.toString() ?? '회사명 없음';
      final position = apiData['position']?.toString() ?? '직무 없음';

      // workDate를 date로 변환 (API에서는 workDate로 오지만 모델에서는 date 필요)
      DateTime date;
      final workDateRaw = apiData['workDate'];
      if (workDateRaw is String) {
        date = DateTime.parse(workDateRaw);
      } else {
        date = DateTime.now();
        print('⚠️ workDate가 문자열이 아님: $workDateRaw (${workDateRaw.runtimeType})');
      }

      // 시간 데이터 안전 변환
      final startTime = apiData['startTime']?.toString() ?? '09:00';
      final endTime = apiData['endTime']?.toString() ?? '18:00';

      // status 변환
      final status = _parseWorkStatus(apiData['status']?.toString() ?? 'SCHEDULED');

      // 선택적 필드들 안전 변환
      final location = apiData['location']?.toString();
      final hourlyRate = _parseHourlyRate(apiData);
      final notes = apiData['notes']?.toString();

      // 체크인/아웃 시간 안전 변환
      DateTime? checkInTime;
      DateTime? checkOutTime;

      if (apiData['checkInTime'] != null) {
        try {
          checkInTime = DateTime.parse(apiData['checkInTime'].toString());
        } catch (e) {
          print('checkInTime 파싱 오류: $e');
        }
      }

      if (apiData['checkOutTime'] != null) {
        try {
          checkOutTime = DateTime.parse(apiData['checkOutTime'].toString());
        } catch (e) {
          print('checkOutTime 파싱 오류: $e');
        }
      }

      print('변환 완료 - id: $id, company: $company, date: $date, status: $status');

      return WorkSchedule(
        id: '0', // String을 int로 안전하게 변환
        company: company,
        position: position,
        date: date,
        startTime: startTime,
        endTime: endTime,
        status: status,
        location: location,
        hourlyRate: hourlyRate,
        notes: notes,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
      );
    } catch (e) {
      print('❌ API 데이터 변환 오류: $e');
      print('문제된 데이터: $apiData');

      // 기본값으로 안전하게 생성
      return WorkSchedule(
        id: '0',
        company: '데이터 오류',
        position: '직무 미상',
        date: DateTime.now(),
        startTime: '09:00',
        endTime: '18:00',
        status: WorkStatus.scheduled,
      );
    }
  }

  // 🎯 시급 데이터 안전 파싱
  double? _parseHourlyRate(Map<String, dynamic> apiData) {
    // 여러 필드에서 시급 정보를 찾아서 변환
    final candidates = [
      apiData['hourlyRate'],
      apiData['hourlyWage'],
      apiData['wage'],
      apiData['rate'],
    ];

    for (final candidate in candidates) {
      if (candidate != null) {
        try {
          if (candidate is num) {
            return candidate.toDouble();
          } else if (candidate is String) {
            return double.tryParse(candidate);
          }
        } catch (e) {
          print('시급 파싱 오류: $candidate -> $e');
        }
      }
    }

    return null; // 시급 정보를 찾을 수 없음
  }

  // 🎯 API status 문자열을 WorkStatus enum으로 변환
  WorkStatus _parseWorkStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'SCHEDULED':
        return WorkStatus.scheduled;
      case 'PRESENT':
        return WorkStatus.present;
      case 'ABSENT':
        return WorkStatus.absent;
      case 'LATE':
        return WorkStatus.late;
      case 'COMPLETED':
        return WorkStatus.completed;
      default:
        return WorkStatus.scheduled;
    }
  }

  void _updateFilteredSchedules() {
    // 월별 필터링
    _filteredSchedules = _allSchedules.where((schedule) {
      return schedule.date.year == _currentMonth.year &&
          schedule.date.month == _currentMonth.month;
    }).toList();

    // 선택된 날짜의 스케줄
    _selectedDateSchedules = _filteredSchedules.where((schedule) {
      return _isSameDay(schedule.date, _selectedDate);
    }).toList();

    print('🔍 필터링 결과: 월별 ${_filteredSchedules.length}개, 선택일 ${_selectedDateSchedules.length}개');
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
        title: '근무관리',
        subtitle: _userName.isNotEmpty ? '$_userName님의 스케줄' : '내 스케줄을 확인하세요',
        emoji: '🗓️',
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
            onPressed: _showOrumIndex,
            tooltip: '오름지수',
          ),
          IconButton(
            icon: const Icon(Icons.today, color: Color(0xFF00A3A3), size: 20),
            onPressed: _goToToday,
            tooltip: '오늘로 이동',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00A3A3), size: 20),
            onPressed: _loadWorkSchedulesFromAPI, // 🎯 새로운 API 메서드 호출
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
              '📅 스케줄을 불러오는 중...',
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
              onPressed: _loadInitialData,
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
      child: CustomScrollView(
        slivers: [
          // 캘린더 섹션
          SliverToBoxAdapter(
            child: _buildCalendarSection(),
          ),

          // 간격
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          // 선택된 날짜 정보
          SliverToBoxAdapter(
            child: _buildSelectedDateHeader(),
          ),

          // 간격
          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          // 선택된 날짜의 스케줄 리스트
          _buildScheduleSliverList(),

          // 하단 여백
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
        children: [
          // 월 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left, color: Color(0xFF00A3A3)),
              ),
              Text(
                '${_currentMonth.year}년 ${_currentMonth.month}월',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A3A3),
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, color: Color(0xFF00A3A3)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 캘린더 그리드
          _buildCalendarGrid(),

          const SizedBox(height: 16),

          // 스케줄 요약
          _buildScheduleSummary(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startDayOfWeek = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // 요일 헤더
        Row(
          children: ['일', '월', '화', '수', '목', '금', '토'].map((day) =>
              Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
          ).toList(),
        ),
        const SizedBox(height: 8),

        // 날짜 그리드
        ...List.generate(6, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - startDayOfWeek + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }

              final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, DateTime.now());
              final hasSchedule = _filteredSchedules.any((s) => _isSameDay(s.date, date));

              return Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(date),
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00A3A3)
                          : (isToday ? const Color(0xFF00A3A3).withOpacity(0.2) : null),
                      borderRadius: BorderRadius.circular(8),
                      border: hasSchedule && !isSelected
                          ? Border.all(color: const Color(0xFF00A3A3), width: 1)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? const Color(0xFF00A3A3) : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }).where((row) =>
        // 빈 행 제거
        (row as Row).children.any((child) =>
        (child as Expanded).child is GestureDetector
        )
        ).toList(),
      ],
    );
  }

  Widget _buildScheduleSummary() {
    final monthlyScheduleCount = _filteredSchedules.length;
    final completedCount = _filteredSchedules.where((s) => s.status == WorkStatus.completed).length;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00A3A3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  monthlyScheduleCount.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A3A3),
                  ),
                ),
                const Text(
                  '이달 총 근무',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00A3A3),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  completedCount.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const Text(
                  '완료',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDateHeader() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00A3A3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isToday ? Icons.today : Icons.calendar_today,
              color: const Color(0xFF00A3A3),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedDate.month}월 ${_selectedDate.day}일 ${_getWeekday(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A3A3),
                  ),
                ),
                if (isToday)
                  const Text(
                    '오늘',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _selectedDateSchedules.isEmpty
                  ? Colors.grey[100]
                  : const Color(0xFF00A3A3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_selectedDateSchedules.length}개 일정',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _selectedDateSchedules.isEmpty
                    ? Colors.grey[600]
                    : const Color(0xFF00A3A3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSliverList() {
    if (_selectedDateSchedules.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  '선택한 날짜에 근무 일정이 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '새로운 일자리에 지원해보세요!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final schedule = _selectedDateSchedules[index];

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: index == _selectedDateSchedules.length - 1 ? 0 : 8,
            ),
            child: WorkScheduleCard(
              schedule: schedule,
              onTap: () => _showScheduleDetail(schedule),
              onCheckIn: schedule.canCheckIn ? () => _handleCheckIn(schedule) : null,
              onCheckOut: schedule.canCheckOut ? () => _handleCheckOut(schedule) : null,
              onEvaluate: schedule.canEvaluate
                  ? () => _showWorkplaceEvaluation(schedule)
                  : null,
            ),
          );
        },
        childCount: _selectedDateSchedules.length,
      ),
    );
  }

  // 이벤트 핸들러들
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _updateFilteredSchedules();
    });
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + direction,
        1,
      );
    });

    // 🎯 새로운 월의 데이터를 API에서 로드
    _loadWorkSchedulesFromAPI();
  }

  void _goToToday() {
    final today = DateTime.now();
    final needsReload = _currentMonth.year != today.year || _currentMonth.month != today.month;

    setState(() {
      _selectedDate = today;
      _currentMonth = DateTime(today.year, today.month, 1);
    });

    if (needsReload) {
      _loadWorkSchedulesFromAPI(); // 🎯 새로운 API 메서드 호출
    } else {
      _updateFilteredSchedules();
    }
  }

  void _showOrumIndex() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrumIndexScreen(onLogout: widget.onLogout),
      ),
    );
  }

  void _showWorkplaceEvaluation(WorkSchedule schedule) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkplaceEvaluationScreen(
          workScheduleId: schedule.id.toString(),
          company: schedule.company,
          position: schedule.position,
          workDate: schedule.date,
        ),
      ),
    );

    if (result != null) {
      // 평가 완료 후 스케줄 새로고침
      _loadWorkSchedulesFromAPI(); // 🎯 새로운 API 메서드 호출
    }
  }

  Future<void> _handleCheckIn(WorkSchedule schedule) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A3A3)),
          ),
        ),
      );

      final result = await WorkScheduleService.checkIn(schedule.id as int);

      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      if (result['success']) {
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(result['message'] ?? '출근 체크인이 완료되었습니다'),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 스케줄 새로고침
        _loadWorkSchedulesFromAPI(); // 🎯 새로운 API 메서드 호출
      } else {
        // 에러 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(result['error']),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('체크인에 실패했습니다: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleCheckOut(WorkSchedule schedule) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A3A3)),
          ),
        ),
      );

      final result = await WorkScheduleService.checkOut(schedule.id as int);

      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      if (result['success']) {
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(result['message'] ?? '퇴근 체크아웃이 완료되었습니다'),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 스케줄 새로고침
        _loadWorkSchedulesFromAPI(); // 🎯 새로운 API 메서드 호출
      } else {
        // 에러 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(result['error']),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('체크아웃에 실패했습니다: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showScheduleDetail(WorkSchedule schedule) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildScheduleDetailSheet(schedule),
    );
  }

  Widget _buildScheduleDetailSheet(WorkSchedule schedule) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: schedule.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    schedule.statusIcon,
                    color: schedule.statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.company,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: schedule.statusColor,
                        ),
                      ),
                      Text(
                        schedule.position,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 상세 정보
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    Icons.calendar_today,
                    '날짜',
                    '${schedule.date.year}년 ${schedule.date.month}월 ${schedule.date.day}일 ${_getWeekday(schedule.date)}',
                  ),
                  _buildDetailItem(
                    Icons.access_time,
                    '근무시간',
                    '${schedule.startTime} - ${schedule.endTime}',
                  ),
                  _buildDetailItem(
                    Icons.work,
                    '상태',
                    schedule.statusText,
                  ),
                  if (schedule.location != null)
                    _buildDetailItem(
                      Icons.location_on,
                      '근무지',
                      schedule.location!,
                    ),
                  if (schedule.hourlyRate != null)
                    _buildDetailItem(
                      Icons.attach_money,
                      '시급',
                      '${schedule.hourlyRate!.toStringAsFixed(0)}원',
                    ),
                  if (schedule.checkInTime != null)
                    _buildDetailItem(
                      Icons.login,
                      '출근시간',
                      '${schedule.checkInTime!.hour.toString().padLeft(2, '0')}:${schedule.checkInTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  if (schedule.checkOutTime != null)
                    _buildDetailItem(
                      Icons.logout,
                      '퇴근시간',
                      '${schedule.checkOutTime!.hour.toString().padLeft(2, '0')}:${schedule.checkOutTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  if (schedule.notes != null && schedule.notes!.isNotEmpty)
                    _buildDetailItem(
                      Icons.note,
                      '메모',
                      schedule.notes!,
                    ),
                ],
              ),
            ),
          ),

          // 액션 버튼들
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (schedule.canCheckIn)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleCheckIn(schedule);
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('출근 체크인'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (schedule.canCheckOut) ...[
                  if (schedule.canCheckIn) const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleCheckOut(schedule);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('퇴근 체크아웃'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9800),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
                if (schedule.canEvaluate) ...[
                  if (schedule.canCheckIn || schedule.canCheckOut) const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showWorkplaceEvaluation(schedule);
                      },
                      icon: const Icon(Icons.star),
                      label: const Text('근무지 평가'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00A3A3),
                        side: const BorderSide(color: Color(0xFF00A3A3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
                if (!schedule.canCheckIn && !schedule.canCheckOut && !schedule.canEvaluate)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A3A3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return '${weekdays[date.weekday % 7]}요일';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}