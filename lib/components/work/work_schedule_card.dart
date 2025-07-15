
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
    // 디버깅 로그 추가
    print('🎯 WorkScheduleCard 빌드 - ${schedule.company}');
    print('  - onCheckIn: ${onCheckIn != null}');
    print('  - onCheckOut: ${onCheckOut != null}');
    print('  - canCheckIn: ${schedule.canCheckIn}');
    print('  - canCheckOut: ${schedule.canCheckOut}');
    
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
                        if (schedule.jobType != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            schedule.jobType!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
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

              // 시간/급여 정보
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
                  const SizedBox(width: 12),
                  Text(
                    '(${schedule.workHours.toStringAsFixed(1)}시간)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '시급: ',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  Text(
                    schedule.hourlyRate != null ? '${schedule.hourlyRate!.toStringAsFixed(0)}원' : '-',
                    style: TextStyle(fontSize: 13, color: Colors.grey[900], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '일급: ',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  Text(
                    schedule.dailyWage != null ? '${schedule.dailyWage!.toStringAsFixed(0)}원' : '-',
                    style: TextStyle(fontSize: 13, color: Colors.grey[900], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (schedule.paymentDate != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.payment,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '지급일: ',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    Text(
                      '매월 ${schedule.paymentDate}일',
                      style: TextStyle(fontSize: 13, color: Colors.grey[900], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],

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
              if (onCheckOut != null || onEvaluate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // 퇴근 버튼 (퇴근 가능할 때만 표시)
                    if (onCheckOut != null && schedule.canCheckOut == true)
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
                            elevation: 1,
                          ),
                        ),
                      ),
                    // 근무지 평가 버튼
                    if (onEvaluate != null) ...[
                      if (onCheckOut != null && schedule.canCheckOut == true) const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEvaluate,
                          icon: const Icon(Icons.star, size: 16),
                          label: const Text('평가'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00A3A3),
                            side: const BorderSide(color: Color(0xFF00A3A3), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // 상태 메시지 (퇴근이 불가능할 때 표시)
                if (schedule.statusMessage != null && (schedule.canCheckOut != true || onCheckOut == null)) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Text(
                      schedule.statusMessage!,
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}