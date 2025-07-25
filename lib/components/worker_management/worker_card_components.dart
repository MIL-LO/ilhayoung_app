// lib/components/worker_management/worker_card_components.dart

import 'package:flutter/material.dart';
import '../../models/work_schedule.dart';
import '../../models/worker_attendance_model.dart' hide WorkSchedule;

class AttendanceCard extends StatelessWidget {
  final WorkerAttendance attendance;
  final VoidCallback onTap;
  final Function(String) onStatusUpdate;

  const AttendanceCard({
    Key? key,
    required this.attendance,
    required this.onTap,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildTimeInfo(),
                const SizedBox(height: 12),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
    );
  }

  Widget _buildTimeInfo() {
    return Row(
      children: [
        _buildTimeInfoItem('출근', attendance.checkInTimeText, Icons.login),
        const SizedBox(width: 16),
        _buildTimeInfoItem('퇴근', attendance.checkOutTimeText, Icons.logout),
        const SizedBox(width: 16),
        _buildTimeInfoItem('근무시간', attendance.workHoursText, Icons.schedule),
      ],
    );
  }

  Widget _buildTimeInfoItem(String label, String value, IconData icon) {
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTap,
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
              onPressed: () => onStatusUpdate('PRESENT'),
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
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final WorkSchedule schedule;
  final VoidCallback onTap;
  final Function(String) onStatusUpdate;

  const ScheduleCard({
    Key? key,
    required this.schedule,
    required this.onTap,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildScheduleInfo(),
                if (schedule.notes != null) ...[
                  const SizedBox(height: 8),
                  _buildNotesSection(),
                ],
                const SizedBox(height: 12),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
                schedule.company,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                schedule.location ?? '위치 정보 없음',
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
    );
  }

  Widget _buildScheduleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              '${schedule.startTime} - ${schedule.endTime}',
              style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 12),
            Text(
              '(${schedule.workHours.toStringAsFixed(1)}시간)',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text('시급: ', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            Text(
              schedule.hourlyRate != null ? '${schedule.hourlyRate!.toStringAsFixed(0)}원' : '-',
              style: TextStyle(fontSize: 13, color: Colors.grey[900], fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Text('일급: ', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            Text(
              schedule.dailyWage != null ? '${schedule.dailyWage!.toStringAsFixed(0)}원' : '-',
              style: TextStyle(fontSize: 13, color: Colors.grey[900], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTap,
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
        // 퇴근/평가 버튼만 남김 (시작 버튼 완전 제거)
        if (schedule.status == 'PRESENT' || schedule.status == 'LATE') ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onStatusUpdate('COMPLETED'),
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('퇴근처리'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF757575),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
        // 평가 버튼 등 추가 필요시 여기에...
      ],
    );
  }
}