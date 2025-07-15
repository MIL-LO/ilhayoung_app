import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ilhayoung_app/components/common/unified_app_header.dart';
import 'package:ilhayoung_app/components/worker_management/attendance_detail_sheet.dart';
import 'package:ilhayoung_app/components/worker_management/schedule_detail_sheet.dart';
import 'package:ilhayoung_app/models/worker_attendance_model.dart';
import 'package:ilhayoung_app/screens/employer/workers/hired_workers_screen.dart';
import 'package:ilhayoung_app/services/applicant_management_service.dart';
import 'package:ilhayoung_app/services/schedule_management_service.dart';
import 'package:ilhayoung_app/services/worker_attendance_service.dart';
import 'package:ilhayoung_app/services/job_api_service.dart';

class WorkerManagementScreen extends StatefulWidget {
  const WorkerManagementScreen({Key? key}) : super(key: key);

  @override
  State<WorkerManagementScreen> createState() => _WorkerManagementScreenState();
}

class _WorkerManagementScreenState extends State<WorkerManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // 데이터 상태
  List<WorkerAttendance> _attendances = [];
  List<WorkSchedule> _schedules = [];
  List<dynamic> _hiredWorkers = [];
  bool _isLoading = true;
  String? _errorMessage;

  // 필터링
  String _selectedDate = '';
  String _selectedStatus = 'ALL';
  
  // 로컬 상태 보존을 위한 Map (직원 ID -> 상태)
  final Map<String, String> _localStatusMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDate = _formatDate(DateTime.now());
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // === 모든 공고에서 HIRED 상태인 지원자들을 가져오기 ===
  Future<Map<String, dynamic>> _getHiredWorkersFromAllJobs() async {
    try {
      print('=== 모든 공고에서 HIRED 직원 조회 시작 ===');
      
      final jobsResult = await JobApiService.getJobPostings(myJobsOnly: true);
      if (!jobsResult['success']) {
        return {
          'success': false,
          'error': '채용공고 목록을 불러올 수 없습니다: ${jobsResult['error']}',
        };
      }

      final jobs = jobsResult['data'] as List<dynamic>? ?? [];
      print('📋 총 공고 수: ${jobs.length}');

      final List<dynamic> allHiredWorkers = [];

      for (final job in jobs) {
        try {
          final jobId = job.id?.toString();
          if (jobId == null) continue;

          print('=== 채용공고 지원자 목록 조회 API 호출 ===');
          print('공고 ID: $jobId');
          
          final applicantsResult = await ApplicantManagementService.getJobApplicants(jobId);

          if (applicantsResult['success']) {
            final applicants = applicantsResult['data'] as List<dynamic>? ?? [];
            final hiredApplicants = applicants.where((applicant) {
              return applicant.status?.toString().toUpperCase() == 'HIRED';
            }).toList();

            print('✅ 공고 $jobId에서 HIRED 직원 ${hiredApplicants.length}명 발견');

            for (final applicant in hiredApplicants) {
              // 실제 지원자 정보를 사용
              allHiredWorkers.add({
                'id': applicant.id?.toString() ?? '',
                'name': applicant.name?.toString() ?? '이름 없음',
                'contact': applicant.contact?.toString() ?? '연락처 없음',
                'climateScore': applicant.climateScore?.toInt() ?? 0,
                'workLocation': job.workLocation?.toString() ?? '',
                'hourlyRate': job.salary?.toDouble() ?? 0.0,
                'jobId': jobId,
                'jobTitle': job.title?.toString() ?? '',
                'companyName': job.companyName?.toString() ?? '',
                'position': job.position?.toString() ?? '',
                'hiredDate': applicant.appliedAt?.toString() ?? '',
                'status': 'HIRED',
                'applicationId': applicant.id?.toString() ?? '',
              });
            }
          } else {
            print('❌ 공고 $jobId 지원자 목록 조회 실패: ${applicantsResult['error']}');
          }
        } catch (e) {
          print('❌ 공고 처리 중 오류: $e');
          continue;
        }
      }

      print('✅ 총 HIRED 직원 수: ${allHiredWorkers.length}명');
      
      return {
        'success': true,
        'data': allHiredWorkers,
      };
    } catch (e) {
      print('❌ HIRED 직원 조회 중 오류: $e');
      return {
        'success': false,
        'error': 'HIRED 직원 정보를 불러오는 중 오류가 발생했습니다: $e',
      };
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        WorkerAttendanceService.getAttendanceOverview(),
        ScheduleManagementService.getMonthlySchedules(),
        _getHiredWorkersFromAllJobs(),
      ]);

      if (mounted) {
        final attendanceResult = results[0];
        final scheduleResult = results[1];
        final workersResult = results[2];

        // 출석 데이터 처리 - 타입 안전성 강화
        if (attendanceResult['success']) {
          final attendanceData = attendanceResult['data'];
          print('출석 데이터 타입: ${attendanceData.runtimeType}');
          print('출석 데이터 내용: $attendanceData');

          // 데이터 타입 확인 후 안전하게 처리
          if (attendanceData is List) {
            try {
              _attendances = attendanceData.map((item) => WorkerAttendance.fromJson(item)).toList();
            } catch (e) {
              print('❌ WorkerAttendance 변환 오류: $e');
              _attendances = [];
            }
          } else if (attendanceData is Map) {
            // API가 Map 형태로 응답하는 경우 - workers 필드에서 직원 목록 추출
            final workersList = attendanceData['workers'] as List<dynamic>? ?? [];
            try {
              _attendances = workersList.map((item) => WorkerAttendance.fromJson(item)).toList();
              print('✅ 출석 데이터 파싱 성공: ${_attendances.length}명');
            } catch (e) {
              print('❌ WorkerAttendance 변환 오류 (Map): $e');
              _attendances = [];
            }
          } else {
            print('⚠️ 예상하지 못한 출석 데이터 형식: ${attendanceData.runtimeType}');
            _attendances = [];
          }
        } else {
          print('❌ 출석 데이터 로드 실패: ${attendanceResult['error']}');
          _attendances = [];
        }

        // 스케줄 데이터 처리 - 타입 안전성 강화
        if (scheduleResult['success']) {
          final scheduleData = scheduleResult['data'];
          print('스케줄 데이터 타입: ${scheduleData.runtimeType}');
          print('스케줄 데이터 내용: $scheduleData');

          if (scheduleData is List) {
            try {
              _schedules = scheduleData.map((item) => WorkSchedule.fromJson(item)).toList();
            } catch (e) {
              print('❌ WorkSchedule 변환 오류: $e');
              _schedules = [];
            }
          } else if (scheduleData is Map) {
            final schedulesList = scheduleData['schedules'] as List<dynamic>? ??
                scheduleData['data'] as List<dynamic>? ??
                [];
            try {
              _schedules = schedulesList.map((item) => WorkSchedule.fromJson(item)).toList();
            } catch (e) {
              print('❌ WorkSchedule 변환 오류 (Map): $e');
              _schedules = [];
            }
          } else {
            print('⚠️ 예상하지 못한 스케줄 데이터 형식: ${scheduleData.runtimeType}');
            _schedules = [];
          }
        } else {
          print('❌ 스케줄 데이터 로드 실패: ${scheduleResult['error']}');
          _schedules = [];
        }

        // 고용된 직원 데이터 처리
        if (workersResult['success']) {
          _hiredWorkers = workersResult['data'] as List<dynamic>? ?? [];
          print('✅ 고용된 직원 수: ${_hiredWorkers.length}');
          
          // 출석 기록에 고용된 직원의 상세 정보 연결
          _enrichAttendanceData();
          
          // 스케줄 데이터에 직원 정보 보강
          _enrichScheduleData();
        } else {
          print('❌ 고용된 직원 데이터 로드 실패: ${workersResult['error']}');
          _hiredWorkers = [];
        }

        print('=== 데이터 로드 완료 ===');
        print('출석 기록: ${_attendances.length}개');
        print('스케줄: ${_schedules.length}개');
        print('고용된 직원: ${_hiredWorkers.length}명');

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 전체 데이터 로드 오류: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '데이터를 불러오는데 실패했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// 출석 기록에 고용된 직원의 상세 정보를 연결
  void _enrichAttendanceData() {
    if (_hiredWorkers.isEmpty || _attendances.isEmpty) return;
    
    print('=== 출석 데이터 보강 시작 ===');
    
    // 고용된 직원 정보를 Map으로 변환 (이름을 키로 사용하여 매칭)
    final hiredWorkersMap = <String, Map<String, dynamic>>{};
    for (final worker in _hiredWorkers) {
      final name = worker['name']?.toString() ?? '';
      if (name.isNotEmpty) {
        hiredWorkersMap[name] = worker;
      }
    }
    
    print('고용된 직원 Map (이름 기준): ${hiredWorkersMap.keys.toList()}');
    print('출석 기록 직원들: ${_attendances.map((a) => a.staffName).toList()}');
    print('스케줄 직원들: ${_schedules.map((s) => s.staffName).toList()}');
    
    // 출석 기록을 보강 (기본 정보만)
    for (int i = 0; i < _attendances.length; i++) {
      final attendance = _attendances[i];
      final hiredWorker = hiredWorkersMap[attendance.staffName];
      
      if (hiredWorker != null) {
        print('직원 ${attendance.staffName}의 기본 정보 연결');
        
        final position = hiredWorker['position']?.toString() ?? '';
        final workLocation = hiredWorker['workLocation']?.toString() ?? attendance.workLocation;
        
        // 상태 보존: 로컬 상태가 있으면 우선 사용, 없으면 서버 상태 사용
        final localStatus = _localStatusMap[attendance.staffId];
        final preservedStatus = localStatus ?? attendance.status;
        
        print('직원 ${attendance.staffName} 상태 보존 - 서버: ${attendance.status}, 로컬: $localStatus, 최종: $preservedStatus');
        
        // 출근 관리에서는 기본 정보만 표시
        _attendances[i] = attendance.copyWith(
          workLocation: workLocation,
          notes: '직책: $position',
          status: preservedStatus, // 상태 보존
        );
      } else {
        print('직원 ${attendance.staffName}의 기본 정보를 찾을 수 없음 (이름: ${attendance.staffName})');
        
        // 스케줄에서 해당 직원의 기본 정보 찾기
        final todaySchedule = _schedules.where((s) {
          final scheduleDate = _formatDate(s.startTime);
          return scheduleDate == _selectedDate && s.staffName == attendance.staffName;
        }).firstOrNull;
        
        if (todaySchedule != null) {
          print('스케줄에서 직원 ${attendance.staffName}의 기본 정보 찾음');
          
          // 상태 보존
          final localStatus = _localStatusMap[attendance.staffId];
          final preservedStatus = localStatus ?? attendance.status;
          
          _attendances[i] = attendance.copyWith(
            notes: '직책: ${todaySchedule.position ?? '미확인'}',
            status: preservedStatus, // 상태 보존
          );
        } else {
          // 상태 보존
          final localStatus = _localStatusMap[attendance.staffId];
          final preservedStatus = localStatus ?? attendance.status;
          
          _attendances[i] = attendance.copyWith(
            notes: '직책: 미확인',
            status: preservedStatus, // 상태 보존
          );
        }
      }
    }
    
    print('=== 출석 데이터 보강 완료 ===');
  }

  /// 스케줄 데이터에 직원 정보를 보강
  void _enrichScheduleData() {
    if (_hiredWorkers.isEmpty || _schedules.isEmpty) return;
    
    print('=== 스케줄 데이터 보강 시작 ===');
    
    // 출석 데이터에서 직원 정보 가져오기 (이름이 확실히 있는 데이터)
    final attendanceWorkerNames = _attendances.map((a) => a.staffName).where((name) => name.isNotEmpty).toSet();
    print('출석 데이터 직원들: $attendanceWorkerNames');
    
    // 고용된 직원 정보를 Map으로 변환
    final hiredWorkersMap = <String, Map<String, dynamic>>{};
    for (final worker in _hiredWorkers) {
      final name = worker['name']?.toString() ?? '';
      if (name.isNotEmpty) {
        hiredWorkersMap[name] = worker;
      }
    }
    
    // 스케줄 데이터 보강 - 모든 스케줄에 직원 이름 추가
    for (int i = 0; i < _schedules.length; i++) {
      final schedule = _schedules[i];
      
      // 모든 스케줄에 직원 이름 추가 (비어있거나 빈 문자열인 경우)
      if (attendanceWorkerNames.isNotEmpty) {
        final workerName = attendanceWorkerNames.first;
        
        // 스케줄에 직원 이름이 비어있거나 빈 문자열인 경우에만 추가
        if (schedule.staffName.isEmpty || schedule.staffName == '') {
          print('스케줄 ${schedule.scheduleId}에 직원 이름 추가: $workerName');
        }
        
        // 고용된 직원 정보에서 상세 정보 가져오기
        final hiredWorker = hiredWorkersMap[workerName];
        final position = hiredWorker?['position']?.toString() ?? '';
        final workLocation = hiredWorker?['workLocation']?.toString() ?? schedule.workLocation;
        final hourlyRate = hiredWorker?['hourlyRate']?.toDouble() ?? schedule.hourlyRate;
        final jobTitle = hiredWorker?['jobTitle']?.toString() ?? '';
        
        _schedules[i] = schedule.copyWith(
          staffName: workerName,
          workLocation: workLocation,
          hourlyRate: hourlyRate,
          position: position,
          jobTitle: jobTitle,
        );
      }
    }
    
    print('=== 스케줄 데이터 보강 완료 ===');
    print('보강된 스케줄 직원들: ${_schedules.map((s) => s.staffName).toList()}');
  }



  /// 시간을 HH:mm 형식으로 포맷
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 근무 시간과 시급을 기반으로 예상급여 계산
  double _calculateEstimatedSalary(double hourlyRate, double workHours) {
    return hourlyRate * workHours;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '근무자 관리',
        subtitle: '출근 현황과 스케줄을 관리하세요',
        emoji: '👥',
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadData,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, color: Color(0xFF2D3748)),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? _buildLoadingWidget()
                : _errorMessage != null
                ? _buildErrorWidget()
                : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  // === UI 빌드 메서드들 ===
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(6),
        ),
        indicatorPadding: const EdgeInsets.all(3),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF2D3748),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.access_time, size: 18),
            text: '출근 관리',
          ),
          Tab(
            icon: Icon(Icons.schedule, size: 18),
            text: '스케줄 관리',
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildSummaryCard(),
        _buildFilterSection(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAttendanceTab(),
              _buildScheduleTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalWorkers = _attendances.length;
    final presentWorkers = _attendances.where((a) => a.status == 'PRESENT').length;
    final lateWorkers = _attendances.where((a) => a.status == 'LATE').length;
    final absentWorkers = _attendances.where((a) => a.status == 'ABSENT').length;
    
    // 예정자 수 계산: 고용된 직원 중 오늘 스케줄이 있지만 아직 출근하지 않은 직원들
    final todaySchedules = _schedules.where((s) {
      final scheduleDate = _formatDate(s.startTime);
      return scheduleDate == _selectedDate;
    }).toList();
    
    // 고용된 직원 중 오늘 스케줄이 있는 직원 수 (중복 제거, 이름 기준)
    final scheduledWorkerNames = todaySchedules
        .map((s) => s.staffName)
        .where((name) => name.isNotEmpty)
        .toSet();
    final scheduledWorkers = scheduledWorkerNames.length;
    final presentWorkerNames = _attendances
        .where((a) => a.status == 'PRESENT' || a.status == 'LATE')
        .map((a) => a.staffName)
        .where((name) => name.isNotEmpty)
        .toSet();
    final scheduledButNotPresent = scheduledWorkerNames.difference(presentWorkerNames).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3748).withOpacity(0.3),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '근무자 현황',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDate,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () => _navigateToHiredWorkers(),
                  borderRadius: BorderRadius.circular(20),
                  child: Text(
                    '고용: ${_hiredWorkers.length}명',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem('전체', '$totalWorkers명', Icons.people, Colors.blue[300]!),
              const SizedBox(width: 12),
              _buildSummaryItem('예정', '$scheduledButNotPresent명', Icons.schedule, Colors.purple[300]!),
              const SizedBox(width: 12),
              _buildSummaryItem('출근', '$presentWorkers명', Icons.check_circle, Colors.green[300]!),
              const SizedBox(width: 12),
              _buildSummaryItem('지각', '$lateWorkers명', Icons.access_time, Colors.orange[300]!),
              const SizedBox(width: 12),
              _buildSummaryItem('결근', '$absentWorkers명', Icons.cancel, Colors.red[300]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Color(0xFF2D3748)),
          const SizedBox(width: 8),
          const Text(
            '필터:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedStatus,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('전체')),
                DropdownMenuItem(value: 'PRESENT', child: Text('출근')),
                DropdownMenuItem(value: 'LATE', child: Text('지각')),
                DropdownMenuItem(value: 'ABSENT', child: Text('결근')),
                DropdownMenuItem(value: 'SCHEDULED', child: Text('예정')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    List<WorkerAttendance> filteredAttendances;
    
    print('=== 출근 관리 탭 필터링 ===');
    print('선택된 날짜: $_selectedDate');
    print('선택된 상태: $_selectedStatus');
    print('전체 출석 기록 수: ${_attendances.length}');
    print('출석 기록 직원들: ${_attendances.map((a) => a.staffName).toList()}');
    
    switch (_selectedStatus) {
      case 'ALL':
        filteredAttendances = _attendances;
        break;
      case 'SCHEDULED':
        // 예정 상태: 오늘 스케줄이 있지만 아직 출근하지 않은 직원들
        final todaySchedules = _schedules.where((s) {
          final scheduleDate = _formatDate(s.startTime);
          return scheduleDate == _selectedDate;
        }).toList();
        
        final scheduledWorkerNames = todaySchedules.map((s) => s.staffName).toSet();
        final presentWorkerNames = _attendances
            .where((a) => a.status == 'PRESENT' || a.status == 'LATE')
            .map((a) => a.staffName)
            .toSet();
        
        // 스케줄이 있지만 아직 출근하지 않은 직원들
        final scheduledButNotPresentNames = scheduledWorkerNames.difference(presentWorkerNames);
        
        // 해당 직원들의 스케줄 정보를 기반으로 가상의 출석 기록 생성
        final virtualAttendances = todaySchedules
            .where((s) => scheduledButNotPresentNames.contains(s.staffName))
            .map((schedule) => WorkerAttendance(
                  staffId: schedule.staffId,
                  staffName: schedule.staffName,
                  workLocation: schedule.workLocation,
                  status: 'SCHEDULED',
                  checkInTime: null,
                  checkOutTime: null,
                  totalWorkHours: 0.0,
                ))
            .toList();
        
        filteredAttendances = virtualAttendances;
        
        // 중복 제거 (같은 직원의 여러 스케줄이 있을 경우) - 이름 기준으로 제거
        final seenNames = <String>{};
        filteredAttendances = filteredAttendances.where((attendance) {
          if (attendance.staffName.isEmpty) return false; // 이름이 비어있으면 제외
          if (seenNames.contains(attendance.staffName)) {
            return false;
          }
          seenNames.add(attendance.staffName);
          return true;
        }).toList();
        break;
      default:
        // ALL이 아닌 경우 해당 상태의 출석 기록만 필터링
        if (_selectedStatus != 'ALL') {
          filteredAttendances = _attendances.where((a) => a.status == _selectedStatus).toList();
        } else {
          filteredAttendances = _attendances;
        }
        break;
    }

    print('필터링된 출석 기록 수: ${filteredAttendances.length}');
    print('필터링된 출석 기록 직원들: ${filteredAttendances.map((a) => a.staffName).toList()}');

    if (filteredAttendances.isEmpty) {
      return _buildEmptyState('출근 기록');
    }

    return RefreshIndicator(
      color: const Color(0xFF2D3748),
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredAttendances.length,
        itemBuilder: (context, index) {
          return _buildAttendanceCard(filteredAttendances[index]);
        },
      ),
    );
  }

  Widget _buildScheduleTab() {
    List<WorkSchedule> filteredSchedules;
    
    // 기본적으로 오늘 날짜의 스케줄만 필터링
    final todaySchedules = _schedules.where((s) {
      final scheduleDate = _formatDate(s.startTime);
      return scheduleDate == _selectedDate;
    }).toList();

    print('=== 스케줄 관리 탭 필터링 ===');
    print('선택된 날짜: $_selectedDate');
    print('선택된 상태: $_selectedStatus');
    print('전체 스케줄 수: ${_schedules.length}');
    print('오늘 스케줄 수: ${todaySchedules.length}');
    print('오늘 스케줄 직원들: ${todaySchedules.map((s) => s.staffName).toList()}');
    print('출석 기록 직원들: ${_attendances.map((a) => a.staffName).toList()}');

    switch (_selectedStatus) {
      case 'ALL':
        filteredSchedules = todaySchedules;
        break;
      case 'SCHEDULED':
        // 예정 상태: 아직 출근하지 않은 직원들의 스케줄
        final presentWorkerNames = _attendances
            .where((a) => a.status == 'PRESENT' || a.status == 'LATE')
            .map((a) => a.staffName)
            .toSet();
        
        filteredSchedules = todaySchedules
            .where((s) => !presentWorkerNames.contains(s.staffName))
            .toList();
        break;
      case 'PRESENT':
      case 'LATE':
        // 출근/지각한 직원들의 스케줄
        final presentWorkerNames = _attendances
            .where((a) => a.status == _selectedStatus)
            .map((a) => a.staffName)
            .toSet();
        
        filteredSchedules = todaySchedules
            .where((s) => presentWorkerNames.contains(s.staffName))
            .toList();
        break;
      case 'ABSENT':
        // 결근한 직원들의 스케줄 (스케줄이 있지만 출근하지 않은 경우)
        final presentWorkerNames = _attendances
            .where((a) => a.status == 'PRESENT' || a.status == 'LATE')
            .map((a) => a.staffName)
            .toSet();
        
        final scheduledWorkerNames = todaySchedules.map((s) => s.staffName).toSet();
        final absentWorkerNames = scheduledWorkerNames.difference(presentWorkerNames);
        
        filteredSchedules = todaySchedules
            .where((s) => absentWorkerNames.contains(s.staffName))
            .toList();
        break;
      default:
        // ALL이 아닌 경우 해당 상태의 스케줄만 필터링
        if (_selectedStatus != 'ALL') {
          filteredSchedules = todaySchedules.where((s) => s.status == _selectedStatus).toList();
        } else {
          filteredSchedules = todaySchedules;
        }
        break;
    }

    print('필터링된 스케줄 수: ${filteredSchedules.length}');
    print('필터링된 스케줄 직원들: ${filteredSchedules.map((s) => s.staffName).toList()}');

    // 중복 제거 (같은 직원의 여러 스케줄이 있을 경우) - 이름 기준으로 제거
    final seenNames = <String>{};
    filteredSchedules = filteredSchedules.where((schedule) {
      if (schedule.staffName.isEmpty) return false; // 이름이 비어있으면 제외
      if (seenNames.contains(schedule.staffName)) {
        return false;
      }
      seenNames.add(schedule.staffName);
      return true;
    }).toList();

    print('중복 제거 후 스케줄 수: ${filteredSchedules.length}');
    print('중복 제거 후 스케줄 직원들: ${filteredSchedules.map((s) => s.staffName).toList()}');

    if (filteredSchedules.isEmpty) {
      return _buildEmptyState('스케줄');
    }

    return RefreshIndicator(
      color: const Color(0xFF2D3748),
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredSchedules.length,
        itemBuilder: (context, index) {
          return _buildScheduleCard(filteredSchedules[index]);
        },
      ),
    );
  }

  Widget _buildAttendanceCard(WorkerAttendance attendance) {
    // 디버깅: 현재 출석 상태 출력
    print('출석 카드 빌드 - 직원: ${attendance.staffName}, 상태: ${attendance.status}');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showAttendanceDetail(attendance),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF2D3748),
                      child: Text(
                        attendance.staffName.isNotEmpty ? attendance.staffName[0] : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attendance.staffName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            attendance.workLocation,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: attendance.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: attendance.statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        attendance.statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: attendance.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTimeInfo('출근', attendance.checkInTimeText, Icons.login),
                    const SizedBox(width: 16),
                    _buildTimeInfo('퇴근', attendance.checkOutTimeText, Icons.logout),
                    const SizedBox(width: 16),
                    _buildTimeInfo('근무시간', attendance.workHoursText, Icons.schedule),
                  ],
                ),
                // 근무자 기본 정보 표시 (출근 관리에서는 간단하게)
                if (attendance.notes != null && attendance.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    attendance.notes!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAttendanceDetail(attendance),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('상세보기'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2D3748),
                          side: const BorderSide(color: Color(0xFF2D3748)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Builder(
                      builder: (context) {
                        // 디버깅: 버튼 표시 로직 확인
                        print('버튼 표시 로직 - 직원: ${attendance.staffName}, 상태: ${attendance.status}');
                        
                        if (attendance.status == 'SCHEDULED' || attendance.status == 'ABSENT') {
                          print('출근처리 버튼 표시');
                          return Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateAttendanceStatus(attendance, 'PRESENT'),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('출근처리'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          );
                        } else if (attendance.status == 'PRESENT' || attendance.status == 'LATE') {
                          print('퇴근처리 버튼 표시');
                          return Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateAttendanceStatus(attendance, 'COMPLETED'),
                              icon: const Icon(Icons.logout, size: 16),
                              label: const Text('퇴근처리'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF757575),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          );
                        } else if (attendance.status == 'COMPLETED') {
                          print('근무 완료 표시');
                          return Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    '근무 완료',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          print('알 수 없는 상태: ${attendance.status}');
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(WorkSchedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showScheduleDetail(schedule),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: schedule.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.schedule,
                        color: schedule.statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.staffName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            schedule.workLocation,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: schedule.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: schedule.statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        schedule.statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: schedule.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTimeInfo('시작', _formatTime(schedule.startTime), Icons.access_time),
                    const SizedBox(width: 16),
                    _buildTimeInfo('종료', _formatTime(schedule.endTime), Icons.access_time_filled),
                    const SizedBox(width: 16),
                    _buildTimeInfo('근무시간', schedule.durationText, Icons.schedule),
                  ],
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildScheduleInfo('시급', '₩${schedule.hourlyRate.toInt()}', Icons.attach_money),
                    const SizedBox(width: 16),
                    _buildScheduleInfo('근무지', schedule.workLocation, Icons.location_on),
                  ],
                ),
                if (schedule.notes != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      schedule.notes!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showScheduleDetail(schedule),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('상세보기'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2D3748),
                          side: const BorderSide(color: Color(0xFF2D3748)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (schedule.status == 'SCHEDULED') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateScheduleStatus(schedule, 'IN_PROGRESS'),
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('시작'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ] else if (schedule.status == 'IN_PROGRESS') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateScheduleStatus(schedule, 'COMPLETED'),
                          icon: const Icon(Icons.stop, size: 16),
                          label: const Text('완료'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF757575),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == '출근 기록' ? Icons.access_time : Icons.schedule,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '${type}이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '선택한 날짜에 대한 ${type}이 없습니다',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
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
            style: TextStyle(fontSize: 16, color: Color(0xFF2D3748)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(fontSize: 16, color: Colors.red[400]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3748),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // === 상호작용 메서드들 ===
  void _showDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = _formatDate(selectedDate);
      });
    }
  }

  void _showAttendanceDetail(WorkerAttendance attendance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttendanceDetailSheet(
        attendance: attendance,
        onStatusChanged: (newStatus) {
          _updateAttendanceStatus(attendance, newStatus);
        },
      ),
    );
  }

  void _showScheduleDetail(WorkSchedule schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleDetailSheet(
        schedule: schedule,
        onStatusChanged: (newStatus) {
          _updateScheduleStatus(schedule, newStatus);
        },
      ),
    );
  }

  Future<void> _updateAttendanceStatus(WorkerAttendance attendance, String newStatus) async {
    try {
      HapticFeedback.lightImpact();

      print('=== 출근 상태 변경 시작 ===');
      print('직원: ${attendance.staffName}');
      print('현재 상태: ${attendance.status}');
      print('새로운 상태: $newStatus');

      final result = await WorkerAttendanceService.updateStaffStatus(
        attendance.staffId,
        newStatus,
      );

      if (result['success']) {
        print('서버 응답 성공: ${result['data']}');
        
        // 로컬 상태 Map에 저장
        _localStatusMap[attendance.staffId] = newStatus;
        print('로컬 상태 저장: ${attendance.staffId} -> $newStatus');
        
        _showSuccessMessage('${attendance.staffName}님의 상태가 변경되었습니다');
        
        // 즉시 로컬 상태 업데이트
        setState(() {
          final index = _attendances.indexWhere((a) => a.staffId == attendance.staffId);
          if (index != -1) {
            _attendances[index] = attendance.copyWith(status: newStatus);
            print('출석 기록 상태 업데이트: ${_attendances[index].status}');
          }
        });
        
        // UI 강제 업데이트를 위해 여러 번 setState 호출
        if (mounted) {
          setState(() {});
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {});
            }
          });
        }
        
        // 잠시 후 서버에서 최신 데이터 다시 로드 (UI 업데이트 완료 후)
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            print('서버 데이터 재로드 시작');
            _loadData();
          }
        });
      } else {
        print('서버 응답 실패: ${result['error']}');
        _showErrorMessage(result['error'] ?? '상태 변경에 실패했습니다');
      }
    } catch (e) {
      print('출근 상태 변경 오류: $e');
      _showErrorMessage('상태 변경 중 오류가 발생했습니다');
    }
  }

  Future<void> _updateScheduleStatus(WorkSchedule schedule, String newStatus) async {
    try {
      HapticFeedback.lightImpact();

      final result = await ScheduleManagementService.updateScheduleStatus(
        schedule.scheduleId,
        newStatus,
      );

      if (result['success']) {
        _showSuccessMessage('${schedule.staffName}님의 스케줄이 변경되었습니다');
        _loadData();
      } else {
        _showErrorMessage(result['error'] ?? '스케줄 변경에 실패했습니다');
      }
    } catch (e) {
      _showErrorMessage('스케줄 변경 중 오류가 발생했습니다: $e');
    }
  }

  // === 유틸리티 메서드들 ===
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // LocalTime을 DateTime으로 변환 (오늘 날짜 기준)
  DateTime _localTimeToDateTime(DateTime localTime) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, localTime.hour, localTime.minute);
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToHiredWorkers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HiredWorkersScreen(
          hiredWorkers: _hiredWorkers,
        ),
      ),
    );
  }
}