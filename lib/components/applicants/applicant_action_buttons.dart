import 'package:flutter/material.dart';
import '../../services/applicant_management_service.dart';
import '../../services/worker_management_service.dart';
import '../../models/job_posting_model.dart';

class ApplicantActionButtons extends StatelessWidget {
  final JobApplicant applicant;
  final JobPosting jobPosting;
  final Function(String) onStatusChanged;

  const ApplicantActionButtons({
    Key? key,
    required this.applicant,
    required this.jobPosting,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateStatus(context, 'REJECTED'),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('거절'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateStatus(context, 'INTERVIEW'),
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text('면접요청'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9C27B0),
                  side: const BorderSide(color: Color(0xFF9C27B0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _updateStatus(context, 'HIRED'),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('승인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        // 승인된 지원자인 경우 근무자 등록 버튼 추가
        if (applicant.status == 'HIRED' || applicant.status == 'APPROVED') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showWorkerRegistrationDialog(context),
              icon: const Icon(Icons.work, size: 18),
              label: const Text('근무자 등록'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3748),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      final result = await ApplicantManagementService.updateApplicationStatus(
        applicant.id,
        newStatus,
      );

      if (result['success']) {
        onStatusChanged(newStatus);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '상태가 변경되었습니다'),
            backgroundColor: const Color(0xFF2D3748),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showErrorMessage(context, result['error']);
      }
    } catch (e) {
      _showErrorMessage(context, '상태 변경에 실패했습니다: $e');
    }
  }

  void _showWorkerRegistrationDialog(BuildContext context) {
    DateTime? startDate;
    DateTime? endDate;
    double? hourlyRate;
    String workLocation = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.work, color: Color(0xFF2D3748)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${applicant.name}님 근무자 등록',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '근무 정보를 입력해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // 근무 시작일 선택
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: Color(0xFF2D3748)),
                    title: const Text('근무 시작일'),
                    subtitle: Text(
                      startDate != null
                          ? '${startDate!.year}.${startDate!.month.toString().padLeft(2, '0')}.${startDate!.day.toString().padLeft(2, '0')}'
                          : '날짜를 선택해주세요',
                      style: TextStyle(
                        color: startDate != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF2D3748),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setDialogState(() {
                          startDate = date;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 근무 종료일 선택 (선택사항)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.event_busy, color: Colors.grey),
                    title: const Text('근무 종료일 (선택사항)'),
                    subtitle: Text(
                      endDate != null
                          ? '${endDate!.year}.${endDate!.month.toString().padLeft(2, '0')}.${endDate!.day.toString().padLeft(2, '0')}'
                          : '종료일을 선택해주세요',
                      style: TextStyle(
                        color: endDate != null ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    onTap: startDate != null ? () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate!.add(const Duration(days: 1)),
                        firstDate: startDate!.add(const Duration(days: 1)),
                        lastDate: startDate!.add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF2D3748),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setDialogState(() {
                          endDate = date;
                        });
                      }
                    } : null,
                  ),
                ),

                const SizedBox(height: 16),

                // 시급 입력
                TextField(
                  decoration: InputDecoration(
                    labelText: '시급 (원)',
                    hintText: '예: 10000',
                    prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF2D3748)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2D3748)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    hourlyRate = double.tryParse(value);
                  },
                ),

                const SizedBox(height: 16),

                // 근무 장소 입력
                TextField(
                  decoration: InputDecoration(
                    labelText: '근무 장소 (선택사항)',
                    hintText: '예: 제주시 연동',
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2D3748)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF2D3748)),
                    ),
                  ),
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
              child: Text(
                '취소',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: startDate != null && hourlyRate != null && hourlyRate! > 0
                  ? () => _registerWorker(context, startDate!, endDate, hourlyRate!, workLocation.isEmpty ? null : workLocation)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3748),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('등록'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerWorker(
      BuildContext context,
      DateTime startDate,
      DateTime? endDate,
      double hourlyRate,
      String? workLocation,
      ) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
          ),
        ),
      );

      final result = await WorkerManagementService.createWorker(
        applicationId: applicant.id,
        jobId: jobPosting.id,
        startDate: startDate,
        endDate: endDate,
        hourlyRate: hourlyRate,
        workLocation: workLocation,
      );

      // 로딩 다이얼로그 닫기
      Navigator.pop(context);

      if (result['success']) {
        // 등록 다이얼로그 닫기
        Navigator.pop(context);

        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('${applicant.name}님이 근무자로 등록되었습니다'),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        _showErrorMessage(context, result['error']);
      }
    } catch (e) {
      // 로딩 다이얼로그 닫기
      Navigator.pop(context);
      _showErrorMessage(context, '근무자 등록에 실패했습니다: $e');
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
