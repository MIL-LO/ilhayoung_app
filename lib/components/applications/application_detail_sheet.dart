// lib/components/applications/application_detail_sheet.dart - 상세보기 바텀시트

import 'package:flutter/material.dart';
import '../../models/application_model.dart';
import '../../models/application_detail_model.dart';
import '../../services/application_api_service.dart';

class ApplicationDetailSheet extends StatefulWidget {
  final JobApplication application;
  final VoidCallback? onRefresh;

  const ApplicationDetailSheet({
    Key? key,
    required this.application,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<ApplicationDetailSheet> createState() => _ApplicationDetailSheetState();

  /// 정적 메서드로 바텀시트 표시
  static void show(
      BuildContext context, {
        required JobApplication application,
        VoidCallback? onRefresh,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ApplicationDetailSheet(
        application: application,
        onRefresh: onRefresh,
      ),
    );
  }
}

class _ApplicationDetailSheetState extends State<ApplicationDetailSheet> {
  bool _isLoading = true;
  ApplicationDetail? _applicationDetail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApplicationDetail();
  }

  Future<void> _loadApplicationDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await ApplicationApiService.getApplicationDetail(widget.application.id);

      if (result['success']) {
        setState(() {
          _applicationDetail = ApplicationDetail.fromJson(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['error'] ?? '상세 정보를 불러올 수 없습니다';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '네트워크 오류가 발생했습니다';
      });
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
          if (!_isLoading && _errorMessage == null && widget.application.hasAction)
            _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 드래그 핸들
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // 헤더 정보
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.application.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.application.statusIcon,
                  color: widget.application.statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.application.jobTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.application.company,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
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
            '지원서 상세 정보를 불러오는 중...',
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
            onPressed: _loadApplicationDetail,
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
    if (_applicationDetail == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection('지원 정보', [
            _buildDetailItem('지원일', _applicationDetail!.formattedAppliedDate),
            _buildDetailItem('상태', _applicationDetail!.statusDisplayText),
            _buildDetailItem('마감일', _applicationDetail!.formattedDeadline),
          ]),

          _buildDetailSection('지원자 정보', [
            _buildDetailItem('성명', _applicationDetail!.name),
            _buildDetailItem('생년월일', _applicationDetail!.formattedBirthDate),
            _buildDetailItem('연락처', _applicationDetail!.formattedContact),
            _buildDetailItem('주소', _applicationDetail!.address),
            _buildDetailItem('오름 점수', '${_applicationDetail!.climateScore}점'),
          ]),

          _buildDetailSection('경험 및 경력', [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _applicationDetail!.experience.isNotEmpty
                    ? _applicationDetail!.experience
                    : '경험 정보가 없습니다',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
          ]),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildActionButton() {
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
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAction();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.application.statusColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.application.actionText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction() async {
    switch (widget.application.status) {
      case ApplicationStatus.interview:
        _showSnackBar('면접 일정 확인 기능은 준비 중입니다', Colors.orange[600]!);
        break;
      case ApplicationStatus.applied:
        _showCancelDialog();
        break;
      default:
        break;
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지원 취소'),
        content: Text('${widget.application.jobTitle} 공고에 대한 지원을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelApplication();
            },
            child: Text(
              '취소하기',
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelApplication() async {
    try {
      _showSnackBar('지원을 취소하는 중...', Colors.orange[600]!);

      final result = await ApplicationApiService.cancelApplication(widget.application.id);

      if (result['success']) {
        _showSnackBar(result['message'] ?? '지원이 취소되었습니다', Colors.green[600]!);
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
        Navigator.pop(context);
      } else {
        _showSnackBar(result['error'] ?? '지원 취소에 실패했습니다', Colors.red[600]!);
      }
    } catch (e) {
      _showSnackBar('지원 취소 중 오류가 발생했습니다', Colors.red[600]!);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}