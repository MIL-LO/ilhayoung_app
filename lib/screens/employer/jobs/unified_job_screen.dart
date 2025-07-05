// lib/screens/employer/jobs/unified_job_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/common/unified_app_header.dart';
import '../../../components/jobs/job_card.dart';
import '../../../components/jobs/job_banner.dart';
import '../../../components/jobs/filter_bottom_sheet.dart';
import '../../../components/jobs/job_detail_bottom_sheet.dart';
import '../../../models/jeju_job_item.dart';
import '../../../services/mock_data_service.dart';
import 'job_management_screen.dart';

class UnifiedJobScreen extends StatefulWidget {
  final Function? onLogout;

  const UnifiedJobScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<UnifiedJobScreen> createState() => _UnifiedJobScreenState();
}

class _UnifiedJobScreenState extends State<UnifiedJobScreen>
    with TickerProviderStateMixin {

  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 전체 공고 관련
  List<JejuJobItem> _allJobs = [];
  List<JejuJobItem> _displayedJobs = [];
  String _selectedLocation = '제주 전체';
  String _selectedCategory = '전체';
  List<String> _locations = [];
  List<String> _categories = [];
  int _currentPage = 1;
  bool _isLoading = false;

  // 내 공고 관련
  List<JobPosting> _myJobs = [];

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _loadData();
  }

  void _setupControllers() {
    _tabController = TabController(length: 2, vsync: this);

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

  Future<void> _loadData() async {
    try {
      // 전체 공고 데이터 로드
      final results = await Future.wait([
        MockDataService.instance.getLocations(),
        MockDataService.instance.getCategories(),
        MockDataService.instance.generateJobs(count: 100),
      ]);

      setState(() {
        _locations = results[0] as List<String>;
        _categories = results[1] as List<String>;
        _allJobs = results[2] as List<JejuJobItem>;
        _displayedJobs = _allJobs.take(20).toList();
        _currentPage = 1;
      });

      // 내 공고 데이터 로드
      _loadMyJobs();
    } catch (e) {
      _generateFallbackData();
    }
  }

  void _loadMyJobs() {
    // 임시 내 공고 데이터
    _myJobs = [
      JobPosting(
        id: '1',
        title: '제주맛집카페 서빙 직원 모집',
        company: '제주맛집카페',
        status: JobStatus.active,
        position: '서빙',
        salary: '시급 12,000원',
        workTime: '09:00 - 18:00',
        location: '제주시 연동',
        applicantCount: 12,
        viewCount: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        deadline: DateTime.now().add(const Duration(days: 14)),
      ),
      JobPosting(
        id: '2',
        title: '한라산펜션 프론트데스크 직원 모집',
        company: '한라산펜션',
        status: JobStatus.active,
        position: '프론트데스크',
        salary: '월급 2,200,000원',
        workTime: '08:00 - 20:00',
        location: '서귀포시 중문',
        applicantCount: 8,
        viewCount: 156,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        deadline: DateTime.now().add(const Duration(days: 10)),
      ),
      JobPosting(
        id: '3',
        title: '제주감귤농장 수확 알바 모집',
        company: '제주감귤농장',
        status: JobStatus.closed,
        position: '농장작업',
        salary: '시급 15,000원',
        workTime: '06:00 - 15:00',
        location: '제주시 한림읍',
        applicantCount: 25,
        viewCount: 203,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        deadline: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    setState(() {});
  }

  void _generateFallbackData() {
    // Fallback 데이터 (기존 코드와 동일)
    _locations = [
      '제주 전체', '제주시', '서귀포시', '애월읍', '한림읍', '구좌읍', '성산읍', '표선면', '남원읍'
    ];
    _categories = [
      '전체', '카페/음료', '음식점', '숙박업', '관광/레저', '농업', '유통/판매', '서비스업'
    ];

    // 간단한 fallback 공고 생성 로직
    _allJobs = List.generate(50, (index) {
      return JejuJobItem(
        id: (index + 1).toString(),
        title: '테스트 공고 ${index + 1}',
        company: '테스트 회사 ${index + 1}',
        location: '제주시',
        fullAddress: '제주시 연동 123-45',
        salary: '시급 ₩12,000',
        hourlyWage: 12000,
        workType: '아르바이트',
        workSchedule: '09:00 - 18:00',
        isUrgent: index % 7 == 0,
        isNew: index % 10 == 0,
        category: '카페/음료',
        createdAt: DateTime.now().subtract(Duration(days: index % 30)),
        description: '테스트 공고입니다.',
        contactNumber: '064-720-1234',
        representativeName: '테스트',
      );
    });

    setState(() {
      _displayedJobs = _allJobs.take(20).toList();
      _currentPage = 1;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '공고 관리',
        subtitle: '시장 동향을 파악하고 내 공고를 관리하세요',
        emoji: '📋',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2D3748), size: 22),
            onPressed: _showSearchDialog,
            tooltip: '검색',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllJobsTab(),
                  _buildMyJobsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateJob,
        backgroundColor: const Color(0xFF2D3748),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          '공고 작성',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
        indicator: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF2D3748),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.public, size: 20),
            text: '전체 공고',
          ),
          Tab(
            icon: Icon(Icons.business, size: 20),
            text: '내 공고',
          ),
        ],
      ),
    );
  }

  Widget _buildAllJobsTab() {
    return Column(
      children: [
        // 필터 및 배너
        _buildSearchAndFilters(),
        _buildBanner(),

        // 공고 리스트
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshAllJobs,
            color: const Color(0xFF2D3748),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _displayedJobs.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _displayedJobs.length) {
                  return _buildLoadingIndicator();
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: JobCard(
                    job: _displayedJobs[index],
                    onTap: () => _showJobDetail(_displayedJobs[index]),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyJobsTab() {
    if (_myJobs.isEmpty) {
      return _buildEmptyMyJobs();
    }

    final activeJobs = _myJobs.where((job) => job.status == JobStatus.active).toList();
    final closedJobs = _myJobs.where((job) => job.status == JobStatus.closed).toList();

    return RefreshIndicator(
      onRefresh: _refreshMyJobs,
      color: const Color(0xFF2D3748),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 통계 카드
            _buildMyJobsStats(),
            const SizedBox(height: 20),

            // 활성 공고
            if (activeJobs.isNotEmpty) ...[
              _buildSectionHeader('활성 공고', activeJobs.length, Colors.green),
              const SizedBox(height: 12),
              ...activeJobs.map((job) => _buildMyJobCard(job)),
              const SizedBox(height: 20),
            ],

            // 마감된 공고
            if (closedJobs.isNotEmpty) ...[
              _buildSectionHeader('마감된 공고', closedJobs.length, Colors.grey),
              const SizedBox(height: 12),
              ...closedJobs.map((job) => _buildMyJobCard(job)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSelectBox(
              '지역',
              _selectedLocation,
              Icons.location_on,
              const Color(0xFF2D3748),
              _showLocationPicker,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSelectBox(
              '업종',
              _selectedCategory,
              Icons.category,
              const Color(0xFFFF6B35),
              _showCategoryPicker,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectBox(String label, String value, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3748).withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🏢 총 ${_allJobs.length}개의 공고',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '시장 동향을 파악하고 경쟁력을 높이세요!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('📊', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyJobsStats() {
    final totalApplicants = _myJobs.fold(0, (sum, job) => sum + job.applicantCount);
    final totalViews = _myJobs.fold(0, (sum, job) => sum + job.viewCount);
    final activeCount = _myJobs.where((job) => job.status == JobStatus.active).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3748).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                '📊 내 공고 현황',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('총 공고', '${_myJobs.length}개', Icons.work)),
              Expanded(child: _buildStatItem('활성 공고', '${activeCount}개', Icons.trending_up)),
              Expanded(child: _buildStatItem('총 지원자', '${totalApplicants}명', Icons.people)),
              Expanded(child: _buildStatItem('총 조회수', '${totalViews}회', Icons.visibility)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count개',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyJobCard(JobPosting job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: job.status == JobStatus.active
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.position} • ${job.salary}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: job.status == JobStatus.active
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.status == JobStatus.active ? '활성' : '마감',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: job.status == JobStatus.active ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildJobInfo(Icons.people, '${job.applicantCount}명 지원'),
              const SizedBox(width: 16),
              _buildJobInfo(Icons.visibility, '${job.viewCount}회 조회'),
              const SizedBox(width: 16),
              _buildJobInfo(Icons.access_time, '${_getDaysLeft(job.deadline)}일 남음'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _editJob(job),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2D3748)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '수정',
                    style: TextStyle(color: Color(0xFF2D3748)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _viewApplicants(job),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3748),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '지원자 보기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMyJobs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '등록된 공고가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 버튼을 눌러 첫 공고를 작성해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
              strokeWidth: 3,
            ),
            SizedBox(height: 12),
            Text(
              '공고를 불러오는 중... 📋',
              style: TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
            ),
          ],
        ),
      ),
    );
  }

  // 이벤트 핸들러들
  Future<void> _refreshAllJobs() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadData();
  }

  Future<void> _refreshMyJobs() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadMyJobs();
  }

  void _navigateToCreateJob() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JobManagementScreen(),
      ),
    ).then((_) {
      // 공고 작성 후 돌아왔을 때 내 공고 새로고침
      _loadMyJobs();
    });
  }

  void _showLocationPicker() {
    FilterBottomSheet.showLocationPicker(
      context,
      _locations,
      _selectedLocation,
          (location) {
        setState(() {
          _selectedLocation = location;
        });
      },
    );
  }

  void _showCategoryPicker() {
    FilterBottomSheet.showCategoryPicker(
      context,
      _categories,
      _selectedCategory,
          (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  void _showJobDetail(JejuJobItem job) {
    JobDetailBottomSheet.show(context, job);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🔍 공고 검색',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('검색 기능 준비 중입니다 🔍'),
                  backgroundColor: Color(0xFF2D3748),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3748),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '검색',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _editJob(JobPosting job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${job.title} 수정 기능 준비 중입니다'),
        backgroundColor: const Color(0xFF2D3748),
      ),
    );
  }

  void _viewApplicants(JobPosting job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${job.title} 지원자 목록 기능 준비 중입니다'),
        backgroundColor: const Color(0xFF2D3748),
      ),
    );
  }

  int _getDaysLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }
}

// JobPosting 모델 클래스
class JobPosting {
  final String id;
  final String title;
  final String company;
  final JobStatus status;
  final String position;
  final String salary;
  final String workTime;
  final String location;
  final int applicantCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime deadline;

  JobPosting({
    required this.id,
    required this.title,
    required this.company,
    required this.status,
    required this.position,
    required this.salary,
    required this.workTime,
    required this.location,
    required this.applicantCount,
    required this.viewCount,
    required this.createdAt,
    required this.deadline,
  });
}

enum JobStatus {
  active,
  closed,
}