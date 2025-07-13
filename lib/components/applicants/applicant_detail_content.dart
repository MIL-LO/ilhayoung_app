// ========================================
// lib/components/applicants/applicant_detail_content.dart - 완전 수정 버전
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/applicant_management_service.dart';
import '../../services/worker_management_service.dart';
import '../../models/job_posting_model.dart';

class ApplicantDetailContent extends StatefulWidget {
  final ApplicantDetail detail;
  final JobApplicant applicant;
  final JobPosting jobPosting;
  final Function(String) onStatusChanged;

  const ApplicantDetailContent({
    Key? key,
    required this.detail,
    required this.applicant,
    required this.jobPosting,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State<ApplicantDetailContent> createState() => _ApplicantDetailContentState();
}

class _ApplicantDetailContentState extends State<ApplicantDetailContent> {
  bool _isUpdating = false;
  String _currentStatus = '';

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.applicant.status;
  }

  // 안전한 지원자 이름 가져오기 - 가장 먼저 정의
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            '기본 정보',
            Icons.person_outline,
            [
              _buildInfoRow('이름', widget.detail.name),
              _buildInfoRow('생년월일', '${widget.detail.birthDate} (${widget.detail.age}세)'),
              _buildInfoRow('연락처', widget.detail.contact),
              _buildInfoRow('주소', widget.detail.address),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '기후 적응 점수',
            Icons.eco,
            [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getClimateScoreColor(widget.detail.climateScore),
                      _getClimateScoreColor(widget.detail.climateScore).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _getClimateScoreColor(widget.detail.climateScore).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.detail.climateScore}점',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getClimateScoreDescription(widget.detail.climateScore),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getScoreLevel(widget.detail.climateScore),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '경험 및 경력',
            Icons.work_outline,
            [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  widget.detail.experience.isNotEmpty
                      ? widget.detail.experience
                      : '경험 정보가 없습니다.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3748).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2D3748),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    // 이미 승인되었거나 처리된 상태인 경우
    if (_currentStatus == 'HIRED' || _currentStatus == 'APPROVED') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 승인 완료!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '지원자가 승인되어 근무 스케줄이 자동으로 생성되었습니다.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // 거절된 상태인 경우
    if (_currentStatus == 'REJECTED') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cancel,
              color: Colors.red[600],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '❌ 지원 거절됨',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '지원이 거절된 상태입니다.',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUpdating ? null : () => _updateStatus('PENDING'),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('재검토하기'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[600],
                  side: BorderSide(color: Colors.red[600]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 처리 가능한 상태인 경우
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUpdating ? null : () => _updateStatus('REJECTED'),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('거절'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUpdating ? null : () => _updateStatus('INTERVIEW'),
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('면접요청'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9C27B0),
                  side: const BorderSide(color: Color(0xFF9C27B0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isUpdating ? null : () => _showApprovalDialog(),
            icon: _isUpdating
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.check, size: 18),
            label: Text(_isUpdating ? '처리 중...' : '🎉 승인 및 스케줄 생성'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  void _showApprovalDialog() {
    DateTime selectedStartDate = DateTime.now().add(const Duration(days: 1));
    DateTime? selectedEndDate;
    double? hourlyRate = widget.jobPosting.salary?.toDouble();
    String workLocation = widget.jobPosting.workLocation ?? '';

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
                      Icon(Icons.info, color: Colors.blue[600], size: 24),
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
                  ? () {
                Navigator.pop(context);
                _approveAndCreateSchedule(
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
      _isUpdating = true;
    });

    try {
      print('=== 지원자 승인 및 스케줄 생성 시작 ===');
      print('지원자: ${_getApplicantName()}');
      print('시작일: ${startDate.toIso8601String()}');
      print('시급: $hourlyRate');

      // 1단계: 지원자 상태를 HIRED로 변경
      final statusResult = await ApplicantManagementService.updateApplicationStatus(
        widget.applicant.id,
        'HIRED',
      );

      if (!mounted) return;

      if (!statusResult['success']) {
        throw Exception(statusResult['error'] ?? '지원자 상태 변경에 실패했습니다');
      }

      print('✅ 1단계 완료: 지원자 상태 HIRED로 변경');

      // 2단계: 근무자 스케줄 자동 생성
      final scheduleResult = await WorkerManagementService.createWorkerSchedule(
        applicationId: widget.applicant.id,
        jobId: widget.jobPosting.id,
        startDate: startDate,
        hourlyRate: hourlyRate,
        workLocation: workLocation.isNotEmpty ? workLocation : null,
        workDetails: {
          'jobTitle': widget.jobPosting.title,
          'companyName': widget.jobPosting.companyName,
          'approvedAt': DateTime.now().toIso8601String(),
          'approvedBy': 'MANAGER',
        },
      );

      if (!mounted) return;

      if (scheduleResult['success']) {
        // 완전 성공
        setState(() {
          _currentStatus = 'HIRED';
        });

        print('✅ 2단계 완료: 근무자 스케줄 생성');
        print('=== 승인 및 스케줄 생성 완료 ===');

        // 성공 메시지 표시
        _showSuccessMessage(
          '🎉 ${_getApplicantName()}님이 승인되었습니다!\n'
              '근무 스케줄이 자동으로 생성되었습니다.',
        );

        // 햅틱 피드백 (더 간단한 방법)
        HapticFeedback.lightImpact();

        // 콜백 호출
        widget.onStatusChanged('HIRED');

      } else {
        // 스케줄 생성은 실패했지만 승인은 완료됨
        setState(() {
          _currentStatus = 'HIRED';
        });

        print('⚠️ 2단계 실패: 스케줄 생성 실패 - ${scheduleResult['error']}');

        _showWarningMessage(
          '지원자 승인은 완료되었으나\n'
              '스케줄 생성에 실패했습니다.\n'
              '수동으로 스케줄을 생성해주세요.\n\n'
              '오류: ${scheduleResult['error']}',
        );

        widget.onStatusChanged('HIRED');
      }

    } catch (e) {
      if (!mounted) return;
      print('❌ 승인 및 스케줄 생성 실패: $e');
      _showErrorMessage('승인 처리 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final result = await ApplicantManagementService.updateApplicationStatus(
        widget.applicant.id,
        status,
      );

      if (result['success']) {
        setState(() {
          _currentStatus = status;
        });

        String message = '';
        switch (status) {
          case 'REJECTED':
            message = '❌ ${_getApplicantName()}님의 지원이 거절되었습니다.';
            break;
          case 'INTERVIEW':
            message = '📞 ${_getApplicantName()}님께 면접 요청을 보냈습니다.';
            break;
          case 'PENDING':
            message = '🔄 ${_getApplicantName()}님의 상태가 재검토로 변경되었습니다.';
            break;
          default:
            message = '상태가 변경되었습니다.';
        }

        _showSuccessMessage(message);
        widget.onStatusChanged(status);

      } else {
        _showErrorMessage(result['error'] ?? '상태 변경에 실패했습니다');
      }
    } catch (e) {
      _showErrorMessage('상태 변경 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Color _getClimateScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFF2196F3);
    if (score >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String _getClimateScoreDescription(int score) {
    if (score >= 80) return '제주 기후에 매우 적합';
    if (score >= 60) return '제주 기후에 적합';
    if (score >= 40) return '제주 기후 적응 가능';
    return '제주 기후 적응 필요';
  }

  String _getScoreLevel(int score) {
    if (score >= 80) return '매우 우수';
    if (score >= 60) return '우수';
    if (score >= 40) return '양호';
    return '개선 필요';
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
}