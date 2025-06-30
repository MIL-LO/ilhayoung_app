import 'package:flutter/material.dart';
import '../../models/work_schedule.dart';

class WorkCalendar extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final List<WorkSchedule> schedules;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;

  const WorkCalendar({
    Key? key,
    required this.currentMonth,
    required this.selectedDate,
    required this.schedules,
    required this.onDateSelected,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(),
          _buildWeekDays(),
          _buildCalendarDays(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => onMonthChanged(
              DateTime(currentMonth.year, currentMonth.month - 1, 1),
            ),
            icon: const Icon(Icons.chevron_left, color: Color(0xFF00A3A3)),
          ),
          Text(
            '${currentMonth.year}년 ${currentMonth.month}월',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A3A3),
            ),
          ),
          IconButton(
            onPressed: () => onMonthChanged(
              DateTime(currentMonth.year, currentMonth.month + 1, 1),
            ),
            icon: const Icon(Icons.chevron_right, color: Color(0xFF00A3A3)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    const weekDays = ['일', '월', '화', '수', '목', '금', '토'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: weekDays.map((day) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarDays() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    // 이전 달 빈 칸
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const Expanded(child: SizedBox()));
    }

    // 현재 달 날짜들
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final daySchedules = schedules.where((s) => _isSameDay(s.date, date)).toList();

      dayWidgets.add(
        Expanded(
          child: _buildDayCell(date, daySchedules),
        ),
      );
    }

    // 주 단위로 나누기
    List<Widget> weeks = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      weeks.add(
        Row(
          children: dayWidgets.sublist(
            i,
            i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(children: weeks),
    );
  }

  Widget _buildDayCell(DateTime date, List<WorkSchedule> daySchedules) {
    final isSelected = _isSameDay(date, selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    final hasSchedule = daySchedules.isNotEmpty;

    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
            ? const Color(0xFF00A3A3).withOpacity(0.1)
            : (isToday ? const Color(0xFFFF6B35).withOpacity(0.1) : null),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
              ? const Color(0xFF00A3A3)
              : (isToday ? const Color(0xFFFF6B35) : Colors.transparent),
            width: isSelected || isToday ? 2 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                  ? const Color(0xFF00A3A3)
                  : (isToday ? const Color(0xFFFF6B35) : Colors.black),
              ),
            ),
            if (hasSchedule) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: daySchedules.take(3).map((schedule) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: schedule.statusColor,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
              if (daySchedules.length > 3)
                Text(
                  '+${daySchedules.length - 3}',
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}