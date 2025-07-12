// lib/screens/employer/applicants/applicant_management_screen.dart - 완전한 버전

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/applicant_management_service.dart';
import '../../../models/job_posting_model.dart';

class ApplicantManagementScreen extends StatefulWidget {
  final JobPosting jobPosting;

  const ApplicantManagementScreen({
    Key? key,
    required this.jobPosting,
  }) : super(key: key);

  @override
  State<ApplicantManagementScreen> createState() => _ApplicantManagementScreenState();
}

class _ApplicantManagementScreenState extends State<ApplicantManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<JobApplicant> _allApplicants = [];
  Map<String, List<JobApplicant>> _applicantsByStatus = {};
  bool _isLoading = true;

  final List<String> _statusList = ['ALL', 'PENDING', 'REVIEWING', 'INTERVIEW', 'HIRED', 'REJECTED'];
  final Map<String, String> _statusNames = {
    'ALL': '전체',
    'PENDING': '검토 대기',
    'REVIEWING': '검토 중',
    'INTERVIEW': '면접 요청',
    'HIRED': '승인',
    'REJECTED': '거절',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusList.length, vsync: this);
    _loadApplicants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadApplicants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApplicantManagementService.getJobApplicants(widget.jobPosting.id);

      if (result['success']) {
        final List<JobApplicant> applicants = result['data'];

        setState(() {
          _allApplicants = applicants;
          _applicantsByStatus = {
            'ALL': applicants,
            'PENDING': applicants.where((a) => a.status == 'PENDING' || a.status == 'APPLIED').toList(),
            'REVIEWING': applicants.where((a) => a.status == 'REVIEWING').toList(),
            'INTERVIEW': applicants.where((a) => a.status == 'INTERVIEW').toList(),
            'HIRED': applicants.where((a) => a.status == 'HIRED' || a.status == 'APPROVED').toList(),
            'REJECTED': applicants.where((a) => a.status == 'REJECTED').toList(),
          };
        });
      } else {
        _showErrorMessage(result['error']);
      }
    } catch (e) {
      _showErrorMessage('네트워크 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateApplicantsByStatus() {
    _applicantsByStatus = {
      'ALL': _allApplicants,
      'PENDING': _allApplicants.where((a) => a.status == 'PENDING' || a.status == 'APPLIED').toList(),
      'REVIEWING': _allApplicants.where((a) => a.status == 'REVIEWING').toList(),
      'INTERVIEW': _allApplicants.where((a) => a.status == 'INTERVIEW').toList(),
      'HIRED': _allApplicants.where((a) => a.status == 'HIRED' || a.status == 'APPROVED').toList(),
      'REJECTED': _allApplicants.where((a) => a.status == 'REJECTED').toList(),
    };
  }

  void _updateApplicantStatus(String applicantId, String newStatus) {
    setState(() {
      final applicantIndex = _allApplicants.indexWhere((a) => a.id == applicantId);
      if (applicantIndex != -1) {
        // copyWith 메소드 사용
        _allApplicants[applicantIndex] = _allApplicants[applicantIndex].copyWith(status: newStatus);
        _updateApplicantsByStatus();
      }
    });
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF2D3748),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.jobPosting.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            Text(
              '총 ${_allApplicants.length}명 지원',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2D3748)),
            onPressed: _loadApplicants,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statusList.map((status) {
                final applicants = _applicantsByStatus[status] ?? [];
                return _buildApplicantList(applicants, status);
              }).toList(),
            ),
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            '지원자 정보를 불러오는 중...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF2D3748),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: _statusList.map((status) {
          final count = _applicantsByStatus[status]?.length ?? 0;
          return Tab(
            text: '${_statusNames[status]} ($count)',
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApplicantList(List<JobApplicant> applicants, String status) {
    if (applicants.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      color: const Color(0xFF2D3748),
      onRefresh: _loadApplicants,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applicants.length,
        itemBuilder: (context, index) {
          return _buildApplicantCard(applicants[index]);
        },
      ),
    );
  }

  Widget _buildApplicantCard(JobApplicant applicant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showApplicantDetail(applicant),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3748).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF2D3748),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        applicant.contact,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(applicant.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(applicant.status).withOpacity(0.3)),
                  ),
                  child: Text(
                    _getStatusText(applicant.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(applicant.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getClimateScoreColor(applicant.climateScore).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco,
                        size: 14,
                        color: _getClimateScoreColor(applicant.climateScore),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '기후점수 ${applicant.climateScore}점',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getClimateScoreColor(applicant.climateScore),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${applicant.daysSinceApplied}일 전 지원',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showApplicantDetail(applicant),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2D3748)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      '상세보기',
                      style: TextStyle(color: Color(0xFF2D3748), fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showStatusChangeDialog(applicant),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: applicant.status == 'HIRED' || applicant.status == 'REJECTED'
                          ? Colors.orange
                          : const Color(0xFF2D3748),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      applicant.status == 'HIRED' || applicant.status == 'REJECTED'
                          ? '재검토'
                          : '상태변경',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '${_statusNames[status]} 지원자가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            status == 'ALL'
                ? '아직 지원한 사람이 없습니다'
                : '해당 상태의 지원자가 없습니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
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
        return '승인';
      case 'REJECTED':
        return '거절';
      default:
        return '알 수 없음';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
      case 'APPLIED':
        return const Color(0xFFFF9800);
      case 'REVIEWING':
        return const Color(0xFF2196F3);
      case 'INTERVIEW':
        return const Color(0xFF9C27B0);
      case 'HIRED':
      case 'APPROVED':
        return const Color(0xFF4CAF50);
      case 'REJECTED':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  Color _getClimateScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  void _showApplicantDetail(JobApplicant applicant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicantDetailSheet(
        applicant: applicant,
        onStatusChanged: (String newStatus) {
          _updateApplicantStatus(applicant.id, newStatus);
          _showSuccessMessage('${applicant.name}님의 상태가 변경되었습니다');
        },
      ),
    );
  }

  void _showStatusChangeDialog(JobApplicant applicant) {
    showDialog(
      context: context,
      builder: (context) => StatusChangeDialog(
        applicant: applicant,
        onStatusChanged: (String newStatus) {
          _updateApplicantStatus(applicant.id, newStatus);
          _showSuccessMessage('${applicant.name}님의 상태가 변경되었습니다');
        },
      ),
    );
  }
}

/// 지원자 상세 정보 바텀시트
class ApplicantDetailSheet extends StatefulWidget {
  final JobApplicant applicant;
  final Function(String) onStatusChanged;

  const ApplicantDetailSheet({
    Key? key,
    required this.applicant,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  State<ApplicantDetailSheet> createState() => _ApplicantDetailSheetState();
}

class _ApplicantDetailSheetState extends State<ApplicantDetailSheet> {
  ApplicantDetail? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplicantDetail();
  }

  Future<void> _loadApplicantDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApplicantManagementService.getApplicationDetail(widget.applicant.id);

      if (result['success']) {
        setState(() {
          _detail = result['data'];
        });
      } else {
        _showErrorMessage(result['error']);
      }
    } catch (e) {
      _showErrorMessage('상세 정보를 불러오는데 실패했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2D3748),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.applicant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_getStatusText(widget.applicant.status)} • ${widget.applicant.daysSinceApplied}일 전 지원',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
              ),
            )
                : _detail != null
                ? _buildDetailContent()
                : _buildErrorState(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent() {
    if (_detail == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            '기본 정보',
            Icons.person_outline,
            [
              _buildInfoRow('이름', _detail!.name),
              _buildInfoRow('생년월일', '${_detail!.birthDate} (${_detail!.age}세)'),
              _buildInfoRow('연락처', _detail!.contact),
              _buildInfoRow('주소', _detail!.address),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            '기후 적응 점수',
            Icons.eco,
            [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getClimateScoreColor(_detail!.climateScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getClimateScoreColor(_detail!.climateScore).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.eco,
                      color: _getClimateScoreColor(_detail!.climateScore),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_detail!.climateScore}점',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getClimateScoreColor(_detail!.climateScore),
                            ),
                          ),
                          Text(
                            _getClimateScoreDescription(_detail!.climateScore),
                            style: TextStyle(
                              fontSize: 14,
                              color: _getClimateScoreColor(_detail!.climateScore),
                            ),
                          ),
                        ],
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  _detail!.experience.isNotEmpty
                      ? _detail!.experience
                      : '경험 정보가 없습니다.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.applicant.status != 'HIRED' && widget.applicant.status != 'REJECTED')
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
            Icon(icon, color: const Color(0xFF2D3748), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _updateStatus('REJECTED'),
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
                onPressed: () => _updateStatus('INTERVIEW'),
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
                onPressed: () => _updateStatus('HIRED'),
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
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '상세 정보를 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadApplicantDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3748),
            ),
            child: const Text(
              '다시 시도',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '검토 대기';
      case 'REVIEWING':
        return '검토 중';
      case 'INTERVIEW':
        return '면접 요청';
      case 'HIRED':
        return '승인';
      case 'REJECTED':
        return '거절';
      default:
        return '알 수 없음';
    }
  }

  Color _getClimateScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String _getClimateScoreDescription(int score) {
    if (score >= 80) return '제주 기후에 매우 적합';
    if (score >= 60) return '제주 기후에 적합';
    return '제주 기후 적응 필요';
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      final result = await ApplicantManagementService.updateApplicationStatus(
        widget.applicant.id,
        newStatus,
      );

      if (result['success']) {
        widget.onStatusChanged(newStatus);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '상태가 변경되었습니다'),
            backgroundColor: const Color(0xFF2D3748),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showErrorMessage(result['error']);
      }
    } catch (e) {
      _showErrorMessage('상태 변경에 실패했습니다: $e');
    }
  }
}

/// 상태 변경 다이얼로그
class StatusChangeDialog extends StatelessWidget {
  final JobApplicant applicant;
  final Function(String) onStatusChanged;

  const StatusChangeDialog({
    Key? key,
    required this.applicant,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '${applicant.name}님 상태 변경',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '현재 상태: ${_getStatusText(applicant.status)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '변경할 상태를 선택해주세요',
            style: TextStyle(fontSize: 14),
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
        TextButton(
          onPressed: () => _updateStatus(context, 'REJECTED'),
          child: const Text(
            '거절',
            style: TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: () => _updateStatus(context, 'INTERVIEW'),
          child: const Text(
            '면접요청',
            style: TextStyle(color: Color(0xFF9C27B0)),
          ),
        ),
        ElevatedButton(
          onPressed: () => _updateStatus(context, 'HIRED'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
          ),
          child: const Text(
            '승인',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '검토 대기';
      case 'REVIEWING':
        return '검토 중';
      case 'INTERVIEW':
        return '면접 요청';
      case 'HIRED':
        return '승인';
      case 'REJECTED':
        return '거절';
      default:
        return '알 수 없음';
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('상태 변경에 실패했습니다: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}