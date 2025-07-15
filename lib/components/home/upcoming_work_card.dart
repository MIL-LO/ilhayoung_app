import 'package:flutter/material.dart';
import '../../models/work_schedule.dart';

class UpcomingWorkCard extends StatelessWidget {
  final WorkSchedule? upcomingWork;
  final String userName;

  const UpcomingWorkCard({
    Key? key,
    this.upcomingWork,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (upcomingWork == null) {
      return _buildNoUpcomingWork();
    }

    final timeUntilWork = _calculateTimeUntilWork();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A3A3), Color(0xFF00D4AA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A3A3).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '다가오는 근무 일정',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatDate(upcomingWork!.date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 메인 메시지
          Text(
            '$userName님,',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          if (timeUntilWork.isNegative)
            const Text(
              '근무 시간이 지났어요!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              '출근까지 ${_formatTimeUntil(timeUntilWork)} 남았어요!',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 16),

          // 근무 정보
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        upcomingWork!.company,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        upcomingWork!.position,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${upcomingWork!.startTime} - ${upcomingWork!.endTime}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _calculateWorkHours(),
                      style: TextStyle(
                        fontSize: 12,
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

  Widget _buildNoUpcomingWork() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            '$userName님,',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '예정된 근무 일정이 없어요',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 공고를 확인해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Duration _calculateTimeUntilWork() {
    if (upcomingWork == null) return Duration.zero;

    final now = DateTime.now();
    
    // 시간 파싱 (HH:MM:SS 형식에서 HH:MM만 추출)
    final startTimeParts = upcomingWork!.startTime.split(':');
    final startHour = int.parse(startTimeParts[0]);
    final startMinute = int.parse(startTimeParts[1]);
    
    final workDateTime = DateTime(
      upcomingWork!.date.year,
      upcomingWork!.date.month,
      upcomingWork!.date.day,
      startHour,
      startMinute,
    );

    // 디버깅 로그 추가
    print('=== 시간 계산 디버깅 ===');
    print('현재 시간: $now (${now.timeZoneName})');
    print('근무 시작 시간: $workDateTime');
    print('근무 날짜: ${upcomingWork!.date}');
    print('근무 시작 시간 문자열: ${upcomingWork!.startTime}');
    print('파싱된 시간: ${startHour}시 ${startMinute}분');
    
    final difference = workDateTime.difference(now);
    print('시간 차이: $difference');
    print('일: ${difference.inDays}, 시간: ${difference.inHours.remainder(24)}, 분: ${difference.inMinutes.remainder(60)}');
    print('총 분: ${difference.inMinutes}');
    print('총 시간: ${difference.inHours}');
    
    return difference;
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}일 ${duration.inHours.remainder(24)}시간';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}시간 ${duration.inMinutes.remainder(60)}분';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분';
    } else {
      return '곧';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return '오늘';
    } else if (difference == 1) {
      return '내일';
    } else if (difference == 2) {
      return '모레';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  String _calculateWorkHours() {
    if (upcomingWork == null) return '';

    final startTime = upcomingWork!.startTime.split(':');
    final endTime = upcomingWork!.endTime.split(':');

    final start = Duration(
      hours: int.parse(startTime[0]),
      minutes: int.parse(startTime[1]),
    );

    final end = Duration(
      hours: int.parse(endTime[0]),
      minutes: int.parse(endTime[1]),
    );

    Duration workDuration;
    if (end > start) {
      workDuration = end - start;
    } else {
      // 야간 근무 (다음날까지)
      workDuration = const Duration(hours: 24) - start + end;
    }

    return '${workDuration.inHours}시간 근무';
  }
}