// lib/components/jobs/job_action_button.dart - 기존 모델과 호환되는 수정

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/job_posting_model.dart';
import '../../services/applicant_management_service.dart';
import '../../screens/employer/jobs/job_edit_screen.dart';

class JobActionButton extends StatelessWidget {
  final JobPosting job;
  final String actionType;
  final VoidCallback? onSuccess;
  final VoidCallback? onTap;

  const JobActionButton({
    Key? key,
    required this.job,
    required this.actionType,
    this.onSuccess,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (actionType) {
      case 'edit':
        return _buildEditButton(context);
      case 'delete':
        return _buildDeleteButton(context);
      case 'status':
        return _buildStatusButton(context);
      case 'applicants':
        return _buildApplicantsButton(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEditButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _handleEdit(context),
      icon: const Icon(Icons.edit, size: 16),
      label: const Text('수정'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2D3748),
        side: const BorderSide(color: Color(0xFF2D3748)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _handleDelete(context),
      icon: const Icon(Icons.delete, size: 16),
      label: const Text('삭제'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context) {
    // 안전한 기본값으로 처리
    final isActive = _getJobActiveStatus();

    return ElevatedButton.icon(
      onPressed: () => _handleStatusChange(context),
      icon: Icon(
        isActive ? Icons.pause : Icons.play_arrow,
        size: 16,
      ),
      label: Text(isActive ? '일시정지' : '재시작'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.orange : const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildApplicantsButton(BuildContext context) {
    // 안전한 기본값으로 처리
    final applicantCount = _getApplicantCount();

    return ElevatedButton.icon(
      onPressed: onTap ?? () => _handleViewApplicants(context),
      icon: const Icon(Icons.people, size: 16),
      label: Text('지원자 ${applicantCount}명'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D3748),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Helper 메서드들 - 기존 모델과 호환
  bool _getJobActiveStatus() {
    // 1. 우선 isActive 프로퍼티가 있는지 확인
    try {
      return (job as dynamic).isActive ?? true;
    } catch (e) {
      // 2. deadline으로 판단 (마감일이 지났으면 비활성)
      return job.deadline.isAfter(DateTime.now());
    }
  }

  int _getApplicantCount() {
    try {
      return (job as dynamic).applicantCount ?? 0;
    } catch (e) {
      return 0; // 기본값
    }
  }

  String _getJobPosition() {
    try {
      return (job as dynamic).position ?? job.title;
    } catch (e) {
      return job.title; // position이 없으면 title 사용
    }
  }

  void _handleEdit(BuildContext context) {
    HapticFeedback.lightImpact();

    // JobEditScreen으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobEditScreen(jobPosting: job),
      ),
    ).then((result) {
      // 수정이나 삭제가 완료되면 새로고침
      if (result == true || result == 'deleted') {
        onSuccess?.call();
      }
    });
  }

  void _handleDelete(BuildContext context) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '⚠️ 공고 삭제',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정말로 "${job.title}" 공고를 삭제하시겠습니까?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Text(
                '⚠️ 삭제된 공고는 복구할 수 없으며, 모든 지원자 정보도 함께 삭제됩니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => _confirmDelete(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _handleStatusChange(BuildContext context) {
    HapticFeedback.lightImpact();

    final isActive = _getJobActiveStatus();
    final newStatus = isActive ? 'INACTIVE' : 'ACTIVE';
    final statusText = isActive ? '일시정지' : '재시작';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '공고 $statusText',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        content: Text(
          '${job.title} 공고를 ${statusText}하시겠습니까?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => _confirmStatusChange(context, newStatus, statusText),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'ACTIVE'
                  ? const Color(0xFF4CAF50)
                  : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(statusText),
          ),
        ],
      ),
    );
  }

  void _handleViewApplicants(BuildContext context) {
    HapticFeedback.lightImpact();
    onTap?.call();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
        ),
      ),
    );

    try {
      final result = await ApplicantManagementService.deleteJobPosting(job.id);

      Navigator.pop(context);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '공고가 삭제되었습니다'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
        onSuccess?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmStatusChange(BuildContext context, String newStatus, String statusText) async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
        ),
      ),
    );

    try {
      final result = await ApplicantManagementService.updateJobPostingStatus(job.id, newStatus);

      Navigator.pop(context);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '공고 상태가 변경되었습니다'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
        onSuccess?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('상태 변경 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}