// lib/models/work_schedule.dart - 근무 스케줄 모델

import 'package:flutter/material.dart';

enum WorkStatus {
  scheduled,   // 예정됨
  inProgress,  // 진행중
  completed,   // 완료됨
  cancelled,   // 취소됨
}

class WorkSchedule {
  final String id;
  final String company;
  final String position;
  final DateTime date;
  final String startTime;
  final String endTime;
  final WorkStatus status;
  final int hourlyWage;
  final String? location;
  final String? notes;
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
    required this.hourlyWage,
    this.location,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      id: json['id']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      date: _parseDateTime(json['date']),
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString()),
      hourlyWage: json['hourlyWage']?.toInt() ?? 0,
      location: json['location']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status.name,
      'hourlyWage': hourlyWage,
      'location': location,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static WorkStatus _parseStatus(String? statusString) {
    if (statusString == null) return WorkStatus.scheduled;

    switch (statusString.toLowerCase()) {
      case 'scheduled':
        return WorkStatus.scheduled;
      case 'in_progress':
      case 'inprogress':
        return WorkStatus.inProgress;
      case 'completed':
        return WorkStatus.completed;
      case 'cancelled':
        return WorkStatus.cancelled;
      default:
        return WorkStatus.scheduled;
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

  // UI 관련 getter들
  String get statusText {
    switch (status) {
      case WorkStatus.scheduled:
        return '예정됨';
      case WorkStatus.inProgress:
        return '진행중';
      case WorkStatus.completed:
        return '완료됨';
      case WorkStatus.cancelled:
        return '취소됨';
    }
  }

  Color get statusColor {
    switch (status) {
      case WorkStatus.scheduled:
        return Colors.blue[600]!;
      case WorkStatus.inProgress:
        return const Color(0xFF00A3A3);
      case WorkStatus.completed:
        return Colors.green[600]!;
      case WorkStatus.cancelled:
        return Colors.red[600]!;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case WorkStatus.scheduled:
        return Icons.schedule;
      case WorkStatus.inProgress:
        return Icons.work;
      case WorkStatus.completed:
        return Icons.check_circle;
      case WorkStatus.cancelled:
        return Icons.cancel;
    }
  }

  String get formattedDate {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String get formattedTime {
    return '$startTime - $endTime';
  }

  String get formattedWage {
    return '시급 ${hourlyWage.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}원';
  }

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

  int get expectedPay {
    return workHours * hourlyWage;
  }

  String get formattedExpectedPay {
    return '${expectedPay.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}원';
  }

  bool get canCancel {
    return status == WorkStatus.scheduled &&
        date.isAfter(DateTime.now());
  }

  bool get canComplete {
    return status == WorkStatus.inProgress;
  }

  bool get canEvaluate {
    return status == WorkStatus.completed;
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get isPast {
    return date.isBefore(DateTime.now()) && !isToday;
  }

  bool get isFuture {
    return date.isAfter(DateTime.now()) && !isToday;
  }

  String get timeUntilWork {
    if (isToday) return '오늘';
    if (isPast) return '지난 근무';

    final difference = date.difference(DateTime.now()).inDays;
    if (difference == 1) return '내일';
    return 'D-$difference';
  }

  // 편의를 위한 getter들 (기존 코드 호환성)
  bool get isMyWork => true; // API에서 내 근무만 조회하므로 항상 true
}

// WorkStatus 확장
extension WorkStatusExtension on WorkStatus {
  String get displayName {
    switch (this) {
      case WorkStatus.scheduled:
        return '예정됨';
      case WorkStatus.inProgress:
        return '진행중';
      case WorkStatus.completed:
        return '완료됨';
      case WorkStatus.cancelled:
        return '취소됨';
    }
  }

  String get apiValue {
    switch (this) {
      case WorkStatus.scheduled:
        return 'SCHEDULED';
      case WorkStatus.inProgress:
        return 'IN_PROGRESS';
      case WorkStatus.completed:
        return 'COMPLETED';
      case WorkStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color get color {
    switch (this) {
      case WorkStatus.scheduled:
        return Colors.blue[600]!;
      case WorkStatus.inProgress:
        return const Color(0xFF00A3A3);
      case WorkStatus.completed:
        return Colors.green[600]!;
      case WorkStatus.cancelled:
        return Colors.red[600]!;
    }
  }
}