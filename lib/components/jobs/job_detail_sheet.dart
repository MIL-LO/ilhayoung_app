// lib/components/jobs/job_detail_sheet.dart - 채용공고 상세보기 컴포넌트

import 'package:flutter/material.dart';
import '../../models/job_posting_model.dart';
import '../../services/job_api_service.dart';

class JobDetailSheet extends StatefulWidget {
  final JobPosting job;
  final Function(String)? onApply;

  const JobDetailSheet({
    Key? key,
    required this.job,
    this.onApply,
  }) : super(key: key);

  @override
  State<JobDetailSheet> createState() => _JobDetailSheetState();
}

class _JobDetailSheetState extends State<JobDetailSheet> {
  bool _isLoading = true;
  bool _isApplying = false;
  Map<String, dynamic>? _jobDetail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadJobDetail();
  }

  Future<void> _loadJobDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('=== 채용공고 상세 조회 시작 ===');
      print('공고 ID: ${widget.job.id}');

      final result = await JobApiService.getJobDetail(widget.job.id);

      if (result['success']) {
        setState(() {
          _jobDetail = result['data'];
          _isLoading = false;
        });
        print('✅ 채용공고 상세 조회 성공');
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['error'] ?? '상세 정보를 불러올 수 없습니다';
        });
        print('❌ 채용공고 상세 조회 실패: ${result['error']}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '네트워크 오류가 발생했습니다';
      });
      print('❌ 채용공고 상세 조회 예외: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? _buildLoadingWidget()
                : _errorMessage != null
                ? _buildErrorWidget()
                : _buildContent(),
          ),
          if (!_isLoading && _errorMessage == null) _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // 헤더 정보
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00A3A3), Color(0xFF00D4AA)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.work,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.job.companyName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.grey[600]),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          // 상태 태그들
          const SizedBox(height: 12),
          Row(
            children: [
              if (widget.job.isNew)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (widget.job.isUrgent) ...[
                if (widget.job.isNew) const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '급구',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.job.isExpired
                      ? Colors.red[50]
                      : const Color(0xFF00A3A3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.job.isExpired
                        ? Colors.red[300]!
                        : const Color(0xFF00A3A3),
                  ),
                ),
                child: Text(
                  widget.job.daysUntilDeadline > 0
                      ? 'D-${widget.job.daysUntilDeadline}'
                      : '마감',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.job.isExpired
                        ? Colors.red[600]
                        : const Color(0xFF00A3A3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A3A3)),
          ),
          SizedBox(height: 16),
          Text(
            '상세 정보를 불러오는 중...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF00A3A3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[400],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadJobDetail,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A3A3),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 급여 정보 (하이라이트)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00A3A3), Color(0xFF00D4AA)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💰 급여 정보',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.job.formattedSalary,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 근무 정보
          _buildDetailSection('🏢 근무 정보', [
            _buildDetailItem('근무지', _jobDetail?['workLocation'] ?? widget.job.workLocation),
            _buildDetailItem('근무시간', _jobDetail?['workTime'] ?? widget.job.workScheduleText),
            _buildDetailItem('근무요일', _jobDetail?['workDays'] ?? widget.job.workDaysText),
            _buildDetailItem('근무기간', _jobDetail?['workPeriod'] ?? widget.job.workSchedule.workPeriodText),
          ]),

          // 채용 정보
          _buildDetailSection('📋 채용 정보', [
            _buildDetailItem('모집인원', _jobDetail?['recruitCount']?.toString() ?? '1명'),
            _buildDetailItem('지원자 수', '${widget.job.applicationCount}명'),
            _buildDetailItem('등록일', _formatDate(widget.job.createdAt)),
            _buildDetailItem('마감일', _formatDate(widget.job.deadline)),
          ]),

          // 업무 내용 (API에서 받은 상세 정보)
          if (_jobDetail?['jobDescription'] != null) ...[
            _buildDetailSection('📝 업무 내용', [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _jobDetail!['jobDescription'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ]),
          ],

          // 자격 요건 (API에서 받은 상세 정보)
          if (_jobDetail?['requirements'] != null) ...[
            _buildDetailSection('✅ 자격 요건', [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _jobDetail!['requirements'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ]),
          ],

          // 우대사항 (API에서 받은 상세 정보)
          if (_jobDetail?['preferredQualifications'] != null) ...[
            _buildDetailSection('⭐ 우대사항', [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _jobDetail!['preferredQualifications'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ]),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: widget.job.isExpired || _isApplying ? null : _handleApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.job.isExpired
                  ? Colors.grey[400]
                  : const Color(0xFF00A3A3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isApplying
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '지원 중...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.job.isExpired ? Icons.close : Icons.send,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.job.isExpired ? '마감된 공고' : '🚀 지원하기',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleApply() async {
    // 지원 확인 다이얼로그
    final shouldApply = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🎯 지원 확인',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.job.companyName}'),
            const SizedBox(height: 4),
            Text(
              '"${widget.job.title}"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('위 공고에 지원하시겠습니까?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A3A3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('지원하기'),
          ),
        ],
      ),
    );

    if (shouldApply != true) return;

    setState(() {
      _isApplying = true;
    });

    try {
      final result = await JobApiService.applyToJob(widget.job.id);

      if (mounted) {
        if (result['success']) {
          // 성공 시 콜백 호출 및 바텀시트 닫기
          if (widget.onApply != null) {
            widget.onApply!(result['message'] ?? '지원이 완료되었습니다.');
          }
          Navigator.pop(context);
        } else {
          // 실패 시 에러 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? '지원에 실패했습니다.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('지원 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 정적 메서드로 바텀시트 표시
  static void show(
      BuildContext context,
      JobPosting job, {
        Function(String)? onApply,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => JobDetailSheet(
        job: job,
        onApply: onApply,
      ),
    );
  }
}