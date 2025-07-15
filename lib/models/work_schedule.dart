import 'package:flutter/material.dart';

enum WorkStatus {
  scheduled, // 예정
  present,   // 출근
  absent,    // 결근
  late,      // 지각
  completed, // 완료
}

class WorkSchedule {
  final String id;
  final String company;
  final String position;
  final String? jobType; // 직무 유형 추가
  final DateTime date;
  final String startTime;
  final String endTime;
  final WorkStatus status;
  final String? location;
  final double? hourlyRate;
  final String? notes;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool canEvaluate;
  final String? statusMessage;
  final bool canCheckIn;
  final bool canCheckOut;
  final String? paymentDate; // 지급일 (예: "10", "15", "25")

  WorkSchedule({
    required this.id,
    required this.company,
    required this.position,
    this.jobType, // 직무 유형 추가
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.location,
    this.hourlyRate,
    this.notes,
    this.checkInTime,
    this.checkOutTime,
    this.canEvaluate = false,
    this.statusMessage,
    this.canCheckIn = false,
    this.canCheckOut = false,
    this.paymentDate,
  });

  // API 응답에 맞게 수정된 fromJson
  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    try {
      print('=== WorkSchedule.fromJson 파싱 시작 ===');
      print('원본 JSON: $json');

      // 날짜 파싱 (workDate 필드 사용)
      DateTime parsedDate;
      try {
        final workDate = json['workDate'] as String? ?? json['date'] as String?;
        if (workDate != null) {
          parsedDate = DateTime.parse(workDate);
          print('✅ 날짜 파싱 성공: $workDate → $parsedDate');
        } else {
          throw Exception('날짜 필드가 없음');
        }
      } catch (e) {
        print('❌ 날짜 파싱 실패: $e');
        parsedDate = DateTime.now();
      }

      // 상태 파싱
      WorkStatus parsedStatus;
      try {
        final statusStr = (json['status'] as String? ?? 'SCHEDULED').toUpperCase();
        parsedStatus = _parseWorkStatus(statusStr);
        print('✅ 상태 파싱 성공: $statusStr → $parsedStatus');
      } catch (e) {
        print('❌ 상태 파싱 실패: $e');
        parsedStatus = WorkStatus.scheduled;
      }

      // 시간 파싱 (HH:MM:SS → HH:MM 형식으로 변환)
      String parsedStartTime = _formatTime(json['startTime'] as String? ?? '09:00:00');
      String parsedEndTime = _formatTime(json['endTime'] as String? ?? '18:00:00');

      // 회사명과 직책 처리
      String companyName = json['companyName'] as String? ??
          json['company'] as String? ??
          '회사명 정보 없음';

      String position = json['position'] as String? ??
          json['jobTitle'] as String? ??
          '직책 정보 없음';

      // 직무 유형 처리
      String? jobType = json['jobType'] as String?;

      final schedule = WorkSchedule(
        id: json['id'] as String? ?? '',
        company: companyName,
        position: position,
        jobType: jobType, // 직무 유형 추가
        date: parsedDate,
        startTime: parsedStartTime,
        endTime: parsedEndTime,
        status: parsedStatus,
        location: json['workLocation'] as String? ?? json['location'] as String?,
        hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
        checkInTime: _parseDateTime(json['checkInTime']),
        checkOutTime: _parseDateTime(json['checkOutTime']),
        canEvaluate: json['canEvaluate'] as bool? ?? false,
        statusMessage: json['statusMessage'] as String?,
        canCheckIn: json['canCheckIn'] as bool? ?? false,
        canCheckOut: json['canCheckOut'] as bool? ?? false,
        paymentDate: json['paymentDate'] as String?,
      );

      print('✅ WorkSchedule 파싱 완료: ${schedule.company} - ${schedule.date}');
      return schedule;
    } catch (e) {
      print('❌ WorkSchedule 파싱 실패: $e');
      print('문제가 된 JSON: $json');

      // 파싱 실패 시 기본값으로 객체 생성
      return WorkSchedule(
        id: json['id'] as String? ?? 'unknown',
        company: '파싱 실패',
        position: '알 수 없음',
        date: DateTime.now(),
        startTime: '09:00',
        endTime: '18:00',
        status: WorkStatus.scheduled,
        statusMessage: '파싱 실패',
        canCheckIn: true,
        canCheckOut: true,
        paymentDate: null,
      );
    }
  }

  // 상태 문자열을 WorkStatus enum으로 변환
  static WorkStatus _parseWorkStatus(String? status) {
    switch (status?.toUpperCase()) {
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
        print('⚠️ 알 수 없는 상태: $status, SCHEDULED로 설정');
        return WorkStatus.scheduled;
    }
  }

  // 시간 형식 통일 (HH:MM:SS → HH:MM)
  static String _formatTime(String time) {
    try {
      if (time.contains(':')) {
        final parts = time.split(':');
        if (parts.length >= 2) {
          return '${parts[0]}:${parts[1]}';
        }
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  // DateTime 파싱 헬퍼
  static DateTime? _parseDateTime(dynamic dateTimeValue) {
    if (dateTimeValue == null) return null;
    try {
      return DateTime.parse(dateTimeValue.toString());
    } catch (e) {
      print('DateTime 파싱 실패: $dateTimeValue');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'jobType': jobType, // 직무 유형 추가
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status.name.toUpperCase(),
      'location': location,
      'hourlyRate': hourlyRate,
      'notes': notes,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'canEvaluate': canEvaluate,
      'statusMessage': statusMessage,
      'canCheckIn': canCheckIn,
      'canCheckOut': canCheckOut,
      'paymentDate': paymentDate,
    };
  }

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

  Color get statusColor {
    switch (status) {
      case WorkStatus.scheduled:
        return const Color(0xFF2196F3);
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
        return Icons.done_all;
    }
  }

  WorkSchedule copyWith({
    String? id,
    String? company,
    String? position,
    String? jobType,
    DateTime? date,
    String? startTime,
    String? endTime,
    WorkStatus? status,
    String? location,
    double? hourlyRate,
    String? notes,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    bool? canEvaluate,
    String? statusMessage,
    bool? canCheckIn,
    bool? canCheckOut,
    String? paymentDate,
  }) {
    return WorkSchedule(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      jobType: jobType ?? this.jobType,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      location: location ?? this.location,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      notes: notes ?? this.notes,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      canEvaluate: canEvaluate ?? this.canEvaluate,
      statusMessage: statusMessage ?? this.statusMessage,
      canCheckIn: canCheckIn ?? this.canCheckIn,
      canCheckOut: canCheckOut ?? this.canCheckOut,
      paymentDate: paymentDate ?? this.paymentDate,
    );
  }

  /// 근무 시간 (시간 단위)
  double get workHours {
    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);
      
      final startTotalMinutes = startHour * 60 + startMinute;
      final endTotalMinutes = endHour * 60 + endMinute;
      
      final workMinutes = endTotalMinutes - startTotalMinutes;
      return workMinutes / 60.0;
    } catch (e) {
      return 8.0; // 기본값
    }
  }

  /// 일급 계산
  double? get dailyWage {
    if (hourlyRate != null) {
      return hourlyRate! * workHours;
    }
    return null;
  }
}