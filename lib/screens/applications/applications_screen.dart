import 'package:flutter/material.dart';

// 컴포넌트 imports
import '../../../components/common/unified_app_header.dart';
import '../../../components/applications/application_card.dart';
import '../../../models/application_status.dart';
import '../../../services/mock_application_service.dart';

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

  List<JobApplication> _allApplications = [];
  List<JobApplication> _filteredApplications = [];
  ApplicationStatus? _selectedStatus = ApplicationStatus.closed; // 첫 번째 탭을 기본으로
  Map<ApplicationStatus, int> _statusCounts = {};

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

  void _loadApplications() {
    final applications = MockApplicationService.instance.generateApplications(count: 12);
    final sortedApplications = MockApplicationService.instance.sortByDate(applications);

    setState(() {
      _allApplications = sortedApplications;
      _statusCounts = MockApplicationService.instance.getStatusCounts(applications);
      // 기본으로 첫 번째 상태 필터링
      _filteredApplications = MockApplicationService.instance.filterByStatus(
        _allApplications,
        _selectedStatus
      );
    });
  }

  void _filterByStatus(ApplicationStatus? status) {
    setState(() {
      _selectedStatus = status;
      _filteredApplications = MockApplicationService.instance.filterByStatus(
        _allApplications,
        status
      );
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
      backgroundColor: const Color(0xFFF8FFFE), // 밝은 민트색 배경
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
            icon: const Icon(Icons.filter_list, color: Color(0xFF00A3A3), size: 20),
            onPressed: _showFilterDialog,
            tooltip: '필터',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 상태 필터 탭
            _buildStatusTabs(),

            // 지원내역 리스트
            Expanded(
              child: _buildApplicationsList(),
            ),
          ],
        ),
      ),
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
      child: Row(
        children: ApplicationStatus.values.map((status) {
          return Expanded(
            child: _buildStatusTab(
              status,
              status == ApplicationStatus.closed ? '마감' :
              status == ApplicationStatus.offer ? '제안' :
              status == ApplicationStatus.interview ? '면접' : '확정',
              _statusCounts[status] ?? 0,
              _getStatusColor(status),
            ),
          );
        }).toList(),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _loadApplications();
      },
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
                // 공고 탭으로 이동
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
      height: MediaQuery.of(context).size.height * 0.7,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    application.statusIcon,
                    color: application.statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
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
                      ),
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
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 상세 내용은 추후 구현
          const Expanded(
            child: Center(
              child: Text('상세 정보 준비 중...'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(JobApplication application) {
    switch (application.status) {
      case ApplicationStatus.offer:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('채용 제안을 확인하는 기능 준비 중입니다'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        break;
      case ApplicationStatus.interview:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('면접 일정을 확인하는 기능 준비 중입니다'),
            backgroundColor: Color(0xFFFF6B35),
          ),
        );
        break;
      case ApplicationStatus.hired:
      case ApplicationStatus.closed:
      default:
        break;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.filter_list, color: Color(0xFF00A3A3)),
            SizedBox(width: 8),
            Text(
              '필터',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A3A3),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(ApplicationStatus.hired, '채용 확정', const Color(0xFF00A3A3)),
            _buildFilterOption(ApplicationStatus.offer, '채용 제안', const Color(0xFF4CAF50)),
            _buildFilterOption(ApplicationStatus.interview, '면접 요청', const Color(0xFFFF6B35)),
            _buildFilterOption(ApplicationStatus.closed, '마감', Colors.grey[600]!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '닫기',
              style: TextStyle(color: Color(0xFF00A3A3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(ApplicationStatus status, String label, Color color) {
    final isSelected = _selectedStatus == status;
    final count = _statusCounts[status] ?? 0;

    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(label),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
      selected: isSelected,
      selectedTileColor: color.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        _filterByStatus(status);
      },
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.closed:
        return Colors.grey[600]!;
      case ApplicationStatus.offer:
        return const Color(0xFF4CAF50);
      case ApplicationStatus.interview:
        return const Color(0xFFFF6B35);
      case ApplicationStatus.hired:
        return const Color(0xFF00A3A3);
    }
  }
}