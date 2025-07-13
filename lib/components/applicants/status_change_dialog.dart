// ========================================
// lib/components/applicants/status_change_dialog.dart - 에러 수정 버전
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/applicant_management_service.dart';
import '../../services/worker_management_service.dart';
import '../../models/job_posting_model.dart';

class StatusChangeDialog extends StatefulWidget {
  final JobApplicant applicant;
  final JobPosting? jobPosting;
  final Function(String) onStatusChanged;

  const StatusChangeDialog({
    Key? key,
    required this.applicant,
    this.jobPosting,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State<StatusChangeDialog> createState() => _StatusChangeDialogState();
}

class _StatusChangeDialogState extends State<StatusChangeDialog> {
  String _selectedStatus = '';
  bool _isLoading = false;
  String _note = '';

  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'PENDING',
      'label': '검토 대기',
      'description': '지원서를 다시 검토 대기 상태로 변경',
      'icon': Icons.schedule,
      'color': Color(0xFFFF9800),
    },
    {
      'value': 'REVIEWING',
      'label': '검토 중',
      'description': '현재 지원서를 검토 중인 상태로 변경',
      'icon': Icons.rate_review,
      'color': Color(0xFF2196F3),
    },
    {
      'value': 'INTERVIEW',
      'label': '면접 요청',
      'description': '지원자에게 면접 요청을 보내는 상태',
      'icon': Icons.video_call,
      'color': Color(0xFF9C27B0),
    },
    {
      'value': 'HIRED',
      'label': '승인 및 스케줄 생성',
      'description': '지원자를 승인하고 자동으로 근무 스케줄 생성',
      'icon': Icons.check_circle,
      'color': Color(0xFF4CAF50),
    },
    {
      'value': 'REJECTED',
      'label': '거절',
      'description': '지원을 거절하는 상태로 변경',
      'icon': Icons.cancel,
      'color': Color(0xFFF44336),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.applicant.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                // name 필드가 없을 수 있으므로 안전하게 처리
                _getApplicantName().isNotEmpty
                    ? _getApplicantName()[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getApplicantName()}님',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '상태 변경',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '현재 상태: ${_getCurrentStatusText()}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              '새로운 상태 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // 상태 옵션들
            Container(
              constraints: const BoxConstraints(maxHeight: 350),
              child: SingleChildScrollView(
                child: Column(
                  children: _statusOptions.map((option) {
                    final isSelected = _selectedStatus == option['value'];
                    final isCurrent = widget.applicant.status == option['value'];
                    final isHired = option['value'] == 'HIRED';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isCurrent ? null : () {
                            setState(() {
                              _selectedStatus = option['value'];
                            });
                            HapticFeedback.selectionClick();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Colors.grey[100]
                                  : isSelected
                                  ? option['color'].withOpacity(0.1)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent
                                    ? Colors.grey[300]!
                                    : isSelected
                                    ? option['color']
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? Colors.grey[300]
                                        : option['color'].withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    option['icon'],
                                    color: isCurrent
                                        ? Colors.grey[600]
                                        : option['color'],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            option['label'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isCurrent
                                                  ? Colors.grey[600]
                                                  : Colors.black87,
                                            ),
                                          ),
                                          if (isCurrent) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[400],
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                '현재',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (isHired && !isCurrent) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.green[400]!, Colors.green[600]!],
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                '자동',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        option['description'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isCurrent
                                              ? Colors.grey[500]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected && !isCurrent)
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: option['color'],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 메모 입력
            const Text(
              '메모 (선택사항)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: '상태 변경 사유를 입력하세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 2,
              onChanged: (value) {
                _note = value;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            '취소',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedStatus == widget.applicant.status
              ? null
              : () => _updateStatus(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getSelectedStatusColor(),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(_getActionButtonText()),
        ),
      ],
    );
  }

  String _getCurrentStatusText() {
    final currentOption = _statusOptions.firstWhere(
          (option) => option['value'] == widget.applicant.status,
      orElse: () => {'label': '알 수 없음'},
    );
    return currentOption['label'];
  }

  Color _getSelectedStatusColor() {
    final selectedOption = _statusOptions.firstWhere(
          (option) => option['value'] == _selectedStatus,
      orElse: () => {'color': const Color(0xFF2D3748)},
    );
    return selectedOption['color'];
  }

  String _getActionButtonText() {
    if (_selectedStatus == 'HIRED') {
      return '🎉 승인 및 스케줄 생성';
    }
    return '상태 변경';
  }

  Future<void> _updateStatus() async {
    // 승인 상태인 경우 스케줄 생성 다이얼로그 표시
    if (_selectedStatus == 'HIRED') {
      Navigator.pop(context); // 현재 다이얼로그 닫기
      _showApprovalDialog();
      return;
    }

    // 일반 상태 변경
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApplicantManagementService.updateApplicationStatus(
        widget.applicant.id,
        _selectedStatus,
      );

      if (result['success']) {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        widget.onStatusChanged(_selectedStatus);
      } else {
        _showErrorMessage(result['error'] ?? '상태 변경에 실패했습니다');
      }
    } catch (e) {
      _showErrorMessage('상태 변경 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showApprovalDialog() {
    DateTime selectedStartDate = DateTime.now().add(const Duration(days: 1));
    double? hourlyRate = widget.jobPosting?.salary?.toDouble() ?? 12000.0;
    String workLocation = widget.jobPosting?.workLocation ?? '제주시';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check_circle, color: Colors.green[600]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${_getApplicantName()}님 승인'),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[50]!, Colors.blue[100]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.blue[600], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '승인과 동시에 근무 스케줄이 자동으로 생성됩니다.',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 근무 시작일
                const Text(
                  '🗓️ 근무 시작일',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedStartDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedStartDate = date;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: Colors.grey[600], size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(selectedStartDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 시급
                const Text(
                  '💰 시급 (원)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: '예: 12000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    prefixText: '₩ ',
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: hourlyRate?.toString() ?? '',
                  ),
                  onChanged: (value) {
                    hourlyRate = double.tryParse(value);
                  },
                ),
                const SizedBox(height: 16),

                // 근무 장소
                const Text(
                  '📍 근무 장소',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: '예: 제주시 연동',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  controller: TextEditingController(text: workLocation),
                  onChanged: (value) {
                    workLocation = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: hourlyRate != null && hourlyRate! > 0
                  ? () async {
                Navigator.pop(context);
                await _approveAndCreateSchedule(
                  startDate: selectedStartDate,
                  hourlyRate: hourlyRate!,
                  workLocation: workLocation,
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('🎉 승인 및 스케줄 생성'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveAndCreateSchedule({
    required DateTime startDate,
    required double hourlyRate,
    required String workLocation,
  }) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('=== 지원자 승인 및 스케줄 생성 시작 ===');
      print('지원자: ${_getApplicantName()}');

      // 1단계: 지원자 상태를 HIRED로 변경
      final statusResult = await ApplicantManagementService.updateApplicationStatus(
        widget.applicant.id,
        'HIRED',
      );

      if (!mounted) return;

      if (!statusResult['success']) {
        throw Exception(statusResult['error'] ?? '지원자 상태 변경에 실패했습니다');
      }

      // 2단계: 근무자 스케줄 자동 생성
      final scheduleResult = await WorkerManagementService.createWorkerSchedule(
        applicationId: widget.applicant.id,
        jobId: widget.jobPosting?.id ?? 'unknown_job_id',
        startDate: startDate,
        hourlyRate: hourlyRate,
        workLocation: workLocation.isNotEmpty ? workLocation : null,
        workDetails: {
          'approvedAt': DateTime.now().toIso8601String(),
          'approvedBy': 'MANAGER',
        },
      );

      if (!mounted) return;

      if (scheduleResult['success']) {
        HapticFeedback.lightImpact();
        _showSuccessMessage(
          '🎉 ${_getApplicantName()}님이 승인되었습니다!\n'
              '근무 스케줄이 자동으로 생성되었습니다.',
        );
        widget.onStatusChanged('HIRED');
      } else {
        _showWarningMessage(
          '지원자 승인은 완료되었으나\n'
              '스케줄 생성에 실패했습니다.\n\n'
              '오류: ${scheduleResult['error']}',
        );
        widget.onStatusChanged('HIRED');
      }

    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('승인 처리 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showWarningMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // 안전한 지원자 이름 가져오기
  String _getApplicantName() {
    try {
      if (widget.applicant.name != null && widget.applicant.name.isNotEmpty) {
        return widget.applicant.name;
      }
    } catch (e) {
      print('name 필드 접근 실패: $e');
    }

    // 대체 방법들
    try {
      final applicantMap = widget.applicant.toJson();
      return applicantMap['name'] ??
          applicantMap['applicantName'] ??
          applicantMap['na'] ??  // 실제 API 응답 필드
          applicantMap['contact'] ??
          '지원자';
    } catch (e) {
      print('toJson 변환 실패: $e');
    }

    // 최종 대안
    try {
      if (widget.applicant.contact != null && widget.applicant.contact.isNotEmpty) {
        return widget.applicant.contact.substring(0, 4) + '***';
      }
    } catch (e) {
      print('contact 필드 접근 실패: $e');
    }

    return '지원자';
  }
}