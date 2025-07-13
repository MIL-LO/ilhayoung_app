import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../providers/employer_job_provider.dart';
import '../../services/worker_attendance_service.dart';
import '../../services/schedule_management_service.dart';
import '../../services/applicant_management_service.dart';
import '../../models/worker_attendance_model.dart';
import '../../components/worker_management/attendance_detail_sheet.dart';
import '../../components/worker_management/schedule_detail_sheet.dart';
import '../../components/worker_management/hired_workers_dialog.dart';
import '../../components/worker_management/schedule_creation_dialog.dart';
import '../../components/common/unified_app_header.dart';

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

  // FAB 애니메이션 상태
  bool _isFabExpanded = false;

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

      final jobsResult = await JobApiService.getMyJobs();
      if (jobsResult['jobs'] == null) {
        return {
          'success': false,
          'error': '공고 목록을 불러올 수 없습니다',
        };
      }

      final jobs = jobsResult['jobs'] as List<JobPosting>? ?? [];
      print('📋 총 공고 수: ${jobs.length}');

      if (jobs.isEmpty) {
        return {
          'success': true,
          'data': [],
        };
      }

      final List<dynamic> allHiredWorkers = [];

      for (final job in jobs) {
        try {
          final jobId = job.id?.toString();
          if (jobId == null) continue;

          final applicantsResult = await ApplicantManagementService.getJobApplicants(jobId);

          if (applicantsResult['success']) {
            final applicants = applicantsResult['data'] as List<JobApplicant>? ?? [];
            final hiredApplicants = applicants.where((applicant) {
              return applicant.status.toUpperCase() == 'HIRED';
            }).toList();

            for (final applicant in hiredApplicants) {
              allHiredWorkers.add({
                'id': applicant.id,
                'name': applicant.name,
                'workLocation': job.location ?? '근무지 미정',
                'hourlyRate': double.tryParse(job.salary) ?? 12000.0,
                'jobId': jobId,
                'jobTitle': job.title,
                'hiredDate': applicant.appliedAt.toIso8601String(),
                'contact': applicant.contact,
                'status': 'HIRED',
                'applicationId': applicant.id,
                'climateScore': applicant.climateScore,
              });
            }
          }
        } catch (e) {
          print('❌ 공고 처리 중 오류: $e');
          continue;
        }
      }

      return {
        'success': true,
        'data': allHiredWorkers,
      };
    } catch (e) {
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
            // API가 Map 형태로 응답하는 경우
            final attendancesList = attendanceData['attendances'] as List<dynamic>? ??
                attendanceData['data'] as List<dynamic>? ??
                [];
            try {
              _attendances = attendancesList.map((item) => WorkerAttendance.fromJson(item)).toList();
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadData();
            },
            tooltip: '새로고침',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
            tooltip: '날짜 선택',
          ),
          const SizedBox(width: 8),
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
      floatingActionButton: _buildExpandableFab(),
    );
  }

  // === 확장 가능한 FAB 구현 ===
  Widget _buildExpandableFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isFabExpanded ? 56 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.extended(
                heroTag: "schedule_fab",
                onPressed: _isFabExpanded ? _showScheduleCreationDialog : null,
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.schedule, size: 20),
                label: const Text('스케줄 생성', style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isFabExpanded ? 56 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.extended(
                heroTag: "workers_fab",
                onPressed: _isFabExpanded ? _showHiredWorkersDialog : null,
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.people, size: 20),
                label: const Text('고용된 직원', style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ),
        FloatingActionButton(
          heroTag: "main_fab",
          onPressed: () {
            setState(() {
              _isFabExpanded = !_isFabExpanded;
            });
            HapticFeedback.lightImpact();
          },
          backgroundColor: const Color(0xFF2D3748),
          foregroundColor: Colors.white,
          child: AnimatedRotation(
            turns: _isFabExpanded ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(_isFabExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }

  // === 다이얼로그 표시 메서드들 ===
  void _showHiredWorkersDialog() {
    showDialog(
      context: context,
      builder: (context) => HiredWorkersDialog(
        hiredWorkers: _hiredWorkers,
        onWorkerSelected: _createScheduleForWorker,
      ),
    );
  }

  void _showScheduleCreationDialog() {
    if (_hiredWorkers.isEmpty) {
      _showErrorMessage('고용된 직원이 없습니다. 먼저 직원을 고용해주세요.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ScheduleCreationDialog(
        hiredWorkers: _hiredWorkers,
        onScheduleCreated: () {
          _loadData();
          setState(() {
            _isFabExpanded = false;
          });
        },
      ),
    );
  }

  void _createScheduleForWorker(dynamic worker) {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => ScheduleCreationDialog(
        hiredWorkers: _hiredWorkers,
        selectedWorker: worker,
        onScheduleCreated: () {
          _loadData();
          setState(() {
            _isFabExpanded = false;
          });
        },
      ),
    );
  }

  // === UI 빌드 메서드들 ===
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
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
                child: Text(
                  '고용: ${_hiredWorkers.length}명',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem('전체', '$totalWorkers명', Icons.people, Colors.blue[300]!),
              const SizedBox(width: 16),
              _buildSummaryItem('출근', '$presentWorkers명', Icons.check_circle, Colors.green[300]!),
              const SizedBox(width: 16),
              _buildSummaryItem('지각', '$lateWorkers명', Icons.schedule, Colors.orange[300]!),
              const SizedBox(width: 16),
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
    final filteredAttendances = _selectedStatus == 'ALL'
        ? _attendances
        : _attendances.where((a) => a.status == _selectedStatus).toList();

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
    final todaySchedules = _schedules.where((s) {
      final scheduleDate = _formatDate(s.startTime);
      return scheduleDate == _selectedDate;
    }).toList();

    if (todaySchedules.isEmpty) {
      return _buildEmptyState('스케줄');
    }

    return RefreshIndicator(
      color: const Color(0xFF2D3748),
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: todaySchedules.length,
        itemBuilder: (context, index) {
          return _buildScheduleCard(todaySchedules[index]);
        },
      ),
    );
  }

  Widget _buildAttendanceCard(WorkerAttendance attendance) {
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
                    if (attendance.status != 'PRESENT') ...[
                      Expanded(
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
                    _buildScheduleInfo('시간', schedule.timeRangeText, Icons.access_time),
                    const SizedBox(width: 16),
                    _buildScheduleInfo('시급', '₩${schedule.hourlyRate.toInt()}', Icons.attach_money),
                    const SizedBox(width: 16),
                    _buildScheduleInfo('예상급여', '₩${schedule.estimatedPay.toInt()}', Icons.payment),
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

      final result = await WorkerAttendanceService.updateStaffStatus(
        attendance.staffId,
        newStatus,
      );

      if (result['success']) {
        _showSuccessMessage('${attendance.staffName}님의 상태가 변경되었습니다');
        _loadData();
      } else {
        _showErrorMessage(result['error'] ?? '상태 변경에 실패했습니다');
      }
    } catch (e) {
      _showErrorMessage('상태 변경 중 오류가 발생했습니다: $e');
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
}