// ========================================
// lib/components/applicants/applicant_card.dart
// ========================================

import 'package:flutter/material.dart';
import '../../services/applicant_management_service.dart';

class ApplicantCard extends StatelessWidget {
  final JobApplicant applicant;
  final VoidCallback onTap;
  final VoidCallback onStatusChange;

  const ApplicantCard({
    Key? key,
    required this.applicant,
    required this.onTap,
    required this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 정보 (프로필 + 상태)
                Row(
                  children: [
                    // 프로필 아바타
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(applicant.status).withOpacity(0.2),
                            _getStatusColor(applicant.status).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getStatusColor(applicant.status).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          applicant.name.isNotEmpty
                              ? applicant.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(applicant.status),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 이름 및 연락처
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            applicant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            applicant.contact,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 상태 뱃지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(applicant.status),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(applicant.status).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusText(applicant.status),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 기후점수 및 지원일
                Row(
                  children: [
                    // 기후점수
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getClimateScoreColor(applicant.climateScore),
                            _getClimateScoreColor(applicant.climateScore).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.eco,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '기후점수 ${applicant.climateScore}점',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // 지원일
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${applicant.daysSinceApplied}일 전',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 액션 버튼들
                Row(
                  children: [
                    // 상세보기 버튼
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('상세보기'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2D3748),
                          side: const BorderSide(color: Color(0xFF2D3748)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 상태변경/재검토 버튼
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: onStatusChange,
                        icon: Icon(
                          _getActionIcon(applicant.status),
                          size: 16,
                        ),
                        label: Text(_getActionText(applicant.status)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getActionColor(applicant.status),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
      case 'APPLIED':
        return '검토 대기';
      case 'REVIEWING':
        return '검토 중';
      case 'INTERVIEW':
        return '면접 요청';
      case 'HIRED':
      case 'APPROVED':
        return '승인됨';
      case 'REJECTED':
        return '거절됨';
      default:
        return '알 수 없음';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
      case 'APPLIED':
        return const Color(0xFFFF9800); // 주황색
      case 'REVIEWING':
        return const Color(0xFF2196F3); // 파란색
      case 'INTERVIEW':
        return const Color(0xFF9C27B0); // 보라색
      case 'HIRED':
      case 'APPROVED':
        return const Color(0xFF4CAF50); // 녹색
      case 'REJECTED':
        return const Color(0xFFF44336); // 빨간색
      default:
        return Colors.grey;
    }
  }

  Color _getClimateScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50); // 녹색 - 우수
    if (score >= 60) return const Color(0xFF2196F3); // 파란색 - 양호
    if (score >= 40) return const Color(0xFFFF9800); // 주황색 - 보통
    return const Color(0xFFF44336); // 빨간색 - 개선 필요
  }

  String _getActionText(String status) {
    switch (status) {
      case 'HIRED':
      case 'APPROVED':
      case 'REJECTED':
        return '재검토';
      default:
        return '상태변경';
    }
  }

  IconData _getActionIcon(String status) {
    switch (status) {
      case 'HIRED':
      case 'APPROVED':
      case 'REJECTED':
        return Icons.refresh;
      default:
        return Icons.edit;
    }
  }

  Color _getActionColor(String status) {
    switch (status) {
      case 'HIRED':
      case 'APPROVED':
        return const Color(0xFF4CAF50); // 녹색 - 승인된 상태
      case 'REJECTED':
        return const Color(0xFFFF9800); // 주황색 - 재검토 필요
      default:
        return const Color(0xFF2D3748); // 기본 어두운색
    }
  }
}