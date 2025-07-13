// lib/models/worker_attendance_model.dart

import 'package:flutter/material.dart';

/// 근무자 출석 정보 모델
class WorkerAttendance {
  final String staffId;
  final String staffName;
  final String status; // PRESENT, ABSENT, LATE, EARLY_LEAVE, SCHEDULED 등
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String workLocation;
  final double? totalWorkHours;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkerAttendance({
    required this.staffId,
    required this.staffName,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    required this.workLocation,
    this.totalWorkHours,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkerAttendance.fromJson(Map<String, dynamic> json) {
    return WorkerAttendance(
      staffId: json['staffId']?.toString() ?? '',
      staffName: json['staffName']?.toString() ?? json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      checkInTime: json['checkInTime'] != null
          ? DateTime.tryParse(json['checkInTime'].toString())
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.tryParse(json['checkOutTime'].toString())
          : null,
      workLocation: json['workLocation']?.toString() ?? json['location']?.toString() ?? '',
      totalWorkHours: json['totalWorkHours']?.toDouble() ?? json['workHours']?.toDouble(),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'status': status,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'workLocation': workLocation,
      'totalWorkHours': totalWorkHours,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 상태 텍스트 반환
  String get statusText {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return '출근';
      case 'ABSENT':
        return '결근';
      case 'LATE':
        return '지각';
      case 'EARLY_LEAVE':
        return '조퇴';
      case 'SCHEDULED':
        return '근무 예정';
      case 'COMPLETED':
        return '근무 완료';
      case 'ON_BREAK':
        return '휴식 중';
      default:
        return '알 수 없음';
    }
  }

  /// 상태별 색상 반환
  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return const Color(0xFF4CAF50); // 초록색
      case 'ABSENT':
        return const Color(0xFFF44336); // 빨간색
      case 'LATE':
        return const Color(0xFFFF9800); // 주황색
      case 'EARLY_LEAVE':
        return const Color(0xFF9C27B0); // 보라색
      case 'SCHEDULED':
        return const Color(0xFF2196F3); // 파란색
      case 'COMPLETED':
        return const Color(0xFF757575); // 회색
      case 'ON_BREAK':
        return const Color(0xFFFFEB3B); // 노란색
      default:
        return const Color(0xFF9E9E9E); // 기본 회색
    }
  }

  /// 출근 시간 텍스트 반환
  String get checkInTimeText {
    if (checkInTime == null) return '미출근';
    return '${checkInTime!.hour.toString().padLeft(2, '0')}:${checkInTime!.minute.toString().padLeft(2, '0')}';
  }

  /// 퇴근 시간 텍스트 반환
  String get checkOutTimeText {
    if (checkOutTime == null) return '미퇴근';
    return '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}';
  }

  /// 근무 시간 텍스트 반환
  String get workHoursText {
    if (totalWorkHours == null) return '0시간';
    if (totalWorkHours! < 1) {
      final minutes = (totalWorkHours! * 60).round();
      return '${minutes}분';
    }
    return '${totalWorkHours!.toStringAsFixed(1)}시간';
  }

  /// 근무 시간 계산 (출근/퇴근 시간 기준)
  double get calculatedWorkHours {
    if (checkInTime == null || checkOutTime == null) return 0.0;
    final duration = checkOutTime!.difference(checkInTime!);
    return duration.inMinutes / 60.0;
  }

  /// 출근 상태 여부
  bool get isPresent => status.toUpperCase() == 'PRESENT';

  /// 결근 상태 여부
  bool get isAbsent => status.toUpperCase() == 'ABSENT';

  /// 지각 상태 여부
  bool get isLate => status.toUpperCase() == 'LATE';

  /// 근무 완료 상태 여부
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  /// 복사본 생성 (상태 변경 등을 위해)
  WorkerAttendance copyWith({
    String? staffId,
    String? staffName,
    String? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? workLocation,
    double? totalWorkHours,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkerAttendance(
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      workLocation: workLocation ?? this.workLocation,
      totalWorkHours: totalWorkHours ?? this.totalWorkHours,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 근무 스케줄 정보 모델
class WorkSchedule {
  final String scheduleId;
  final String staffId;
  final String staffName;
  final DateTime startTime;
  final DateTime endTime;
  final String workLocation;
  final double hourlyRate;
  final String status; // SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED
  final String? notes;
  final String? jobId;
  final String? jobTitle;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkSchedule({
    required this.scheduleId,
    required this.staffId,
    required this.staffName,
    required this.startTime,
    required this.endTime,
    required this.workLocation,
    required this.hourlyRate,
    required this.status,
    this.notes,
    this.jobId,
    this.jobTitle,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      scheduleId: json['scheduleId']?.toString() ?? json['id']?.toString() ?? '',
      staffId: json['staffId']?.toString() ?? '',
      staffName: json['staffName']?.toString() ?? json['name']?.toString() ?? '',
      startTime: DateTime.parse(json['startTime']?.toString() ?? json['startDate']?.toString() ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime']?.toString() ?? json['endDate']?.toString() ?? DateTime.now().add(const Duration(hours: 8)).toIso8601String()),
      workLocation: json['workLocation']?.toString() ?? json['location']?.toString() ?? '',
      hourlyRate: json['hourlyRate']?.toDouble() ?? json['wage']?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'SCHEDULED',
      notes: json['notes']?.toString(),
      jobId: json['jobId']?.toString(),
      jobTitle: json['jobTitle']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'staffId': staffId,
      'staffName': staffName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'workLocation': workLocation,
      'hourlyRate': hourlyRate,
      'status': status,
      'notes': notes,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 상태 텍스트 반환
  String get statusText {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return '예정';
      case 'IN_PROGRESS':
        return '진행 중';
      case 'COMPLETED':
        return '완료';
      case 'CANCELLED':
        return '취소';
      case 'PAUSED':
        return '일시정지';
      default:
        return '알 수 없음';
    }
  }

  /// 상태별 색상 반환
  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return const Color(0xFF2196F3); // 파란색
      case 'IN_PROGRESS':
        return const Color(0xFF4CAF50); // 초록색
      case 'COMPLETED':
        return const Color(0xFF757575); // 회색
      case 'CANCELLED':
        return const Color(0xFFF44336); // 빨간색
      case 'PAUSED':
        return const Color(0xFFFF9800); // 주황색
      default:
        return const Color(0xFF9E9E9E); // 기본 회색
    }
  }

  /// 시간 범위 텍스트 반환 (HH:MM - HH:MM)
  String get timeRangeText {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  /// 근무 시간 계산
  Duration get duration {
    return endTime.difference(startTime);
  }

  /// 근무 시간 텍스트 반환
  String get durationText {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours == 0) {
      return '${minutes}분';
    } else if (minutes == 0) {
      return '${hours}시간';
    } else {
      return '${hours}시간 ${minutes}분';
    }
  }

  /// 예상 급여 계산
  double get estimatedPay {
    final hours = duration.inMinutes / 60.0;
    return hours * hourlyRate;
  }

  /// 예상 급여 텍스트 반환
  String get estimatedPayText {
    return '₩${estimatedPay.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// 시급 텍스트 반환
  String get hourlyRateText {
    return '₩${hourlyRate.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// 날짜 텍스트 반환 (YYYY-MM-DD)
  String get dateText {
    return '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}';
  }

  /// 예정된 스케줄 여부
  bool get isScheduled => status.toUpperCase() == 'SCHEDULED';

  /// 진행 중인 스케줄 여부
  bool get isInProgress => status.toUpperCase() == 'IN_PROGRESS';

  /// 완료된 스케줄 여부
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  /// 취소된 스케줄 여부
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';

  /// 오늘 스케줄 여부
  bool get isToday {
    final today = DateTime.now();
    return startTime.year == today.year &&
        startTime.month == today.month &&
        startTime.day == today.day;
  }

  /// 과거 스케줄 여부
  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  /// 미래 스케줄 여부
  bool get isFuture {
    return startTime.isAfter(DateTime.now());
  }

  /// 복사본 생성 (상태 변경 등을 위해)
  WorkSchedule copyWith({
    String? scheduleId,
    String? staffId,
    String? staffName,
    DateTime? startTime,
    DateTime? endTime,
    String? workLocation,
    double? hourlyRate,
    String? status,
    String? notes,
    String? jobId,
    String? jobTitle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkSchedule(
      scheduleId: scheduleId ?? this.scheduleId,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      workLocation: workLocation ?? this.workLocation,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 출석 통계 모델
class AttendanceStatistics {
  final int totalWorkers;
  final int presentWorkers;
  final int absentWorkers;
  final int lateWorkers;
  final int earlyLeaveWorkers;
  final double attendanceRate;
  final double averageWorkHours;
  final String period; // 통계 기간
  final DateTime generatedAt;

  AttendanceStatistics({
    required this.totalWorkers,
    required this.presentWorkers,
    required this.absentWorkers,
    required this.lateWorkers,
    required this.earlyLeaveWorkers,
    required this.attendanceRate,
    required this.averageWorkHours,
    required this.period,
    required this.generatedAt,
  });

  factory AttendanceStatistics.fromJson(Map<String, dynamic> json) {
    return AttendanceStatistics(
      totalWorkers: json['totalWorkers']?.toInt() ?? 0,
      presentWorkers: json['presentWorkers']?.toInt() ?? 0,
      absentWorkers: json['absentWorkers']?.toInt() ?? 0,
      lateWorkers: json['lateWorkers']?.toInt() ?? 0,
      earlyLeaveWorkers: json['earlyLeaveWorkers']?.toInt() ?? 0,
      attendanceRate: json['attendanceRate']?.toDouble() ?? 0.0,
      averageWorkHours: json['averageWorkHours']?.toDouble() ?? 0.0,
      period: json['period']?.toString() ?? '',
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWorkers': totalWorkers,
      'presentWorkers': presentWorkers,
      'absentWorkers': absentWorkers,
      'lateWorkers': lateWorkers,
      'earlyLeaveWorkers': earlyLeaveWorkers,
      'attendanceRate': attendanceRate,
      'averageWorkHours': averageWorkHours,
      'period': period,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  /// 출석률 텍스트 반환
  String get attendanceRateText {
    return '${(attendanceRate * 100).toStringAsFixed(1)}%';
  }

  /// 평균 근무시간 텍스트 반환
  String get averageWorkHoursText {
    return '${averageWorkHours.toStringAsFixed(1)}시간';
  }
}

/// 스케줄 통계 모델
class ScheduleStatistics {
  final int totalSchedules;
  final int scheduledCount;
  final int inProgressCount;
  final int completedCount;
  final int cancelledCount;
  final double completionRate;
  final double totalEstimatedPay;
  final double totalActualPay;
  final String period;
  final DateTime generatedAt;

  ScheduleStatistics({
    required this.totalSchedules,
    required this.scheduledCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.completionRate,
    required this.totalEstimatedPay,
    required this.totalActualPay,
    required this.period,
    required this.generatedAt,
  });

  factory ScheduleStatistics.fromJson(Map<String, dynamic> json) {
    return ScheduleStatistics(
      totalSchedules: json['totalSchedules']?.toInt() ?? 0,
      scheduledCount: json['scheduledCount']?.toInt() ?? 0,
      inProgressCount: json['inProgressCount']?.toInt() ?? 0,
      completedCount: json['completedCount']?.toInt() ?? 0,
      cancelledCount: json['cancelledCount']?.toInt() ?? 0,
      completionRate: json['completionRate']?.toDouble() ?? 0.0,
      totalEstimatedPay: json['totalEstimatedPay']?.toDouble() ?? 0.0,
      totalActualPay: json['totalActualPay']?.toDouble() ?? 0.0,
      period: json['period']?.toString() ?? '',
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSchedules': totalSchedules,
      'scheduledCount': scheduledCount,
      'inProgressCount': inProgressCount,
      'completedCount': completedCount,
      'cancelledCount': cancelledCount,
      'completionRate': completionRate,
      'totalEstimatedPay': totalEstimatedPay,
      'totalActualPay': totalActualPay,
      'period': period,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  /// 완료율 텍스트 반환
  String get completionRateText {
    return '${(completionRate * 100).toStringAsFixed(1)}%';
  }

  /// 예상 급여 텍스트 반환
  String get totalEstimatedPayText {
    return '₩${totalEstimatedPay.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// 실제 급여 텍스트 반환
  String get totalActualPayText {
    return '₩${totalActualPay.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}

/// 근무자 상세 정보 모델
class StaffDetail {
  final String staffId;
  final String name;
  final String email;
  final String phone;
  final String position;
  final String department;
  final DateTime hireDate;
  final String status;
  final double hourlyRate;
  final List<WorkerAttendance> recentAttendances;
  final List<WorkSchedule> upcomingSchedules;
  final AttendanceStatistics? attendanceStats;

  StaffDetail({
    required this.staffId,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.department,
    required this.hireDate,
    required this.status,
    required this.hourlyRate,
    required this.recentAttendances,
    required this.upcomingSchedules,
    this.attendanceStats,
  });

  factory StaffDetail.fromJson(Map<String, dynamic> json) {
    return StaffDetail(
      staffId: json['staffId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      hireDate: json['hireDate'] != null
          ? DateTime.parse(json['hireDate'].toString())
          : DateTime.now(),
      status: json['status']?.toString() ?? 'ACTIVE',
      hourlyRate: json['hourlyRate']?.toDouble() ?? 0.0,
      recentAttendances: (json['recentAttendances'] as List<dynamic>? ?? [])
          .map((item) => WorkerAttendance.fromJson(item))
          .toList(),
      upcomingSchedules: (json['upcomingSchedules'] as List<dynamic>? ?? [])
          .map((item) => WorkSchedule.fromJson(item))
          .toList(),
      attendanceStats: json['attendanceStats'] != null
          ? AttendanceStatistics.fromJson(json['attendanceStats'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'department': department,
      'hireDate': hireDate.toIso8601String(),
      'status': status,
      'hourlyRate': hourlyRate,
      'recentAttendances': recentAttendances.map((item) => item.toJson()).toList(),
      'upcomingSchedules': upcomingSchedules.map((item) => item.toJson()).toList(),
      'attendanceStats': attendanceStats?.toJson(),
    };
  }

  /// 시급 텍스트 반환
  String get hourlyRateText {
    return '₩${hourlyRate.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// 근무 기간 계산
  Duration get workPeriod {
    return DateTime.now().difference(hireDate);
  }

  /// 근무 기간 텍스트 반환
  String get workPeriodText {
    final days = workPeriod.inDays;
    if (days < 30) {
      return '${days}일';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '${months}개월';
    } else {
      final years = (days / 365).floor();
      final remainingMonths = ((days % 365) / 30).floor();
      if (remainingMonths == 0) {
        return '${years}년';
      } else {
        return '${years}년 ${remainingMonths}개월';
      }
    }
  }

  /// 활성 상태 여부
  bool get isActive => status.toUpperCase() == 'ACTIVE';

  /// 비활성 상태 여부
  bool get isInactive => status.toUpperCase() == 'INACTIVE';

  /// 휴직 상태 여부
  bool get isOnLeave => status.toUpperCase() == 'ON_LEAVE';
}

/// API 응답 래퍼 모델
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final String? errorCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.errorCode,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    return ApiResponse<T>(
      success: json['code'] == 'SUCCESS',
      message: json['message']?.toString(),
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['code'] != 'SUCCESS' ? json['message']?.toString() : null,
      errorCode: json['code']?.toString(),
    );
  }

  /// 성공 응답 생성
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  /// 실패 응답 생성
  factory ApiResponse.failure(String error, {String? errorCode}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      errorCode: errorCode,
    );
  }
}

/// 페이지네이션 모델
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic) fromJsonT,
      ) {
    final itemsList = json['items'] as List<dynamic>? ?? [];

    return PaginatedResponse<T>(
      items: itemsList.map((item) => fromJsonT(item)).toList(),
      currentPage: json['currentPage']?.toInt() ?? 1,
      totalPages: json['totalPages']?.toInt() ?? 1,
      totalItems: json['totalItems']?.toInt() ?? itemsList.length,
      itemsPerPage: json['itemsPerPage']?.toInt() ?? itemsList.length,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}