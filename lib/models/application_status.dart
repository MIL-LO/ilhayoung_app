import 'package:flutter/material.dart';

enum ApplicationStatus {
  closed,      // 마감
  offer,       // 채용제안
  interview,   // 면접 요청
  hired        // 채용 확정
}

class JobApplication {
  final int id;
  final String jobTitle;
  final String company;
  final String location;
  final String salary;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final String workType;
  final List<String> tags;
  final bool isUrgent;

  JobApplication({
    required this.id,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.salary,
    required this.status,
    required this.appliedDate,
    required this.workType,
    required this.tags,
    this.isUrgent = false,
  });

  // 상태별 색상 반환
  Color get statusColor {
    switch (status) {
      case ApplicationStatus.closed:
        return Colors.grey[600]!;
      case ApplicationStatus.offer:
        return const Color(0xFF4CAF50); // 초록색
      case ApplicationStatus.interview:
        return const Color(0xFFFF6B35); // 주황색
      case ApplicationStatus.hired:
        return const Color(0xFF00A3A3); // 제주 바다색
    }
  }

  // 상태별 배경색 반환
  Color get statusBackgroundColor {
    switch (status) {
      case ApplicationStatus.closed:
        return Colors.grey[100]!;
      case ApplicationStatus.offer:
        return const Color(0xFF4CAF50).withOpacity(0.1);
      case ApplicationStatus.interview:
        return const Color(0xFFFF6B35).withOpacity(0.1);
      case ApplicationStatus.hired:
        return const Color(0xFF00A3A3).withOpacity(0.1);
    }
  }

  // 상태별 텍스트 반환
  String get statusText {
    switch (status) {
      case ApplicationStatus.closed:
        return '마감';
      case ApplicationStatus.offer:
        return '채용제안';
      case ApplicationStatus.interview:
        return '면접 요청';
      case ApplicationStatus.hired:
        return '채용 확정';
    }
  }

  // 상태별 아이콘 반환
  IconData get statusIcon {
    switch (status) {
      case ApplicationStatus.closed:
        return Icons.close;
      case ApplicationStatus.offer:
        return Icons.handshake;
      case ApplicationStatus.interview:
        return Icons.chat_bubble;
      case ApplicationStatus.hired:
        return Icons.check_circle;
    }
  }

  // 지원일로부터 경과 시간 계산
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(appliedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  // 액션 가능 여부
  bool get hasAction {
    return status == ApplicationStatus.offer ||
           status == ApplicationStatus.interview;
  }

  // 액션 텍스트
  String get actionText {
    switch (status) {
      case ApplicationStatus.offer:
        return '제안 확인';
      case ApplicationStatus.interview:
        return '면접 일정';
      default:
        return '';
    }
  }
}