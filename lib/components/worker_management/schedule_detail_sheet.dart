// lib/components/worker_management/schedule_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/worker_attendance_model.dart';

class ScheduleDetailSheet extends StatelessWidget {
  final WorkSchedule schedule;
  final Function(String) onStatusChanged;

  const ScheduleDetailSheet({
    Key? key,
    required this.schedule,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(child: _buildContent()),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.schedule,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.staffName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: schedule.statusColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        schedule.statusText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      schedule.timeRangeText,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            '스케줄 정보',
            Icons.schedule,
            [
              _buildScheduleInfoCard(),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '급여 정보',
            Icons.attach_money,
            [
              _buildPayInfoCard(),
            ],
          ),
          if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSection(
              '메모',
              Icons.note,
              [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    schedule.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (schedule.createdAt != null || schedule.updatedAt != null) ...[
            const SizedBox(height: 24),
            _buildSection(
              '기록 정보',
              Icons.history,
              [
                _buildRecordInfoCard(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3748).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2D3748),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildScheduleInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            schedule.statusColor.withOpacity(0.1),
            schedule.statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: schedule.statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: schedule.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(schedule.status),
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
                      schedule.statusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: schedule.statusColor,
                      ),
                    ),
                    Text(
                      _getStatusDescription(schedule.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: schedule.statusColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem('근무지', schedule.workLocation, Icons.place),
              const SizedBox(width: 16),
              _buildInfoItem('근무시간', schedule.durationText, Icons.schedule),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow('근무자', schedule.staffName, Icons.person),
          _buildInfoRow('근무 장소', schedule.workLocation, Icons.place),
          _buildInfoRow('날짜', schedule.dateText, Icons.calendar_today),
          if (schedule.jobTitle != null)
            _buildInfoRow('작업', schedule.jobTitle!, Icons.work),
        ],
      ),
    );
  }

  Widget _buildPayInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFE8F5E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.estimatedPayText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text(
                      '예상 급여',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPayItem('시급', schedule.hourlyRateText, Icons.payments),
              const SizedBox(width: 16),
              _buildPayItem('근무시간', schedule.durationText, Icons.access_time),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          if (schedule.createdAt != null)
            _buildInfoRowDateTime(
              '생성일시',
              schedule.createdAt!,
              Icons.add_circle_outline,
            ),
          if (schedule.updatedAt != null)
            _buildInfoRowDateTime(
              '수정일시',
              schedule.updatedAt!,
              Icons.edit,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, dynamic value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            value is DateTime ? _formatTime(value) : value.toString(),
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

  Widget _buildPayItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowDateTime(String label, DateTime value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _formatDateTime(value),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (schedule.isScheduled) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      onStatusChanged('CANCELLED');
                    },
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('취소'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      onStatusChanged('IN_PROGRESS');
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text(
                      '시작',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (schedule.isInProgress) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  onStatusChanged('COMPLETED');
                },
                icon: const Icon(Icons.check_circle, size: 20),
                label: const Text(
                  '완료',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF757575),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ] else if (schedule.isCompleted) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✅ 근무가 완료되었습니다',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (schedule.isCancelled) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red[600], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '❌ 근무가 취소되었습니다',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        onStatusChanged('SCHEDULED');
                      },
                      icon: const Icon(Icons.restore, size: 16),
                      label: const Text('복원하기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        side: BorderSide(color: Colors.red[600]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // === 유틸리티 메서드들 ===
  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Icons.schedule;
      case 'IN_PROGRESS':
        return Icons.play_circle;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      case 'PAUSED':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return '근무 예정 상태입니다';
      case 'IN_PROGRESS':
        return '현재 근무 중입니다';
      case 'COMPLETED':
        return '근무가 완료되었습니다';
      case 'CANCELLED':
        return '근무가 취소되었습니다';
      case 'PAUSED':
        return '근무가 일시정지되었습니다';
      default:
        return '상태를 확인할 수 없습니다';
    }
  }

  // DateTime을 그대로 반환 (오늘 날짜 기준 변환 불필요)
  DateTime _localTimeToDateTime(DateTime dateTime) {
    return dateTime;
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}