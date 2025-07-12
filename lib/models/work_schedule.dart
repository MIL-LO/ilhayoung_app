import 'package:flutter/material.dart';

enum WorkStatus {
  scheduled,   // 예정 (SCHEDULED)
  present,     // 출근 (PRESENT)
  absent,      // 결근 (ABSENT)
  late,        // 지각 (LATE)
  completed,   // 완료 (COMPLETED)
}

class WorkSchedule {
  final String id;
  final String company;
  final String position;
  final DateTime date;
  final String startTime;
  final String endTime;
  final WorkStatus status;
  final String? actualStartTime;
  final String? actualEndTime;
  final bool canEvaluate;
  final String location;
  final String description;
  final double hourlyWage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WorkSchedule({
    required this.id,
    required this.company,
    required this.position,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.actualStartTime,
    this.actualEndTime,
    this.canEvaluate = false,
    this.location = '',
    this.description = '',
    this.hourlyWage = 0.0,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// API 응답에서 WorkSchedule 객체 생성
  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      id: json['id']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      date: _parseDateTime(json['date']),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      status: _mapStringToWorkStatus(json['status']?.toString()),
      actualStartTime: json['actualStartTime']?.toString(),
      actualEndTime: json['actualEndTime']?.toString(),
      canEvaluate: json['canEvaluate'] ?? false,
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      hourlyWage: (json['hourlyWage'] ?? 0).toDouble(),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': _mapWorkStatusToString(status),
      'actualStartTime': actualStartTime,
      'actualEndTime': actualEndTime,
      'canEvaluate': canEvaluate,
      'location': location,
      'description': description,
      'hourlyWage': hourlyWage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 상태별 색상
  Color get statusColor {
    switch (status) {
      case WorkStatus.scheduled:
        return const Color(0xFF00A3A3); // 예정 - 청록색
      case WorkStatus.present:
        return const Color(0xFF4CAF50); // 출근 - 초록색
      case WorkStatus.absent:
        return const Color(0xFFF44336); // 결근 - 빨간색
      case WorkStatus.late:
        return const Color(0xFFFF9800); // 지각 - 주황색
      case WorkStatus.completed:
        return const Color(0xFF9C27B0); // 완료 - 보라색
    }
  }

  /// 상태별 아이콘
  IconData get statusIcon {
    switch (status) {
      case WorkStatus.scheduled:
        return Icons.schedule;
      case WorkStatus.present:
        return Icons.check_circle;
      case WorkStatus.absent:
        return Icons.cancel;
      case WorkStatus.late:
        return Icons.access_time;
      case WorkStatus.completed:
        return Icons.task_alt;
    }
  }

  /// 상태별 텍스트
  String get statusText {
    switch (status) {
      case WorkStatus.scheduled:
        return '예정';
      case WorkStatus.present:
        return '출근';
      case WorkStatus.absent:
        return '결근';
      case WorkStatus.late:
        return '지각';
      case WorkStatus.completed:
        return '완료';
    }
  }

  /// 근무 시간 텍스트
  String get workTimeText {
    return '$startTime - $endTime';
  }

  /// 근무 시간 텍스트 (호환성을 위한 별칭)
  String get workScheduleText {
    return workTimeText;
  }

  /// 근무 요일 텍스트 (간단하게)
  String get workDaysText {
    return _getWeekday(date);
  }

  /// 실제 근무 시간 텍스트 (있는 경우)
  String? get actualWorkTimeText {
    if (actualStartTime != null && actualEndTime != null) {
      return '$actualStartTime - $actualEndTime';
    } else if (actualStartTime != null) {
      return '$actualStartTime - 진행중';
    }
    return null;
  }

  /// 급여 포맷
  String get formattedSalary {
    return '시급 ${hourlyWage.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}원';
  }

  /// 날짜 포맷
  String get formattedPostedDate {
    return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
  }

  /// 근무지 (location과 workLocation 호환)
  String get workLocation {
    return location;
  }

  /// 마감일까지 남은 일수 (현재는 근무 날짜로 계산)
  int get daysUntilDeadline {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// 만료 여부
  bool get isExpired {
    return date.isBefore(DateTime.now());
  }

  /// 새 공고 여부 (3일 이내 생성된 것)
  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    return difference <= 3;
  }

  /// 급구 여부 (마감까지 3일 이하)
  bool get isUrgent {
    return daysUntilDeadline <= 3 && daysUntilDeadline > 0;
  }

  /// 지원자 수 (API에서 제공되지 않으므로 기본값)
  int get applicationCount {
    return 0; // API 스펙에 없음
  }

  /// 회사명 (company와 companyName 호환)
  String get companyName {
    return company;
  }

  /// 마감일 (근무 날짜로 대체)
  DateTime get deadline {
    return date;
  }

  /// 근무 스케줄 객체 (호환성용)
  WorkScheduleInfo get workSchedule {
    return WorkScheduleInfo(
      workPeriodText: '단기',
    );
  }

  /// 급여 계산 (시간당)
  double get estimatedWage {
    // 간단한 시간 계산 (실제로는 더 정교한 계산 필요)
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    if (start != null && end != null) {
      final duration = end.difference(start);
      final hours = duration.inMinutes / 60.0;
      return hours * hourlyWage;
    }
    return 0.0;
  }

  /// 근무 시간 계산
  int get workHours {
    try {
      final start = TimeOfDay(
        hour: int.parse(startTime.split(':')[0]),
        minute: int.parse(startTime.split(':')[1]),
      );
      final end = TimeOfDay(
        hour: int.parse(endTime.split(':')[0]),
        minute: int.parse(endTime.split(':')[1]),
      );

      int startMinutes = start.hour * 60 + start.minute;
      int endMinutes = end.hour * 60 + end.minute;

      if (endMinutes < startMinutes) {
        // 다음날로 넘어가는 경우
        endMinutes += 24 * 60;
      }

      return ((endMinutes - startMinutes) / 60).round();
    } catch (e) {
      return 8; // 기본값
    }
  }

  /// 예상 급여
  int get expectedPay {
    return (workHours * hourlyWage).round();
  }

  /// 포맷된 예상 급여
  String get formattedExpectedPay {
    return '${expectedPay.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}원';
  }

  /// 취소 가능 여부
  bool get canCancel {
    return status == WorkStatus.scheduled && date.isAfter(DateTime.now());
  }

  /// 완료 처리 가능 여부
  bool get canComplete {
    return status == WorkStatus.present;
  }

  /// 오늘 근무인지
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 과거 근무인지
  bool get isPast {
    return date.isBefore(DateTime.now()) && !isToday;
  }

  /// 미래 근무인지
  bool get isFuture {
    return date.isAfter(DateTime.now()) && !isToday;
  }

  /// 근무까지 남은 시간 텍스트
  String get timeUntilWork {
    if (isToday) return '오늘';
    if (isPast) return '지난 근무';

    final difference = date.difference(DateTime.now()).inDays;
    if (difference == 1) return '내일';
    return 'D-$difference';
  }

  /// 복사본 생성
  WorkSchedule copyWith({
    String? id,
    String? company,
    String? position,
    DateTime? date,
    String? startTime,
    String? endTime,
    WorkStatus? status,
    String? actualStartTime,
    String? actualEndTime,
    bool? canEvaluate,
    String? location,
    String? description,
    double? hourlyWage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkSchedule(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      canEvaluate: canEvaluate ?? this.canEvaluate,
      location: location ?? this.location,
      description: description ?? this.description,
      hourlyWage: hourlyWage ?? this.hourlyWage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'WorkSchedule(id: $id, company: $company, position: $position, date: $date, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Private 메서드들
  DateTime? _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(date.year, date.month, date.day, hour, minute);
      }
    } catch (e) {
      print('시간 파싱 오류: $timeString');
    }
    return null;
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return '${weekdays[date.weekday % 7]}요일';
  }

  static WorkStatus _mapStringToWorkStatus(String? statusString) {
    if (statusString == null) return WorkStatus.scheduled;

    switch (statusString.toUpperCase()) {
      case 'SCHEDULED':
        return WorkStatus.scheduled;
      case 'PRESENT':
        return WorkStatus.present;
      case 'ABSENT':
        return WorkStatus.absent;
      case 'LATE':
        return WorkStatus.late;
      case 'COMPLETED':
        return WorkStatus.completed;
      default:
        return WorkStatus.scheduled;
    }
  }

  static String _mapWorkStatusToString(WorkStatus status) {
    switch (status) {
      case WorkStatus.scheduled:
        return 'SCHEDULED';
      case WorkStatus.present:
        return 'PRESENT';
      case WorkStatus.absent:
        return 'ABSENT';
      case WorkStatus.late:
        return 'LATE';
      case WorkStatus.completed:
        return 'COMPLETED';
    }
  }

  static DateTime _parseDateTime(dynamic dateString) {
    if (dateString == null) return DateTime.now();

    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return DateTime.now();
    }
  }
}

/// 근무 스케줄 정보 클래스 (호환성용)
class WorkScheduleInfo {
  final String workPeriodText;

  WorkScheduleInfo({
    required this.workPeriodText,
  });
}

/// WorkStatus 확장
extension WorkStatusExtension on WorkStatus {
  String get displayName {
    switch (this) {
      case WorkStatus.scheduled:
        return '예정';
      case WorkStatus.present:
        return '출근';
      case WorkStatus.absent:
        return '결근';
      case WorkStatus.late:
        return '지각';
      case WorkStatus.completed:
        return '완료';
    }
  }

  String get apiValue {
    switch (this) {
      case WorkStatus.scheduled:
        return 'SCHEDULED';
      case WorkStatus.present:
        return 'PRESENT';
      case WorkStatus.absent:
        return 'ABSENT';
      case WorkStatus.late:
        return 'LATE';
      case WorkStatus.completed:
        return 'COMPLETED';
    }
  }

  Color get color {
    switch (this) {
      case WorkStatus.scheduled:
        return const Color(0xFF00A3A3);
      case WorkStatus.present:
        return const Color(0xFF4CAF50);
      case WorkStatus.absent:
        return const Color(0xFFF44336);
      case WorkStatus.late:
        return const Color(0xFFFF9800);
      case WorkStatus.completed:
        return const Color(0xFF9C27B0);
    }
  }
}