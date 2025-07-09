// lib/models/job_posting_model.dart

class JobPosting {
  final String id;
  final String title;
  final String companyName;
  final int salary;
  final String workLocation;
  final WorkSchedule workSchedule;
  final String status;
  final int applicationCount;
  final DateTime createdAt;
  final DateTime deadline;

  JobPosting({
    required this.id,
    required this.title,
    required this.companyName,
    required this.salary,
    required this.workLocation,
    required this.workSchedule,
    required this.status,
    required this.applicationCount,
    required this.createdAt,
    required this.deadline,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      salary: json['salary']?.toInt() ?? 0,
      workLocation: json['workLocation']?.toString() ?? '',
      workSchedule: WorkSchedule.fromJson(json['workSchedule'] ?? {}),
      status: json['status']?.toString() ?? 'ACTIVE',
      applicationCount: json['applicationCount']?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'companyName': companyName,
      'salary': salary,
      'workLocation': workLocation,
      'workSchedule': workSchedule.toJson(),
      'status': status,
      'applicationCount': applicationCount,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline.toIso8601String(),
    };
  }

  /// 급여 포맷팅
  String get formattedSalary {
    return '시급 ${salary.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}원';
  }

  /// 근무 일정 텍스트
  String get workScheduleText {
    return '${workSchedule.startTime} - ${workSchedule.endTime}';
  }

  /// 근무 요일 텍스트
  String get workDaysText {
    if (workSchedule.days.isEmpty) return '요일 미정';
    return workSchedule.days.join(', ');
  }

  /// 마감일까지 남은 일수
  int get daysUntilDeadline {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// 마감 여부
  bool get isExpired {
    return DateTime.now().isAfter(deadline);
  }

  /// 신규 공고 여부 (7일 이내)
  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    return difference <= 7;
  }

  /// 긴급 공고 여부 (마감까지 3일 이내)
  bool get isUrgent {
    return daysUntilDeadline <= 3 && !isExpired;
  }
}

class WorkSchedule {
  final List<String> days;
  final String startTime;
  final String endTime;
  final String workPeriod;

  WorkSchedule({
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.workPeriod,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      days: List<String>.from(json['days'] ?? []),
      startTime: json['startTime']?.toString() ?? '09:00',
      endTime: json['endTime']?.toString() ?? '18:00',
      workPeriod: json['workPeriod']?.toString() ?? 'ONE_TO_THREE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'startTime': startTime,
      'endTime': endTime,
      'workPeriod': workPeriod,
    };
  }

  /// 근무 기간 텍스트
  String get workPeriodText {
    switch (workPeriod) {
      case 'ONE_TO_THREE':
        return '1-3개월';
      case 'THREE_TO_SIX':
        return '3-6개월';
      case 'SIX_TO_TWELVE':
        return '6-12개월';
      case 'LONG_TERM':
        return '장기';
      default:
        return workPeriod;
    }
  }
}