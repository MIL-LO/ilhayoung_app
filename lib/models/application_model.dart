// lib/models/application_model.dart - 실제 API에 맞춘 지원내역 모델

import 'package:flutter/material.dart';

enum ApplicationStatus {
  pending,    // 대기중
  reviewing,  // 검토중 (REVIEWING)
  interview,  // 면접
  offer,      // 제안
  hired,      // 채용확정
  rejected,   // 거절
  cancelled,  // 취소
}

class JobApplication {
  final String id;
  final String recruitTitle;
  final String companyName;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime recruitDeadline;

  JobApplication({
    required this.id,
    required this.recruitTitle,
    required this.companyName,
    required this.status,
    required this.appliedAt,
    required this.recruitDeadline,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id']?.toString() ?? '',
      recruitTitle: json['recruitTitle']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString()),
      appliedAt: _parseDateTime(json['appliedAt']),
      recruitDeadline: _parseDateTime(json['recruitDeadline']),
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
    };
  }

  static ApplicationStatus _parseStatus(String? statusString) {
    if (statusString == null) return ApplicationStatus.pending;

    switch (statusString.toUpperCase()) {
      case 'PENDING':
        return ApplicationStatus.pending;
      case 'REVIEWING':
        return ApplicationStatus.reviewing;
      case 'INTERVIEW':
        return ApplicationStatus.interview;
      case 'OFFER':
        return ApplicationStatus.offer;
      case 'HIRED':
        return ApplicationStatus.hired;
      case 'REJECTED':
        return ApplicationStatus.rejected;
      case 'CANCELLED':
        return ApplicationStatus.cancelled;
      default:
        return ApplicationStatus.pending;
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
      case ApplicationStatus.pending:
        return '대기중';
      case ApplicationStatus.reviewing:
        return '검토중';
      case ApplicationStatus.interview:
        return '면접';
      case ApplicationStatus.offer:
        return '제안';
      case ApplicationStatus.hired:
        return '채용확정';
      case ApplicationStatus.rejected:
        return '거절됨';
      case ApplicationStatus.cancelled:
        return '취소됨';
    }
  }

  Color get statusColor {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange[600]!;
      case ApplicationStatus.reviewing:
        return Colors.blue[600]!;
      case ApplicationStatus.interview:
        return Colors.purple[600]!;
      case ApplicationStatus.offer:
        return Colors.green[600]!;
      case ApplicationStatus.hired:
        return const Color(0xFF00A3A3);
      case ApplicationStatus.rejected:
        return Colors.red[600]!;
      case ApplicationStatus.cancelled:
        return Colors.grey[600]!;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case ApplicationStatus.pending:
        return Icons.schedule;
      case ApplicationStatus.reviewing:
        return Icons.search;
      case ApplicationStatus.interview:
        return Icons.event;
      case ApplicationStatus.offer:
        return Icons.local_offer;
      case ApplicationStatus.hired:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
      case ApplicationStatus.cancelled:
        return Icons.close;
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
    return status == ApplicationStatus.pending || status == ApplicationStatus.reviewing;
  }

  bool get hasAction {
    return status == ApplicationStatus.interview ||
        status == ApplicationStatus.offer ||
        canCancel;
  }

  String get actionText {
    switch (status) {
      case ApplicationStatus.interview:
        return '면접 일정 확인';
      case ApplicationStatus.offer:
        return '제안 확인';
      case ApplicationStatus.pending:
      case ApplicationStatus.reviewing:
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
      case ApplicationStatus.pending:
        return '대기중';
      case ApplicationStatus.reviewing:
        return '검토중';
      case ApplicationStatus.interview:
        return '면접';
      case ApplicationStatus.offer:
        return '제안';
      case ApplicationStatus.hired:
        return '채용확정';
      case ApplicationStatus.rejected:
        return '거절됨';
      case ApplicationStatus.cancelled:
        return '취소됨';
    }
  }

  String get apiValue {
    switch (this) {
      case ApplicationStatus.pending:
        return 'PENDING';
      case ApplicationStatus.reviewing:
        return 'REVIEWING';
      case ApplicationStatus.interview:
        return 'INTERVIEW';
      case ApplicationStatus.offer:
        return 'OFFER';
      case ApplicationStatus.hired:
        return 'HIRED';
      case ApplicationStatus.rejected:
        return 'REJECTED';
      case ApplicationStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.pending:
        return Colors.orange[600]!;
      case ApplicationStatus.reviewing:
        return Colors.blue[600]!;
      case ApplicationStatus.interview:
        return Colors.purple[600]!;
      case ApplicationStatus.offer:
        return Colors.green[600]!;
      case ApplicationStatus.hired:
        return const Color(0xFF00A3A3);
      case ApplicationStatus.rejected:
        return Colors.red[600]!;
      case ApplicationStatus.cancelled:
        return Colors.grey[600]!;
    }
  }
}