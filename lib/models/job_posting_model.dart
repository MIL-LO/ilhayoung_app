// lib/models/job_posting_model.dart

class JobPosting {
  final String id;
  final String title;
  final String companyName;
  final String position; // 직책 추가
  final int salary;
  final String workLocation;
  final WorkSchedule workSchedule;
  final String status;
  final int applicationCount;
  final int viewCount; // 조회수 추가
  final DateTime createdAt;
  final DateTime deadline;
  final DateTime? workStartDate; // 근무 시작일
  final DateTime? workEndDate; // 근무 종료일
  final int? workDurationMonths; // 근무 기간 (개월수)
  final int? recruitmentCount; // 모집인원 추가
  final String? representativeName; // 대표자명 추가
  final String? companyContact; // 업체 연락처 추가
  final String? description; // 상세 설명 추가
  final String? jobType; // 직무분야 추가
  final String? gender; // 성별 추가
  final String? paymentDate; // 급여 지급일 추가

  JobPosting({
    required this.id,
    required this.title,
    required this.companyName,
    required this.position, // 직책 추가
    required this.salary,
    required this.workLocation,
    required this.workSchedule,
    required this.status,
    required this.applicationCount,
    required this.viewCount, // 조회수 추가
    required this.createdAt,
    required this.deadline,
    this.workStartDate,
    this.workEndDate,
    this.workDurationMonths,
    this.recruitmentCount,
    this.representativeName,
    this.companyContact,
    this.description,
    this.jobType,
    this.gender,
    this.paymentDate,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    print('=== JobPosting.fromJson 디버깅 ===');
    print('받은 JSON 데이터: $json');
    print('position: ${json['position']}');
    print('description: ${json['description']}');
    print('companyContact: ${json['companyContact']}');
    print('representativeName: ${json['representativeName']}');
    print('paymentDate: ${json['paymentDate']}');
    print('jobType: ${json['jobType']}');
    print('gender: ${json['gender']}');
    print('================================');
    
    return JobPosting(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      position: json['position']?.toString() ?? '', // 직책 추가
      salary: json['salary']?.toInt() ?? 0,
      workLocation: json['workLocation']?.toString() ?? '',
      workSchedule: WorkSchedule.fromJson(json['workSchedule'] ?? {}),
      status: json['status']?.toString() ?? 'ACTIVE',
      applicationCount: json['applicationCount']?.toInt() ?? 0,
      viewCount: json['viewCount']?.toInt() ?? 0, // 조회수 추가
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      deadline: DateTime.tryParse(json['deadline']?.toString() ?? '') ?? DateTime.now(),
      workStartDate: json['workStartDate'] != null ? DateTime.tryParse(json['workStartDate']) : null,
      workEndDate: json['workEndDate'] != null ? DateTime.tryParse(json['workEndDate']) : null,
      workDurationMonths: json['workDurationMonths']?.toInt(),
      recruitmentCount: json['recruitmentCount']?.toInt(),
      representativeName: json['representativeName']?.toString(),
      companyContact: json['companyContact']?.toString(),
      description: json['description']?.toString(),
      jobType: json['jobType']?.toString(),
      gender: json['gender']?.toString(),
      paymentDate: json['paymentDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'companyName': companyName,
      'position': position, // 직책 추가
      'salary': salary,
      'workLocation': workLocation,
      'workSchedule': workSchedule.toJson(),
      'status': status,
      'applicationCount': applicationCount,
      'viewCount': viewCount, // 조회수 추가
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'workStartDate': workStartDate?.toIso8601String(),
      'workEndDate': workEndDate?.toIso8601String(),
      'workDurationMonths': workDurationMonths,
      'recruitmentCount': recruitmentCount,
      'representativeName': representativeName,
      'companyContact': companyContact,
      'description': description,
      'jobType': jobType,
      'gender': gender,
      'paymentDate': paymentDate,
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

  /// 근무 기간 텍스트
  String get workPeriodText {
    if (workStartDate != null && workEndDate != null) {
      return '${workStartDate.toString().substring(0, 10)} - ${workEndDate.toString().substring(0, 10)}';
    }
    if (workDurationMonths != null) {
      return '${workDurationMonths}개월';
    }
    return workSchedule.workPeriodText;
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

  /// 활성 공고 여부
  bool get isActive {
    return !isExpired && status == 'ACTIVE';
  }
}

class WorkSchedule {
  final List<String> days;
  final String startTime;
  final String endTime;
  final String workPeriod;
  final DateTime? startDate; // 근무 시작일 추가
  final DateTime? endDate; // 근무 종료일 추가
  final int? recruitmentCount; // 모집인원 추가

  WorkSchedule({
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.workPeriod,
    this.startDate,
    this.endDate,
    this.recruitmentCount,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      days: List<String>.from(json['days'] ?? []),
      startTime: json['startTime']?.toString() ?? '09:00',
      endTime: json['endTime']?.toString() ?? '18:00',
      workPeriod: json['workPeriod']?.toString() ?? 'ONE_TO_THREE',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      recruitmentCount: json['recruitmentCount']?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'startTime': startTime,
      'endTime': endTime,
      'workPeriod': workPeriod,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'recruitmentCount': recruitmentCount,
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