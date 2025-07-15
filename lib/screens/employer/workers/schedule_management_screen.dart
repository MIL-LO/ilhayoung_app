import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../services/schedule_service.dart';
import '../../../models/schedule_model.dart';
import '../../../components/common/unified_app_header.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  
  List<MonthlySchedule> _schedules = [];
  bool _isLoading = false;
  Map<DateTime, List<MonthlySchedule>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ScheduleService.getMonthlySchedules(
        _focusedDay.year,
        _focusedDay.month,
      );

      if (result['success']) {
        final schedules = result['data'] as List<MonthlySchedule>;
        setState(() {
          _schedules = schedules;
          _events = _groupSchedulesByDate(schedules);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? '스케줄 로드에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<DateTime, List<MonthlySchedule>> _groupSchedulesByDate(List<MonthlySchedule> schedules) {
    final events = <DateTime, List<MonthlySchedule>>{};
    
    for (final schedule in schedules) {
      final date = DateTime.parse(schedule.workDate);
      final key = DateTime(date.year, date.month, date.day);
      
      if (events[key] == null) {
        events[key] = [];
      }
      events[key]!.add(schedule);
    }
    
    return events;
  }

  List<MonthlySchedule> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Column(
        children: [
          const UnifiedAppHeader(
            title: '근무 스케줄 관리',
            showBackButton: true,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCalendar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        _buildCalendarHeader(),
        Expanded(
          child: TableCalendar<MonthlySchedule>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red),
              holidayTextStyle: TextStyle(color: Colors.red),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF2D3748),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFF4299E1),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Color(0xFFE53E3E),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showDaySchedule(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadSchedules();
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '${events.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '근무 스케줄',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_focusedDay.year}년 ${_focusedDay.month}월',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusLegend(),
        ],
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Row(
      children: [
        _buildLegendItem('예정', Colors.blue),
        const SizedBox(width: 8),
        _buildLegendItem('출근', Colors.green),
        const SizedBox(width: 8),
        _buildLegendItem('지각', Colors.orange),
        const SizedBox(width: 8),
        _buildLegendItem('결근', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  void _showDaySchedule(DateTime day) {
    final events = _getEventsForDay(day);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDayScheduleSheet(day, events),
    );
  }

  Widget _buildDayScheduleSheet(DateTime day, List<MonthlySchedule> events) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${day.year}년 ${day.month}월 ${day.day}일',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Text(
                      '해당 날짜에 근무 스케줄이 없습니다.',
                      style: TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final schedule = events[index];
                      return _buildScheduleCard(schedule);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(MonthlySchedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showScheduleDetail(schedule),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      schedule.companyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: schedule.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: schedule.statusColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      schedule.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: schedule.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Color(0xFF718096),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${schedule.startTime.formattedTime} - ${schedule.endTime.formattedTime}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleDetail(MonthlySchedule schedule) async {
    // 스케줄 상세 정보 조회
    final result = await ScheduleService.getScheduleDetail(schedule.id);
    
    if (result['success']) {
      final scheduleDetail = result['data'] as ScheduleDetail;
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _buildScheduleDetailDialog(scheduleDetail),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? '스케줄 상세 조회에 실패했습니다.')),
      );
    }
  }

  Widget _buildScheduleDetailDialog(ScheduleDetail schedule) {
    return AlertDialog(
      title: Text(schedule.companyName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('근무자', schedule.staffName),
          _buildDetailRow('직책', schedule.position),
          _buildDetailRow('근무일', schedule.workDate),
          _buildDetailRow('근무시간', '${schedule.startTime.formattedTime} - ${schedule.endTime.formattedTime}'),
          _buildDetailRow('근무지', schedule.workLocation),
          _buildDetailRow('시급', '${schedule.hourlyWage.toString()}원'),
          _buildDetailRow('상태', schedule.statusText),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
        if (schedule.status != 'COMPLETED')
          TextButton(
            onPressed: () => _showStatusUpdateDialog(schedule),
            child: const Text('상태 변경'),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF4A5568),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(ScheduleDetail schedule) {
    final statusOptions = [
      {'value': 'SCHEDULED', 'label': '예정', 'color': Colors.blue},
      {'value': 'PRESENT', 'label': '출근', 'color': Colors.green},
      {'value': 'LATE', 'label': '지각', 'color': Colors.orange},
      {'value': 'ABSENT', 'label': '결근', 'color': Colors.red},
      {'value': 'COMPLETED', 'label': '완료', 'color': Colors.grey},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('근무 상태 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statusOptions.map((option) {
            return ListTile(
              leading: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: option['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(option['label'] as String),
              onTap: () => _updateScheduleStatus(schedule.id, option['value'] as String),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateScheduleStatus(String scheduleId, String status) async {
    Navigator.pop(context); // 상태 선택 다이얼로그 닫기
    
    try {
      final result = await ScheduleService.updateScheduleStatus(scheduleId, status);
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('근무 상태가 변경되었습니다.')),
        );
        // 스케줄 다시 로드
        _loadSchedules();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? '상태 변경에 실패했습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }
} 