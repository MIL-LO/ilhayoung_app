import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 컴포넌트 imports
import '../../../components/common/unified_app_header.dart';
import '../../../components/work/work_calendar.dart';
import '../../../components/work/work_schedule_card.dart';
import '../../../components/work/work_filter_toggle.dart';
import '../../../models/work_schedule.dart';
import '../../../services/mock_schedule_service.dart';

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

  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  bool _showMyWorkOnly = false;

  List<WorkSchedule> _allSchedules = [];
  List<WorkSchedule> _filteredSchedules = [];
  List<WorkSchedule> _selectedDateSchedules = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadSchedules();
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

  void _loadSchedules() {
    setState(() {
      _allSchedules = MockScheduleService.instance.generateSchedules(months: 3);
      _updateFilteredSchedules();
    });
  }

  void _updateFilteredSchedules() {
    // 월별 필터링
    final monthSchedules = MockScheduleService.instance.getSchedulesForMonth(
      _allSchedules,
      _currentMonth
    );

    // 내 근무 필터링
    _filteredSchedules = MockScheduleService.instance.filterMyWork(
      monthSchedules,
      _showMyWorkOnly
    );

    // 선택된 날짜의 스케줄
    _selectedDateSchedules = MockScheduleService.instance.getSchedulesForDate(
      _filteredSchedules,
      _selectedDate
    );
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
        subtitle: '내 스케줄을 확인하세요',
        emoji: '🗓️',
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: Color(0xFF00A3A3), size: 20),
            onPressed: _goToToday,
            tooltip: '오늘로 이동',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // 필터 토글
            SliverToBoxAdapter(
              child: WorkFilterToggle(
                showMyWorkOnly: _showMyWorkOnly,
                onToggle: _onToggleFilter,
              ),
            ),

            // 캘린더
            SliverToBoxAdapter(
              child: WorkCalendar(
                currentMonth: _currentMonth,
                selectedDate: _selectedDate,
                schedules: _filteredSchedules,
                onDateSelected: _onDateSelected,
                onMonthChanged: _onMonthChanged,
              ),
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
      ),
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
                  '선택한 날짜에 일정이 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '다른 날짜를 선택해보세요',
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
            ),
          );
        },
        childCount: _selectedDateSchedules.length,
      ),
    );
  }

  // 이벤트 핸들러들
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedDateSchedules = MockScheduleService.instance.getSchedulesForDate(
        _filteredSchedules,
        date
      );
    });
  }

  void _onMonthChanged(DateTime month) {
    setState(() {
      _currentMonth = month;
      _updateFilteredSchedules();
    });
  }

  void _onToggleFilter(bool showMyWorkOnly) {
    setState(() {
      _showMyWorkOnly = showMyWorkOnly;
      _updateFilteredSchedules();
    });
  }

  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _selectedDate = today;
      _currentMonth = DateTime(today.year, today.month, 1);
      _updateFilteredSchedules();
    });
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
      height: MediaQuery.of(context).size.height * 0.6,
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
                  if (schedule.isMyWork)
                    _buildDetailItem(
                      Icons.person,
                      '구분',
                      '내 근무',
                    ),
                ],
              ),
            ),
          ),

          // 액션 버튼들
          if (schedule.status == 'scheduled')
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showCancelDialog(schedule);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('일정 취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditDialog(schedule);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A3A3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '일정 수정',
                        style: TextStyle(color: Colors.white),
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

  void _showCancelDialog(WorkSchedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 취소'),
        content: Text('${schedule.company}의 근무 일정을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니요'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('일정이 취소되었습니다'),
                  backgroundColor: Color(0xFFFF6B35),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('네, 취소합니다', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(WorkSchedule schedule) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('일정 수정 기능 준비 중입니다'),
        backgroundColor: Color(0xFF00A3A3),
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