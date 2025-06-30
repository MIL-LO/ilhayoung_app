import 'package:flutter/material.dart';

class WorkSchedule {
  final int id;
  final String company;
  final String position;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status; // 'scheduled', 'working', 'completed'
  final Color companyColor;
  final bool isMyWork; // 내 근무인지 여부

  WorkSchedule({
    required this.id,
    required this.company,
    required this.position,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.companyColor,
    this.isMyWork = false,
  });

  // 상태별 색상 반환
  Color get statusColor {
    switch (status) {
      case 'working':
        return const Color(0xFF4CAF50); // 초록색 - 근무 중
      case 'completed':
        return Colors.grey[600]!; // 회색 - 완료
      case 'scheduled':
      default:
        return companyColor; // 기업 색상 - 예정
    }
  }

  // 상태별 아이콘 반환
  IconData get statusIcon {
    switch (status) {
      case 'working':
        return Icons.work;
      case 'completed':
        return Icons.check_circle;
      case 'scheduled':
      default:
        return Icons.schedule;
    }
  }

  // 상태별 텍스트 반환
  String get statusText {
    switch (status) {
      case 'working':
        return '근무 중';
      case 'completed':
        return '완료';
      case 'scheduled':
      default:
        return '예정';
    }
  }
}