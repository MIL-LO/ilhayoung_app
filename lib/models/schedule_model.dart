import 'package:flutter/material.dart';

// 월별 달력 조회용 스케줄 정보
class MonthlySchedule {
  final String id;
  final String workDate;
  final LocalTime startTime;
  final LocalTime endTime;
  final String companyName;
  final String status;

  MonthlySchedule({
    required this.id,
    required this.workDate,
    required this.startTime,
    required this.endTime,
    required this.companyName,
    required this.status,
  });

  factory MonthlySchedule.fromJson(Map<String, dynamic> json) {
    return MonthlySchedule(
      id: json['id'] ?? '',
      workDate: json['workDate'] ?? '',
      startTime: LocalTime.fromJson(json['startTime'] ?? {}),
      endTime: LocalTime.fromJson(json['endTime'] ?? {}),
      companyName: json['companyName'] ?? '',
      status: json['status'] ?? '',
    );
  }

  String get statusText {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return '예정';
      case 'PRESENT':
        return '출근';
      case 'ABSENT':
        return '결근';
      case 'LATE':
        return '지각';
      case 'COMPLETED':
        return '완료';
      default:
        return '알 수 없음';
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'PRESENT':
        return Colors.green;
      case 'ABSENT':
        return Colors.red;
      case 'LATE':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

// 스케줄 상세 정보
class ScheduleDetail {
  final String id;
  final String applicationId;
  final String recruitId;
  final String staffId;
  final String staffName;
  final String workDate;
  final LocalTime startTime;
  final LocalTime endTime;
  final String position;
  final String jobType;
  final String workLocation;
  final String companyName;
  final int hourlyWage;
  final String status;

  ScheduleDetail({
    required this.id,
    required this.applicationId,
    required this.recruitId,
    required this.staffId,
    required this.staffName,
    required this.workDate,
    required this.startTime,
    required this.endTime,
    required this.position,
    required this.jobType,
    required this.workLocation,
    required this.companyName,
    required this.hourlyWage,
    required this.status,
  });

  factory ScheduleDetail.fromJson(Map<String, dynamic> json) {
    return ScheduleDetail(
      id: json['id'] ?? '',
      applicationId: json['applicationId'] ?? '',
      recruitId: json['recruitId'] ?? '',
      staffId: json['staffId'] ?? '',
      staffName: json['staffName'] ?? '',
      workDate: json['workDate'] ?? '',
      startTime: LocalTime.fromJson(json['startTime'] ?? {}),
      endTime: LocalTime.fromJson(json['endTime'] ?? {}),
      position: json['position'] ?? '',
      jobType: json['jobType'] ?? '',
      workLocation: json['workLocation'] ?? '',
      companyName: json['companyName'] ?? '',
      hourlyWage: json['hourlyWage'] ?? 0,
      status: json['status'] ?? '',
    );
  }

  String get statusText {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return '예정';
      case 'PRESENT':
        return '출근';
      case 'ABSENT':
        return '결근';
      case 'LATE':
        return '지각';
      case 'COMPLETED':
        return '완료';
      default:
        return '알 수 없음';
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'PRESENT':
        return Colors.green;
      case 'ABSENT':
        return Colors.red;
      case 'LATE':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

// 오늘의 근무 스케줄
class TodaySchedule {
  final String id;
  final String workDate;
  final LocalTime startTime;
  final LocalTime endTime;
  final String companyName;
  final String position;
  final String jobType;
  final String workLocation;
  final String status;
  final bool canCheckIn;
  final bool canCheckOut;
  final String statusMessage;

  TodaySchedule({
    required this.id,
    required this.workDate,
    required this.startTime,
    required this.endTime,
    required this.companyName,
    required this.position,
    required this.jobType,
    required this.workLocation,
    required this.status,
    required this.canCheckIn,
    required this.canCheckOut,
    required this.statusMessage,
  });

  factory TodaySchedule.fromJson(Map<String, dynamic> json) {
    return TodaySchedule(
      id: json['id'] ?? '',
      workDate: json['workDate'] ?? '',
      startTime: LocalTime.fromJson(json['startTime'] ?? {}),
      endTime: LocalTime.fromJson(json['endTime'] ?? {}),
      companyName: json['companyName'] ?? '',
      position: json['position'] ?? '',
      jobType: json['jobType'] ?? '',
      workLocation: json['workLocation'] ?? '',
      status: json['status'] ?? '',
      canCheckIn: json['canCheckIn'] ?? false,
      canCheckOut: json['canCheckOut'] ?? false,
      statusMessage: json['statusMessage'] ?? '',
    );
  }

  String get statusText {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return '예정';
      case 'PRESENT':
        return '출근';
      case 'ABSENT':
        return '결근';
      case 'LATE':
        return '지각';
      case 'COMPLETED':
        return '완료';
      default:
        return '알 수 없음';
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return Colors.blue;
      case 'PRESENT':
        return Colors.green;
      case 'ABSENT':
        return Colors.red;
      case 'LATE':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

// 대체 근무자 정보
class ReplacementInfo {
  final String recruitId;
  final String title;
  final String workLocation;
  final String workDate;
  final LocalTime startTime;
  final LocalTime endTime;
  final String position;
  final String jobType;
  final int hourlyWage;
  final String absentStaffName;

  ReplacementInfo({
    required this.recruitId,
    required this.title,
    required this.workLocation,
    required this.workDate,
    required this.startTime,
    required this.endTime,
    required this.position,
    required this.jobType,
    required this.hourlyWage,
    required this.absentStaffName,
  });

  factory ReplacementInfo.fromJson(Map<String, dynamic> json) {
    return ReplacementInfo(
      recruitId: json['recruitId'] ?? '',
      title: json['title'] ?? '',
      workLocation: json['workLocation'] ?? '',
      workDate: json['workDate'] ?? '',
      startTime: LocalTime.fromJson(json['startTime'] ?? {}),
      endTime: LocalTime.fromJson(json['endTime'] ?? {}),
      position: json['position'] ?? '',
      jobType: json['jobType'] ?? '',
      hourlyWage: json['hourlyWage'] ?? 0,
      absentStaffName: json['absentStaffName'] ?? '',
    );
  }
}

// 시간 정보
class LocalTime {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  LocalTime({
    required this.hour,
    required this.minute,
    this.second = 0,
    this.nano = 0,
  });

  factory LocalTime.fromJson(dynamic json) {
    // JSON이 문자열인 경우 (백엔드에서 LocalTime이 문자열로 직렬화된 경우)
    if (json is String) {
      return _parseTimeString(json);
    }
    
    // JSON이 Map인 경우 (기존 방식)
    if (json is Map<String, dynamic>) {
      return LocalTime(
        hour: json['hour'] ?? 0,
        minute: json['minute'] ?? 0,
        second: json['second'] ?? 0,
        nano: json['nano'] ?? 0,
      );
    }
    
    // 기본값 반환
    return LocalTime(hour: 0, minute: 0);
  }

  // 시간 문자열 파싱 헬퍼 메서드
  static LocalTime _parseTimeString(String timeString) {
    try {
      // "HH:mm:ss" 또는 "HH:mm" 형식 파싱
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final second = parts.length > 2 ? int.parse(parts[2]) : 0;
        return LocalTime(hour: hour, minute: minute, second: second);
      }
    } catch (e) {
      print('❌ 시간 문자열 파싱 오류: $timeString - $e');
    }
    
    // 파싱 실패 시 기본값 반환
    return LocalTime(hour: 0, minute: 0);
  }

  String get formattedTime {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return formattedTime;
  }
} 