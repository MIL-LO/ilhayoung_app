// lib/screens/worker/applications/applications_screen.dart - API 연동된 지원내역

import 'package:flutter/material.dart';
import 'dart:async';

// API 서비스 import
import '../../../services/application_api_service.dart';
import '../../../models/application_model.dart';

// 컴포넌트 imports
import '../../../components/common/unified_app_header.dart';

class ApplicationsScreen extends StatefulWidget {
  final Function? onLogout;

  const ApplicationsScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 데이터 상태
  List<JobApplication> _allApplications = [];
  List<JobApplication> _filteredApplications = [];
  ApplicationStatus? _selectedStatus;
  Map<ApplicationStatus, int> _statusCounts = {};

  // 로딩 상태
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadApplications();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  Future<void> _loadApplications({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      print('=== 지원내역 조회 시작 ===');

      final result = await ApplicationApiService.getMyApplications(
        page: 0,
        size: 100, // 모든 지원내역 조회
        status: _selectedStatus?.name,
      );

      if (result['success']) {
        final List<JobApplication> applications = result['data'];

        setState(() {
          _allApplications = applications;
          _statusCounts = _calculateStatusCounts(applications);
          _filteredApplications = _filterApplicationsByStatus(applications, _selectedStatus);
          _isLoading = false;
          _isRefreshing = false;
        });

        print('✅ 지원내역 ${applications.length}개 조회 완료');
      } else {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = result['error'] ?? '지원내역을 불러오는데 실패했습니다';
        });
        print('❌ 지원내역 조회 실패: ${result['error']}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = '네트워크 오류가 발생했습니다';
      });
      print('❌ 지원내역 조회 예외: $e');
    }
  }

  Map<ApplicationStatus, int> _calculateStatusCounts(List<JobApplication> applications) {
    final counts = <ApplicationStatus, int>{};

    for (final status in ApplicationStatus.values) {
      counts[status] = applications.where((app) => app.status == status).length;
    }

    return counts;
  }

  List<JobApplication> _filterApplicationsByStatus(
      List<JobApplication> applications,
      ApplicationStatus? status,
      ) {
    if (status == null) return applications;
    return applications.where((app) => app.status == status).toList();
  }

  void _filterByStatus(ApplicationStatus? status) {
    setState(() {
      _selectedStatus = status;
      _filteredApplications = _filterApplicationsByStatus(_allApplications, status);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text('📝 ', style: TextStyle(fontSize: 20)),
            Text(
              '지원 내역',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              '내가 지원한 공고들을 확인하세요',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00A3A3), size: 20),
            onPressed: () => _loadApplications(isRefresh: true),
            tooltip: '새로고침',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A3A3)),
            ),
            SizedBox(height: 16),
            Text(
              '지원내역을 불러오는 중...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF00A3A3),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
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
              onPressed: () => _loadApplications(),
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

    return Column(
      children: [
        _buildStatusTabs(),
        Expanded(
          child: _buildApplicationsList(),
        ),
      ],
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusTab(null, '전체', _allApplications.length, const Color(0xFF00A3A3)),
            ...ApplicationStatus.values.map((status) {
              return _buildStatusTab(
                status,
                status.displayName,
                _statusCounts[status] ?? 0,
                status.color,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(ApplicationStatus? status, String label, int count, Color color) {
    final isSelected = _selectedStatus == status;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _filterByStatus(status),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? color : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsList() {
    if (_filteredApplications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadApplications(isRefresh: true),
      color: const Color(0xFF00A3A3),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredApplications.length,
        itemBuilder: (context, index) {
          final application = _filteredApplications[index];
          return _buildApplicationCard(application);
        },
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
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
        onTap: () => _showApplicationDetail(application),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 상태와 날짜
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: application.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        application.statusIcon,
                        size: 14,
                        color: application.statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        application.statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: application.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  application.formattedAppliedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 회사명과 직무
            Text(
              application.company,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              application.jobTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // 급여와 위치
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A3A3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    application.formattedSalary,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00A3A3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    application.companyLocation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // 액션 버튼 (필요한 경우)
            if (application.hasAction) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _handleAction(application),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: application.statusColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    application.actionText,
                    style: TextStyle(
                      color: application.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _selectedStatus != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.filter_list_off : Icons.description_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? '해당 상태의 지원내역이 없어요' : '아직 지원한 공고가 없어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered ? '다른 상태를 확인해보세요' : '관심있는 공고에 지원해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (!isFiltered) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: 공고 탭으로 이동 기능 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('공고 탭으로 이동합니다'),
                    backgroundColor: Color(0xFF00A3A3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A3A3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('공고 보러가기'),
            ),
          ],
        ],
      ),
    );
  }

  // 이벤트 핸들러들
  void _showApplicationDetail(JobApplication application) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildDetailBottomSheet(application),
    );
  }

  Widget _buildDetailBottomSheet(JobApplication application) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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

          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: application.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    application.statusIcon,
                    color: application.statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.jobTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.company,
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

          // 상세 정보
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('지원 정보', [
                    _buildDetailItem('지원일', application.formattedAppliedDate),
                    _buildDetailItem('상태', application.statusText),
                    if (application.message != null)
                      _buildDetailItem('메시지', application.message!),
                  ]),

                  _buildDetailSection('공고 정보', [
                    _buildDetailItem('회사명', application.company),
                    _buildDetailItem('직무', application.jobTitle),
                    _buildDetailItem('급여', application.formattedSalary),
                    _buildDetailItem('위치', application.companyLocation),
                  ]),

                  if (application.status == ApplicationStatus.interview && application.interviewDate != null)
                    _buildDetailSection('면접 정보', [
                      _buildDetailItem('면접 일정', application.interviewDate!),
                    ]),

                  if (application.status == ApplicationStatus.offer && application.offerDetails != null)
                    _buildDetailSection('제안 정보', [
                      _buildDetailItem('제안 내용', application.offerDetails!),
                    ]),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 액션 버튼
          if (application.hasAction)
            Container(
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
                      _handleAction(application);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: application.statusColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      application.actionText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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

  Future<void> _handleAction(JobApplication application) async {
    switch (application.status) {
      case ApplicationStatus.interview:
        _showSnackBar('면접 일정 확인 기능은 준비 중입니다', Colors.purple[600]!);
        break;
      case ApplicationStatus.offer:
        _showSnackBar('제안 확인 기능은 준비 중입니다', Colors.green[600]!);
        break;
      case ApplicationStatus.pending:
      case ApplicationStatus.reviewing:
        _showCancelDialog(application);
        break;
      default:
        break;
    }
  }

  void _showCancelDialog(JobApplication application) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지원 취소'),
        content: Text('${application.jobTitle} 공고에 대한 지원을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelApplication(application);
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

  Future<void> _cancelApplication(JobApplication application) async {
    try {
      _showSnackBar('지원을 취소하는 중...', Colors.orange[600]!);

      final result = await ApplicationApiService.cancelApplication(application.id);

      if (result['success']) {
        _showSnackBar(result['message'] ?? '지원이 취소되었습니다', Colors.green[600]!);
        // 목록 새로고침
        _loadApplications(isRefresh: true);
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

// ApplicationStatus 확장
extension ApplicationStatusExtension on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return '대기중';
      case ApplicationStatus.reviewing:
        return '검토중';
      case ApplicationStatus.interview:
        return '면접';
      case ApplicationStatus.offer:
        return '제안';
      case ApplicationStatus.hired:
        return '채용확정';
      case ApplicationStatus.rejected:
        return '거절됨';
      case ApplicationStatus.cancelled:
        return '취소됨';
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.pending:
        return Colors.orange[600]!;
      case ApplicationStatus.reviewing:
        return Colors.blue[600]!;
      case ApplicationStatus.interview:
        return Colors.purple[600]!;
      case ApplicationStatus.offer:
        return Colors.green[600]!;
      case ApplicationStatus.hired:
        return const Color(0xFF00A3A3);
      case ApplicationStatus.rejected:
        return Colors.red[600]!;
      case ApplicationStatus.cancelled:
        return Colors.grey[600]!;
    }
  }
}