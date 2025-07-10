// lib/models/application_model.dart - 지원내역 모델

import 'package:flutter/material.dart';

enum ApplicationStatus {
  pending,    // 대기중
  reviewing,  // 검토중
  interview,  // 면접
  offer,      // 제안
  hired,      // 채용확정
  rejected,   // 거절
  cancelled,  // 취소
}

class JobApplication {
  final String id;
  final String recruitId;
  final String jobTitle;
  final String company;
  final String companyLocation;
  final int salary;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final String? message;
  final String? interviewDate;
  final String? offerDetails;

  JobApplication({
    required this.id,
    required this.recruitId,
    required this.jobTitle,
    required this.company,
    required this.companyLocation,
    required this.salary,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
    this.message,
    this.interviewDate,
    this.offerDetails,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id']?.toString() ?? '',
      recruitId: json['recruitId']?.toString() ?? '',
      jobTitle: json['jobTitle']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      companyLocation: json['companyLocation']?.toString() ?? '',
      salary: json['salary']?.toInt() ?? 0,
      status: _parseStatus(json['status']?.toString()),
      appliedAt: _parseDateTime(json['appliedAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      message: json['message']?.toString(),
      interviewDate: json['interviewDate']?.toString(),
      offerDetails: json['offerDetails']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recruitId': recruitId,
      'jobTitle': jobTitle,
      'company': company,
      'companyLocation': companyLocation,
      'salary': salary,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'message': message,
      'interviewDate': interviewDate,
      'offerDetails': offerDetails,
    };
  }

  static ApplicationStatus _parseStatus(String? statusString) {
    if (statusString == null) return ApplicationStatus.pending;

    switch (statusString.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'reviewing':
        return ApplicationStatus.reviewing;
      case 'interview':
        return ApplicationStatus.interview;
      case 'offer':
        return ApplicationStatus.offer;
      case 'hired':
        return ApplicationStatus.hired;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'cancelled':
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

  String get formattedSalary {
    if (salary == 0) return '급여 정보 없음';

    if (salary >= 10000) {
      // 월급인 경우 (10,000원 이상)
      return '월 ${salary.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      )}원';
    } else {
      // 시급인 경우
      return '시급 ${salary.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
      )}원';
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
}