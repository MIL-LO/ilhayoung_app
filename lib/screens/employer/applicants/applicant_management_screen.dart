// lib/screens/employer/applicants/applicant_management_screen.dart - 상세보기 수정 버전

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/applicant_management_service.dart';
import '../../../models/job_posting_model.dart';
// ApplicantDetailSheet import 제거 - 직접 구현

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

  // 데이터 상태
  List<JobApplicant> _allApplicants = [];
  Map<String, List<JobApplicant>> _applicantsByStatus = {};
  bool _isLoading = true;
  bool _isUpdating = false;

  final List<String> _statusList = ['ALL', 'PENDING', 'REVIEWING', 'INTERVIEW', 'HIRED', 'REJECTED'];
  final Map<String, String> _statusNames = {
    'ALL': '전체',
    'PENDING': '검토 대기',
    'REVIEWING': '검토 중',
    'INTERVIEW': '면접 요청',
    'HIRED': '승인',
    'REJECTED': '거절',
  };

  final Map<String, IconData> _statusIcons = {
    'ALL': Icons.people,
    'PENDING': Icons.schedule,
    'REVIEWING': Icons.rate_review,
    'INTERVIEW': Icons.video_call,
    'HIRED': Icons.check_circle,
    'REJECTED': Icons.cancel,
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

  // === 데이터 로딩 및 상태 관리 ===
  Future<void> _loadApplicants() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApplicantManagementService.getJobApplicants(widget.jobPosting.id);

      if (!mounted) return;

      if (result['success']) {
        final List<JobApplicant> applicants = result['data'] ?? [];

        print('=== 지원자 로드 완료 ===');
        print('총 지원자 수: ${applicants.length}');
        for (var applicant in applicants) {
          print('- ${applicant.name}: ${applicant.status}');
        }

        setState(() {
          _allApplicants = applicants;
          _updateApplicantsByStatus();
          _isLoading = false;
        });
      } else {
        _showErrorMessage(result['error'] ?? '지원자 목록을 불러오는데 실패했습니다');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorMessage('네트워크 오류가 발생했습니다: $e');
      setState(() => _isLoading = false);
    }
  }

  void _updateApplicantsByStatus() {
    _applicantsByStatus = {
      'ALL': _allApplicants,
      'PENDING': _allApplicants.where((a) =>
      a.status == 'PENDING' || a.status == 'APPLIED').toList(),
      'REVIEWING': _allApplicants.where((a) =>
      a.status == 'REVIEWING').toList(),
      'INTERVIEW': _allApplicants.where((a) =>
      a.status == 'INTERVIEW').toList(),
      'HIRED': _allApplicants.where((a) =>
      a.status == 'HIRED' || a.status == 'APPROVED').toList(),
      'REJECTED': _allApplicants.where((a) =>
      a.status == 'REJECTED').toList(),
    };

    print('=== 상태별 필터링 결과 ===');
    _applicantsByStatus.forEach((status, applicants) {
      print('$status: ${applicants.length}명');
    });
  }

  // === 상태 변경 메서드 (핵심 수정 부분) ===
  Future<void> _updateApplicantStatus(String applicantId, String newStatus) async {
    if (_isUpdating) return;

    setState(() => _isUpdating = true);

    try {
      print('=== 지원자 상태 변경 시작 ===');
      print('지원자 ID: $applicantId');
      print('새로운 상태: $newStatus');

      // 1. 실제 API 호출로 서버 상태 변경
      final result = await ApplicantManagementService.updateApplicationStatus(
        applicantId,
        newStatus,
      );

      if (!mounted) return;

      if (result['success']) {
        print('✅ 서버 상태 변경 성공');

        // 2. 로컬 상태 업데이트 (새로운 JobApplicant 객체 생성)
        setState(() {
          final applicantIndex = _allApplicants.indexWhere((a) => a.id == applicantId);
          if (applicantIndex != -1) {
            // 기존 지원자 정보를 복사하고 상태만 변경
            final oldApplicant = _allApplicants[applicantIndex];
            _allApplicants[applicantIndex] = JobApplicant(
              id: oldApplicant.id,
              name: oldApplicant.name,
              contact: oldApplicant.contact,
              status: newStatus, // 새로운 상태로 업데이트
              appliedAt: oldApplicant.appliedAt,
              climateScore: oldApplicant.climateScore,
            );

            // 상태별 필터링 다시 실행
            _updateApplicantsByStatus();
          }
        });

        final applicantName = _getApplicantName(applicantId);
        _showSuccessMessage('$applicantName님의 상태가 ${_getStatusText(newStatus)}로 변경되었습니다');

        print('✅ 로컬 상태 업데이트 완료');

      } else {
        _showErrorMessage(result['error'] ?? '상태 변경에 실패했습니다');
      }
    } catch (e) {
      if (!mounted) return;
      print('❌ 상태 변경 실패: $e');
      _showErrorMessage('상태 변경 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  // === UI 빌드 메서드들 ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingWidget()
          : Column(
        children: [
          _buildJobSummaryCard(),
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지원자 관리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            widget.jobPosting.title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: _isUpdating
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.refresh, color: Color(0xFF2D3748)),
          onPressed: _isUpdating ? null : () {
            HapticFeedback.lightImpact();
            _loadApplicants();
          },
        ),
      ],
    );
  }

  Widget _buildJobSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3748).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.work, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.jobPosting.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.jobPosting.companyName} • ${widget.jobPosting.workLocation}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem(
                '총 지원자',
                '${_allApplicants.length}명',
                Icons.people,
                Colors.blue[300]!,
              ),
              const SizedBox(width: 16),
              _buildSummaryItem(
                '승인',
                '${(_applicantsByStatus['HIRED'] ?? []).length}명',
                Icons.check_circle,
                Colors.green[300]!,
              ),
              const SizedBox(width: 16),
              _buildSummaryItem(
                '대기',
                '${(_applicantsByStatus['PENDING'] ?? []).length}명',
                Icons.schedule,
                Colors.orange[300]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
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
          SizedBox(height: 20),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF2D3748),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: _statusList.map((status) {
          final count = _applicantsByStatus[status]?.length ?? 0;
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcons[status], size: 16),
                const SizedBox(width: 8),
                Text('${_statusNames[status]}'),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
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
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showApplicantDetail(applicant),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF2D3748),
                      child: Text(
                        _getApplicantName(applicant.id).isNotEmpty
                            ? _getApplicantName(applicant.id)[0]
                            : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getApplicantName(applicant.id),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            applicant.contact,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(applicant),
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
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showApplicantDetail(applicant),
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('상세보기'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2D3748),
                          side: const BorderSide(color: Color(0xFF2D3748)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (applicant.status != 'HIRED' && applicant.status != 'APPROVED' &&
                        applicant.status != 'REJECTED') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUpdating
                              ? null
                              : () => _showStatusChangeDialog(applicant),
                          icon: _isUpdating
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : const Icon(Icons.edit, size: 16),
                          label: Text(_isUpdating ? '처리중...' : '상태변경'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D3748),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(JobApplicant applicant) {
    final color = _getStatusColor(applicant.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getStatusText(applicant.status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcons[status],
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
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
            _getEmptyStateMessage(status),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage(String status) {
    switch (status) {
      case 'ALL': return '아직 지원한 사람이 없습니다.\n공고를 확인하고 홍보해보세요.';
      case 'PENDING': return '검토 대기 중인 지원자가 없습니다.';
      case 'REVIEWING': return '현재 검토 중인 지원자가 없습니다.';
      case 'INTERVIEW': return '면접 요청한 지원자가 없습니다.';
      case 'HIRED': return '승인된 지원자가 없습니다.';
      case 'REJECTED': return '거절된 지원자가 없습니다.';
      default: return '해당 상태의 지원자가 없습니다.';
    }
  }

  // === 지원자 상세보기 - 직접 구현된 상세 화면 ===
  void _showApplicantDetail(JobApplicant applicant) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildApplicantDetailSheet(applicant),
    );
  }

  Widget _buildApplicantDetailSheet(JobApplicant applicant) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 헤더
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    _getApplicantName(applicant.id).isNotEmpty
                        ? _getApplicantName(applicant.id)[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 18,
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
                        _getApplicantName(applicant.id),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(applicant.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(applicant.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${applicant.daysSinceApplied}일 전 지원',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
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
          // 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(
                    '기본 정보',
                    Icons.person,
                    [
                      _buildDetailRow('이름', _getApplicantName(applicant.id)),
                      _buildDetailRow('연락처', applicant.contact),
                      _buildDetailRow('지원일', _formatAppliedDate(applicant.appliedAt)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    '지원 공고 정보',
                    Icons.work,
                    [
                      _buildDetailRow('공고명', widget.jobPosting.title),
                      _buildDetailRow('회사명', widget.jobPosting.companyName),
                      _buildDetailRow('근무지', widget.jobPosting.workLocation ?? '정보 없음'),
                      _buildDetailRow('급여', widget.jobPosting.salary != null ? '₩${widget.jobPosting.salary}' : '정보 없음'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    '제주도 적응 점수',
                    Icons.eco,
                    [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getClimateScoreColor(applicant.climateScore).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _getClimateScoreColor(applicant.climateScore).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '점수: ${applicant.climateScore}점',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _getClimateScoreColor(applicant.climateScore),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '등급: ${_getClimateScoreLevel(applicant.climateScore)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _getClimateScoreColor(applicant.climateScore),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getClimateScoreColor(applicant.climateScore),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                applicant.climateScore >= 80 ? Icons.emoji_events :
                                applicant.climateScore >= 60 ? Icons.thumb_up : Icons.help_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 액션 버튼들
          _buildDetailActionButtons(applicant),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailActionButtons(JobApplicant applicant) {
    // 이미 승인되었거나 처리된 상태인 경우
    if (applicant.status == 'HIRED' || applicant.status == 'APPROVED') {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              '✅ 승인 완료',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '지원자가 승인되어 근무 스케줄이 자동으로 생성되었습니다.',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // 거절된 상태인 경우
    if (applicant.status == 'REJECTED') {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 12),
            Text(
              '❌ 거절됨',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '지원자가 거절되었습니다.',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isUpdating ? null : () {
                  Navigator.pop(context);
                  _updateApplicantStatus(applicant.id, 'PENDING');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red[600]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  '재검토하기',
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 처리 가능한 상태인 경우 (PENDING, REVIEWING, INTERVIEW 등)
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isUpdating ? null : () {
                    Navigator.pop(context);
                    _updateApplicantStatus(applicant.id, 'REJECTED');
                  },
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
                  onPressed: _isUpdating ? null : () {
                    Navigator.pop(context);
                    _updateApplicantStatus(applicant.id, 'INTERVIEW');
                  },
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
              onPressed: _isUpdating ? null : () {
                Navigator.pop(context);
                _updateApplicantStatus(applicant.id, 'HIRED');
              },
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
              label: Text(_isUpdating ? '처리 중...' : '승인'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getClimateScoreLevel(int score) {
    if (score >= 80) return '우수';
    if (score >= 60) return '보통';
    return '미흡';
  }

  String _formatAppliedDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  // === 간단한 상태 변경 다이얼로그 ===
  void _showStatusChangeDialog(JobApplicant applicant) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${_getApplicantName(applicant.id)}님 상태 변경',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '현재 상태: ${_getStatusText(applicant.status)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),

                  // 상태 변경 옵션들
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateApplicantStatus(applicant.id, 'HIRED');
                      },
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('승인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateApplicantStatus(applicant.id, 'REJECTED');
                      },
                      icon: const Icon(Icons.cancel, size: 20),
                      label: const Text('거절', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateApplicantStatus(applicant.id, 'INTERVIEW');
                      },
                      icon: const Icon(Icons.video_call, size: 20),
                      label: const Text('면접 요청', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9C27B0),
                        side: const BorderSide(color: Color(0xFF9C27B0)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // === 유틸리티 메서드들 ===
  String _getApplicantName(String applicantId) {
    try {
      final applicant = _allApplicants.firstWhere((a) => a.id == applicantId);
      if (applicant.name.isNotEmpty) {
        return applicant.name;
      }
    } catch (e) {
      print('지원자 이름 조회 실패: $e');
    }
    return '지원자';
  }

  Color _getClimateScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
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

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
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

  // === 메시지 표시 메서드들 ===
  void _showErrorMessage(String message) {
    if (mounted) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showInfoMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: const Color(0xFF2196F3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}