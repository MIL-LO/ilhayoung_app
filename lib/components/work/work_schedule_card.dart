
import 'package:flutter/material.dart';
import '../../models/work_schedule.dart';

class WorkScheduleCard extends StatelessWidget {
  final WorkSchedule schedule;
  final VoidCallback? onTap;
  final VoidCallback? onCheckIn;
  final VoidCallback? onCheckOut;
  final VoidCallback? onEvaluate;

  const WorkScheduleCard({
    Key? key,
    required this.schedule,
    this.onTap,
    this.onCheckIn,
    this.onCheckOut,
    this.onEvaluate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        border: Border.all(
          color: schedule.statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (회사명, 상태)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.company,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: schedule.statusColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          schedule.position,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: schedule.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          schedule.statusIcon,
                          size: 14,
                          color: schedule.statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          schedule.statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: schedule.statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 시간 정보
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${schedule.startTime} - ${schedule.endTime}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (schedule.hourlyRate != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${schedule.hourlyRate!.toStringAsFixed(0)}원',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              if (schedule.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        schedule.location!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // 액션 버튼들
              if (onCheckIn != null || onCheckOut != null || onEvaluate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (onCheckIn != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onCheckIn,
                          icon: const Icon(Icons.login, size: 16),
                          label: const Text('출근'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    if (onCheckIn != null && onCheckOut != null) const SizedBox(width: 8),
                    if (onCheckOut != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onCheckOut,
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('퇴근'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    if ((onCheckIn != null || onCheckOut != null) && onEvaluate != null)
                      const SizedBox(width: 8),
                    if (onEvaluate != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEvaluate,
                          icon: const Icon(Icons.star, size: 16),
                          label: const Text('평가'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00A3A3),
                            side: const BorderSide(color: Color(0xFF00A3A3)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}