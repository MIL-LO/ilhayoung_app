// lib/models/application_model.dart - 실제 API에 맞춘 지원내역 모델

import 'package:flutter/material.dart';

enum ApplicationStatus {
  applied,    // 지원완료 (APPLIED)
  interview,  // 면접 요청 (INTERVIEW)
  hired,      // 채용 확정 (HIRED)
  rejected,   // 채용 거절 (REJECTED)
}

class JobApplication {
  final String id;
  final String recruitTitle;
  final String companyName;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime recruitDeadline;
  final bool? isRecruitDeleted; // 삭제된 공고인지 여부

  JobApplication({
    required this.id,
    required this.recruitTitle,
    required this.companyName,
    required this.status,
    required this.appliedAt,
    required this.recruitDeadline,
    this.isRecruitDeleted,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id']?.toString() ?? '',
      recruitTitle: json['recruitTitle']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString()),
      appliedAt: _parseDateTime(json['appliedAt']),
      recruitDeadline: _parseDateTime(json['recruitDeadline']),
      isRecruitDeleted: json['isRecruitDeleted'] == true ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recruitTitle': recruitTitle,
      'companyName': companyName,
      'status': status.apiValue,
      'appliedAt': appliedAt.toIso8601String(),
      'recruitDeadline': recruitDeadline.toIso8601String(),
      'isRecruitDeleted': isRecruitDeleted ?? false,
    };
  }

  // copyWith 메소드 추가
  JobApplication copyWith({
    String? id,
    String? recruitTitle,
    String? companyName,
    ApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? recruitDeadline,
    bool? isRecruitDeleted,
  }) {
    return JobApplication(
      id: id ?? this.id,
      recruitTitle: recruitTitle ?? this.recruitTitle,
      companyName: companyName ?? this.companyName,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      recruitDeadline: recruitDeadline ?? this.recruitDeadline,
      isRecruitDeleted: isRecruitDeleted ?? this.isRecruitDeleted,
    );
  }

  // 상태를 문자열로 업데이트하는 편의 메소드
  JobApplication copyWithStatusString(String statusString) {
    return copyWith(status: _parseStatus(statusString));
  }

  static ApplicationStatus _parseStatus(String? statusString) {
    if (statusString == null) return ApplicationStatus.applied;

    switch (statusString.toUpperCase()) {
      case 'APPLIED':
        return ApplicationStatus.applied;
      case 'INTERVIEW':
        return ApplicationStatus.interview;
      case 'HIRED':
        return ApplicationStatus.hired;
      case 'REJECTED':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.applied;
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
      case ApplicationStatus.applied:
        return '지원완료';
      case ApplicationStatus.interview:
        return '면접 요청';
      case ApplicationStatus.hired:
        return '채용 확정';
      case ApplicationStatus.rejected:
        return '채용 거절';
    }
  }

  Color get statusColor {
    switch (status) {
      case ApplicationStatus.applied:
        return Colors.blue[600] ?? Colors.blue;
      case ApplicationStatus.interview:
        return Colors.orange[600] ?? Colors.orange;
      case ApplicationStatus.hired:
        return const Color(0xFF00A3A3);
      case ApplicationStatus.rejected:
        return Colors.red[600] ?? Colors.red;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case ApplicationStatus.applied:
        return Icons.send;
      case ApplicationStatus.interview:
        return Icons.event;
      case ApplicationStatus.hired:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
    }
  }

  String get formattedAppliedDate {
    final now = DateTime.now();
    final diff = now.difference(appliedAt);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}분 전';
      } else {
        return '${diff.inHours}시간 전';
      }
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${appliedAt.year}.${appliedAt.month.toString().padLeft(2, '0')}.${appliedAt.day.toString().padLeft(2, '0')}';
    }
  }

  String get formattedDeadline {
    return '${recruitDeadline.year}.${recruitDeadline.month.toString().padLeft(2, '0')}.${recruitDeadline.day.toString().padLeft(2, '0')}';
  }

  int get daysUntilDeadline {
    final now = DateTime.now();
    final deadline = DateTime(recruitDeadline.year, recruitDeadline.month, recruitDeadline.day);
    final today = DateTime(now.year, now.month, now.day);
    return deadline.difference(today).inDays;
  }

  bool get isDeadlinePassed {
    return daysUntilDeadline < 0;
  }

  bool get canCancel {
    return status == ApplicationStatus.applied;
  }

  bool get hasAction {
    return status == ApplicationStatus.interview || canCancel;
  }

  String get actionText {
    switch (status) {
      case ApplicationStatus.interview:
        return '면접 일정 확인';
      case ApplicationStatus.applied:
        return '지원 취소';
      default:
        return '';
    }
  }

  // 편의를 위한 getter들
  String get jobTitle => recruitTitle;
  String get company => companyName;
  String get companyLocation => '위치 정보 없음'; // API에 없는 필드
  String get formattedSalary => '급여 정보 없음'; // API에 없는 필드
}

// ApplicationStatus 확장
extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.applied:
        return '지원완료';
      case ApplicationStatus.interview:
        return '면접 요청';
      case ApplicationStatus.hired:
        return '채용 확정';
      case ApplicationStatus.rejected:
        return '채용 거절';
    }
  }

  String get apiValue {
    switch (this) {
      case ApplicationStatus.applied:
        return 'APPLIED';
      case ApplicationStatus.interview:
        return 'INTERVIEW';
      case ApplicationStatus.hired:
        return 'HIRED';
      case ApplicationStatus.rejected:
        return 'REJECTED';
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.applied:
        return Colors.blue[600] ?? Colors.blue;
      case ApplicationStatus.interview:
        return Colors.orange[600] ?? Colors.orange;
      case ApplicationStatus.hired:
        return const Color(0xFF00A3A3);
      case ApplicationStatus.rejected:
        return Colors.red[600] ?? Colors.red;
    }
  }
}