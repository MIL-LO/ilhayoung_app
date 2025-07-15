// ========================================
// lib/screens/home/jeju_home_screen.dart - 수정된 API 연동 홈 화면
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 컴포넌트 imports
import '../../components/common/unified_app_header.dart';
import '../../components/work/work_status_bar.dart';
import '../../components/home/upcoming_work_card.dart';
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
  final VoidCallback? onNavigateToJobs; // 공고 리스트로 이동하는 콜백 추가

  const JejuHomeScreen({
    Key? key, 
    this.onLogout,
    this.onNavigateToJobs, // 콜백 추가
  }) : super(key: key);

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
    
    // 스케줄에서 지급일을 찾아서 다음 지급일 계산
    _nextPaymentDate = _calculateNextPaymentDate(now);
  }

  // 다음 지급일 계산
  DateTime? _calculateNextPaymentDate(DateTime now) {
    // 모든 스케줄에서 지급일 찾기
    final paymentDates = <int>{};
    
    for (final schedule in _allSchedules) {
      if (schedule.paymentDate != null) {
        final paymentDay = _extractPaymentDay(schedule.paymentDate!);
        if (paymentDay != null) {
          paymentDates.add(paymentDay);
        }
      }
    }
    
    if (paymentDates.isEmpty) {
      // 기본값: 매월 10일
      return DateTime(now.year, now.month + 1, 10);
    }
    
    // 가장 가까운 지급일 찾기
    DateTime? nextPaymentDate;
    
    for (final paymentDay in paymentDates) {
      // 이번 달 지급일
      final thisMonthPayment = DateTime(now.year, now.month, paymentDay);
      
      // 다음 달 지급일
      final nextMonthPayment = DateTime(now.year, now.month + 1, paymentDay);
      
      // 현재 날짜와 비교하여 다음 지급일 결정
      if (now.isBefore(thisMonthPayment)) {
        if (nextPaymentDate == null || thisMonthPayment.isBefore(nextPaymentDate)) {
          nextPaymentDate = thisMonthPayment;
        }
      } else {
        if (nextPaymentDate == null || nextMonthPayment.isBefore(nextPaymentDate)) {
          nextPaymentDate = nextMonthPayment;
        }
      }
    }
    
    return nextPaymentDate;
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

      // 스케줄 로드 후 지급일 계산
      _setCurrentMonth();
      
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
        final data = result['data'];
        if (data is List) {
          // API 응답을 WorkSchedule로 변환
          final convertedSchedules = data.map((item) {
            if (item is WorkSchedule) {
              return item;
            } else if (item is Map<String, dynamic>) {
              return _convertApiToWorkSchedule(item);
            } else {
              print('⚠️ 알 수 없는 데이터 타입: ${item.runtimeType}');
              return WorkSchedule(
                id: 'unknown',
                company: '알 수 없음',
                position: '알 수 없음',
                jobType: '알 수 없음',
                date: DateTime.now(),
                startTime: '09:00',
                endTime: '18:00',
                status: WorkStatus.scheduled,
                paymentDate: null,
              );
            }
          }).toList();

          print('🔍 변환된 스케줄 수: ${convertedSchedules.length}개');
          
          // 중복 스케줄 제거 (같은 날짜에 여러 스케줄이 있을 때 우선순위 적용)
          final deduplicatedSchedules = _removeDuplicateSchedules(convertedSchedules);
          
          print('🔍 중복 제거 후 스케줄 수: ${deduplicatedSchedules.length}개');
          
          setState(() {
            _allSchedules = deduplicatedSchedules;
          });
        } else {
          setState(() {
            _allSchedules = [];
          });
        }

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
    final today = DateTime(now.year, now.month, now.day);
    
    // 오늘 또는 미래의 스케줄 중에서 아직 시작하지 않은 근무 찾기
    final scheduledWorks = _allSchedules
        .where((schedule) {
          // 스케줄된 상태이고
          if (schedule.status != WorkStatus.scheduled) return false;
          
          // 오늘 또는 미래 날짜이고
          final scheduleDate = DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
          if (scheduleDate.isBefore(today)) return false;
          
          // 오늘인 경우 시작 시간이 아직 지나지 않았는지 확인
          if (scheduleDate.isAtSameMomentAs(today)) {
            final startTimeParts = schedule.startTime.split(':');
            final startHour = int.parse(startTimeParts[0]);
            final startMinute = int.parse(startTimeParts[1]);
            final workStartTime = DateTime(now.year, now.month, now.day, startHour, startMinute);
            
            // 시작 시간이 아직 지나지 않았으면 포함
            return now.isBefore(workStartTime);
          }
          
          // 미래 날짜는 모두 포함
          return true;
        })
        .toList();

    if (scheduledWorks.isNotEmpty) {
      scheduledWorks.sort((a, b) => a.date.compareTo(b.date));
      setState(() {
        _upcomingWork = scheduledWorks.first;
      });
      print('✅ 다가오는 근무 찾음: ${_upcomingWork!.company} (${_upcomingWork!.date})');
    } else {
      setState(() {
        _upcomingWork = null;
      });
      print('ℹ️ 다가오는 근무 없음');
    }
  }

  // API 응답을 WorkSchedule 모델로 변환
  WorkSchedule _convertApiToWorkSchedule(Map<String, dynamic> apiData) {
    try {
      print('변환할 데이터: $apiData');

      // API 응답 필드를 안전하게 추출
      final id = apiData['id']?.toString() ?? '0';
      final company = apiData['companyName']?.toString() ?? '회사명 없음';
      final position = apiData['position']?.toString() ?? '직무 없음';

      // workDate를 date로 변환
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

      // 새로 추가된 필드들 파싱 (임시로 기본값 true로 설정)
      final canCheckIn = true;  // 임시로 true로 설정
      final canCheckOut = true; // 임시로 true로 설정
      final statusMessage = apiData['statusMessage'] as String?;
      
      // paymentDate와 jobType 필드 추가
      final paymentDate = apiData['paymentDate']?.toString();
      final jobType = apiData['jobType']?.toString();

      print('🔍 paymentDate 파싱: ${apiData['paymentDate']} -> $paymentDate');
      print('🔍 jobType 파싱: ${apiData['jobType']} -> $jobType');
      print('변환 완료 - id: $id, company: $company, date: $date, status: $status, paymentDate: $paymentDate, jobType: $jobType');

      return WorkSchedule(
        id: id,
        company: company,
        position: position,
        jobType: jobType, // 직무 유형 추가
        date: date,
        startTime: startTime,
        endTime: endTime,
        status: status,
        location: location,
        hourlyRate: hourlyRate,
        notes: notes,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        canCheckIn: canCheckIn,
        canCheckOut: canCheckOut,
        statusMessage: statusMessage,
        paymentDate: paymentDate, // 지급일 추가
      );
    } catch (e) {
      print('❌ API 데이터 변환 오류: $e');
      print('문제된 데이터: $apiData');

      // 기본값으로 안전하게 생성
      return WorkSchedule(
        id: '0',
        company: '데이터 오류',
        position: '직무 미상',
        jobType: '알 수 없음',
        date: DateTime.now(),
        startTime: '09:00',
        endTime: '18:00',
        status: WorkStatus.scheduled,
        canCheckIn: false,
        canCheckOut: false,
        statusMessage: '데이터 파싱 오류',
        paymentDate: null,
      );
    }
  }

  // 시급 데이터 안전 파싱
  double? _parseHourlyRate(Map<String, dynamic> apiData) {
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
    return null;
  }

  // 중복 스케줄 제거 (같은 날짜에 여러 스케줄이 있을 때 우선순위 적용)
  List<WorkSchedule> _removeDuplicateSchedules(List<WorkSchedule> schedules) {
    print('🔍 중복 제거 시작 - 입력 스케줄 수: ${schedules.length}개');
    
    final Map<String, WorkSchedule> uniqueSchedules = {};
    
    for (final schedule in schedules) {
      final dateKey = '${schedule.date.year}-${schedule.date.month.toString().padLeft(2, '0')}-${schedule.date.day.toString().padLeft(2, '0')}';
      print('🔍 처리 중: ${dateKey} - ${schedule.status}');
      
      if (!uniqueSchedules.containsKey(dateKey)) {
        uniqueSchedules[dateKey] = schedule;
        print('  ✅ 새 스케줄 추가: ${schedule.status}');
      } else {
        // 이미 같은 날짜의 스케줄이 있으면 우선순위에 따라 선택
        final existing = uniqueSchedules[dateKey]!;
        final priority = _getStatusPriority(schedule.status);
        final existingPriority = _getStatusPriority(existing.status);
        
        print('  🔄 중복 발견: 기존=${existing.status}(우선순위:$existingPriority) vs 새=${schedule.status}(우선순위:$priority)');
        
        if (priority > existingPriority) {
          uniqueSchedules[dateKey] = schedule;
          print('  ✅ 스케줄 교체: ${existing.status} → ${schedule.status}');
        } else {
          print('  ❌ 스케줄 유지: ${existing.status} (우선순위가 더 높음)');
        }
      }
    }
    
    final result = uniqueSchedules.values.toList();
    result.sort((a, b) => a.date.compareTo(b.date));
    
    print('🔍 중복 제거 완료: ${schedules.length}개 → ${result.length}개');
    for (final schedule in result) {
      print('  - ${schedule.date} ${schedule.status}');
    }
    return result;
  }

  // 상태별 우선순위 (높을수록 우선)
  int _getStatusPriority(WorkStatus status) {
    switch (status) {
      case WorkStatus.present:
        return 5; // 출근 중 (최고 우선순위)
      case WorkStatus.completed:
        return 4; // 완료
      case WorkStatus.late:
        return 3; // 지각
      case WorkStatus.absent:
        return 2; // 결근
      case WorkStatus.scheduled:
        return 1; // 예정 (최저 우선순위)
    }
  }

  // API status 문자열을 WorkStatus enum으로 변환
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

  void _calculateStats() {
    final now = DateTime.now();

    // 지급일 비례 예상 급여 계산
    _expectedSalary = _calculatePaymentDateBasedSalary(now);

    print('📊 통계 계산 완료: 예상급여 ${_expectedSalary}원');
  }

  // 지급일 비례 급여 계산
  int _calculatePaymentDateBasedSalary(DateTime now) {
    print('🔍 급여 계산 시작 - 현재 시간: $now');
    print('🔍 전체 스케줄 수: ${_allSchedules.length}');
    
    int totalSalary = 0;

    final schedulesByPaymentDate = <String, List<WorkSchedule>>{};
    for (final schedule in _allSchedules) {
      if (schedule.paymentDate != null) {
        final paymentDate = schedule.paymentDate!;
        schedulesByPaymentDate.putIfAbsent(paymentDate, () => []).add(schedule);
        print('📅 스케줄 추가: ${schedule.date} - 지급일: $paymentDate');
      } else {
        print('⚠️ paymentDate가 null인 스케줄: ${schedule.date}');
      }
    }

    print('🔍 지급일별 그룹화 결과: ${schedulesByPaymentDate.keys}');

    for (final entry in schedulesByPaymentDate.entries) {
      final paymentDateStr = entry.key;
      final schedules = entry.value;
      final paymentDay = _extractPaymentDay(paymentDateStr);
      if (paymentDay == null) continue;

      final thisMonthPaymentDate = DateTime(now.year, now.month, paymentDay);

      // 지급일까지의 급여 계산 (지급일이 지나지 않았으면 지급일까지, 지났으면 지급일까지)
      final rangeEnd = thisMonthPaymentDate;

      print('💡 [디버깅] 지급일 $paymentDateStr, rangeEnd: $rangeEnd');
      print('💡 [디버깅] 이번달 지급일: $thisMonthPaymentDate');
      print('💡 [디버깅] 현재 시간: $now');
      print('💡 [디버깅] 필터링 전 스케줄 수: ${schedules.length}');

      final targetMonthSchedules = schedules.where((schedule) {
        final isThisMonth = schedule.date.year == now.year && schedule.date.month == now.month;
        final isInRange = !schedule.date.isAfter(rangeEnd);
        print('  - 스케줄 ${schedule.date}: 이번달=$isThisMonth, 범위내=$isInRange');
        return isThisMonth && isInRange;
      }).toList();

      print('💡 [디버깅] 필터링 후 스케줄 수: ${targetMonthSchedules.length}');
      
      for (final s in targetMonthSchedules) {
        print('  - 스케줄: ${s.date} 시급:${s.hourlyRate} 시간:${s.workHours}');
      }

      final monthSalary = targetMonthSchedules.fold<int>(0, (sum, schedule) {
        final hours = _calculateWorkHours(schedule);
        final hourlyRate = schedule.hourlyRate;
        print('    > 합산: ${schedule.date} * $hourlyRate * $hours');
        if (hourlyRate != null) {
          return sum + (hours * hourlyRate).toInt();
        }
        return sum;
      });

      print('💰 지급일 $paymentDateStr 계산: ${now.month}월 1일~${rangeEnd.day}일 급여 ${monthSalary}원 (${targetMonthSchedules.length}일 근무)');
      totalSalary += monthSalary;
    }

    print('🎯 최종 급여: $totalSalary원');
    return totalSalary;
  }

  // 지급일 문자열에서 날짜 추출
  int? _extractPaymentDay(String paymentDateStr) {
    try {
      // "매월 25일" 형태에서 숫자만 추출
      final regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(paymentDateStr);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    } catch (e) {
      print('지급일 파싱 오류: $paymentDateStr -> $e');
    }
    return null;
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
      return 0; // 시간 계산 실패 시 0 반환
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
                onNavigateToJobs: widget.onNavigateToJobs, // 콜백 전달
              ),
            ),

            // 다가오는 근무 일정 카드
            SliverToBoxAdapter(
              child: UpcomingWorkCard(
                upcomingWork: _upcomingWork,
                userName: _userName,
              ),
            ),

            // 급여 계산
            SliverToBoxAdapter(
              child: SalaryCalculationWidget(
                monthlyHours: 0, // 월간 근무시간은 제거했으므로 0으로 설정
                expectedSalary: _expectedSalary,
                currentMonth: _currentMonth,
                nextPaymentDate: _nextPaymentDate,
              ),
            ),

            // 최근 지원 현황
            if (_recentApplications.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildRecentApplicationsWidget(),
              ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
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



  // 유틸리티 메소드들
  Color _getApplicationStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return const Color(0xFF2196F3);
      case ApplicationStatus.interview:
        return const Color(0xFFFF9800);
      case ApplicationStatus.hired:
        return const Color(0xFF4CAF50);
      case ApplicationStatus.rejected:
        return const Color(0xFFF44336);
    }
  }

  String _getApplicationStatusText(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return '지원완료';
      case ApplicationStatus.interview:
        return '면접 요청';
      case ApplicationStatus.hired:
        return '채용 확정';
      case ApplicationStatus.rejected:
        return '채용 거절';
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

  void _onViewAllApplications() {
    // 전체 지원내역으로 이동
    print('전체 지원내역 보기');
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
            children: _buildNotificationItems(),
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

  List<Widget> _buildNotificationItems() {
    final List<Widget> items = [];
    
    if (_upcomingWork != null) {
      items.add(_buildNotificationItem(
        '다가오는 근무 일정',
        '${_upcomingWork!.company}에서 ${_formatWorkTime(_upcomingWork!)} 근무 예정',
        '알림',
      ));
    }
    
    if (_recentApplications.isNotEmpty) {
      items.addAll([
        const Divider(),
        _buildNotificationItem(
          '최근 지원 현황',
          '${_recentApplications.where((app) => app.status == ApplicationStatus.applied).length}개 지원서가 검토 중입니다',
          '정보',
        ),
      ]);
    }
    
    // 완료된 근무 수 계산
    final completedJobs = _allSchedules
        .where((schedule) =>
            schedule.status == WorkStatus.completed &&
            schedule.date.year == DateTime.now().year &&
            schedule.date.month == DateTime.now().month)
        .length;
    
    if (completedJobs > 0) {
      items.addAll([
        const Divider(),
        _buildNotificationItem(
          '이번 달 근무 완료',
          '$completedJobs개의 근무를 완료했습니다',
          '성과',
        ),
      ]);
    }
    
    if (_upcomingWork == null && _recentApplications.isEmpty) {
      items.add(_buildNotificationItem(
        '새로운 기회를 찾아보세요!',
        '제주 지역의 다양한 일자리를 확인해보세요',
        '추천',
      ));
    }
    
    return items;
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