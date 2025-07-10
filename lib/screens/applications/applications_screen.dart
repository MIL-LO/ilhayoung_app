// lib/screens/worker/applications/applications_screen.dart - 메인 화면만

import 'package:flutter/material.dart';
import 'dart:async';

// API 서비스 및 모델 imports
import '../../../services/application_api_service.dart';
import '../../../models/application_model.dart';

// 컴포넌트 imports
import '../../../components/applications/application_card.dart';
import '../../../components/applications/application_status_tabs.dart';
import '../../../components/applications/application_detail_sheet.dart';

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
        // 상태 탭 컴포넌트
        ApplicationStatusTabs(
          allApplications: _allApplications,
          statusCounts: _statusCounts,
          selectedStatus: _selectedStatus,
          onStatusChanged: _filterByStatus,
        ),

        // 지원내역 리스트
        Expanded(
          child: _buildApplicationsList(),
        ),
      ],
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
          return ApplicationCard(
            application: application,
            onTap: () => _showApplicationDetail(application),
            onActionTap: () => _handleAction(application),
          );
        },
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

  // 데이터 로딩 및 필터링 메서드
  Future<void> _loadApplications({bool isRefresh = false}) async {
    setState(() {
      _isLoading = !isRefresh;
      _errorMessage = null;
    });

    try {
      final result = await ApplicationApiService.getMyApplications(
        page: 0,
        size: 100,
        status: _selectedStatus?.apiValue,
      );

      if (result['success']) {
        final List<JobApplication> applications = result['data'];

        setState(() {
          _allApplications = applications;
          _statusCounts = _calculateStatusCounts(applications);
          _filteredApplications = _filterApplicationsByStatus(applications, _selectedStatus);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['error'] ?? '지원내역을 불러오는데 실패했습니다';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '네트워크 오류가 발생했습니다';
      });
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

  // 이벤트 핸들러들
  void _showApplicationDetail(JobApplication application) {
    ApplicationDetailSheet.show(
      context,
      application: application,
      onRefresh: () => _loadApplications(isRefresh: true),
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