// lib/screens/employer/jobs/unified_employer_job_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/common/unified_app_header.dart';
import 'job_management_screen.dart';

// 공고 상태 enum
enum JobStatus { active, closed }

// 공고 데이터 모델
class AllJobPosting {
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
  final bool isMyJob;

  AllJobPosting({
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
    this.isMyJob = false,
  });
}

class UnifiedEmployerJobScreen extends StatefulWidget {
  final int initialTab; // 0: 전체 공고, 1: 내 공고

  const UnifiedEmployerJobScreen({
    Key? key,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  State<UnifiedEmployerJobScreen> createState() => _UnifiedEmployerJobScreenState();
}

class _UnifiedEmployerJobScreenState extends State<UnifiedEmployerJobScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  // 필터 상태
  String _selectedRegion = '전체';
  String _selectedPosition = '전체';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // 공고 리스트
  List<AllJobPosting> _allJobs = [];
  List<AllJobPosting> _myJobs = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTabs();
    _loadAllJobs();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _fadeController.forward();
  }

  void _setupTabs() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  void _loadAllJobs() {
    _allJobs = [
      // 내 공고들
      AllJobPosting(
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
        isMyJob: true,
      ),
      AllJobPosting(
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
        isMyJob: true,
      ),

      // 다른 업체 공고들
      AllJobPosting(
        id: '3',
        title: '제주흑돼지집 주방 보조 모집',
        company: '제주흑돼지집',
        status: JobStatus.active,
        position: '주방',
        salary: '시급 13,000원',
        workTime: '17:00 - 01:00',
        location: '제주시 노형동',
        applicantCount: 25,
        viewCount: 234,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        deadline: DateTime.now().add(const Duration(days: 20)),
        isMyJob: false,
      ),
      AllJobPosting(
        id: '4',
        title: '제주공항 면세점 판매직 모집',
        company: '제주공항면세점',
        status: JobStatus.active,
        position: '판매',
        salary: '시급 11,500원',
        workTime: '08:00 - 20:00',
        location: '제주시 공항로',
        applicantCount: 45,
        viewCount: 523,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        deadline: DateTime.now().add(const Duration(days: 25)),
        isMyJob: false,
      ),
      AllJobPosting(
        id: '5',
        title: '성산일출봉 관광안내소 직원 모집',
        company: '성산일출봉관리사무소',
        status: JobStatus.active,
        position: '관광안내',
        salary: '일급 80,000원',
        workTime: '06:00 - 18:00',
        location: '서귀포시 성산읍',
        applicantCount: 18,
        viewCount: 167,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        deadline: DateTime.now().add(const Duration(days: 30)),
        isMyJob: false,
      ),
      AllJobPosting(
        id: '6',
        title: '제주올레길 카페 바리스타 모집',
        company: '올레카페',
        status: JobStatus.active,
        position: '바리스타',
        salary: '시급 12,500원',
        workTime: '07:00 - 19:00',
        location: '서귀포시 표선면',
        applicantCount: 33,
        viewCount: 298,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        deadline: DateTime.now().add(const Duration(days: 18)),
        isMyJob: false,
      ),
      AllJobPosting(
        id: '7',
        title: '중문관광단지 리조트 청소 직원',
        company: '중문리조트',
        status: JobStatus.active,
        position: '청소',
        salary: '시급 10,500원',
        workTime: '09:00 - 17:00',
        location: '서귀포시 중문',
        applicantCount: 12,
        viewCount: 87,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        deadline: DateTime.now().add(const Duration(days: 12)),
        isMyJob: false,
      ),
    ];

    _myJobs = _allJobs.where((job) => job.isMyJob).toList();
    setState(() {});
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '공고',
        subtitle: '시장 동향을 파악하고 내 공고를 관리하세요',
        emoji: '🔍',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
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
      floatingActionButton: _buildFloatingActionButton(),
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
        tabs: [
          Tab(
            icon: const Icon(Icons.public, size: 20),
            text: '전체 공고 (${_getFilteredAllJobs().length})',
          ),
          Tab(
            icon: const Icon(Icons.work, size: 20),
            text: '내 공고 (${_myJobs.length})',
          ),
        ],
      ),
    );
  }

  Widget _buildAllJobsTab() {
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              _loadAllJobs();
            },
            color: const Color(0xFF2D3748),
            child: _buildJobList(_getFilteredAllJobs(), isAllJobsTab: true),
          ),
        ),
      ],
    );
  }

  Widget _buildMyJobsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _loadAllJobs();
      },
      color: const Color(0xFF2D3748),
      child: Column(
        children: [
          _buildMyJobsStats(),
          Expanded(
            child: _buildJobList(_myJobs, isAllJobsTab: false),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        children: [
          // 검색바
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '공고 제목이나 회사명으로 검색',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2D3748)),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // 필터
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: '지역',
                  value: _selectedRegion,
                  items: const ['전체', '제주시', '서귀포시'],
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  label: '직무',
                  value: _selectedPosition,
                  items: const ['전체', '서빙', '주방', '판매', '청소', '바리스타', '관광안내', '프론트데스크'],
                  onChanged: (value) {
                    setState(() {
                      _selectedPosition = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13, color: Colors.black),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMyJobsStats() {
    final activeJobs = _myJobs.where((job) => job.status == JobStatus.active).length;
    final totalApplicants = _myJobs.fold(0, (sum, job) => sum + job.applicantCount);
    final totalViews = _myJobs.fold(0, (sum, job) => sum + job.viewCount);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('활성 공고', '${activeJobs}개', Icons.trending_up)),
          Expanded(child: _buildStatItem('총 지원자', '${totalApplicants}명', Icons.people)),
          Expanded(child: _buildStatItem('총 조회수', '${totalViews}회', Icons.visibility)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildJobList(List<AllJobPosting> jobs, {required bool isAllJobsTab}) {
    if (jobs.isEmpty) {
      return _buildEmptyState(isAllJobsTab);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return _buildJobCard(jobs[index], isAllJobsTab: isAllJobsTab);
      },
    );
  }

  Widget _buildJobCard(AllJobPosting job, {required bool isAllJobsTab}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: job.isMyJob
              ? const Color(0xFF2D3748).withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (job.isMyJob)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D3748),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '내 공고',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${job.company} • ${job.position}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${job.salary} • ${job.workTime}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                job.location,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              _buildJobInfo(Icons.people, '${job.applicantCount}명'),
              const SizedBox(width: 12),
              _buildJobInfo(Icons.visibility, '${job.viewCount}회'),
              const SizedBox(width: 12),
              _buildJobInfo(Icons.access_time, '${_getDaysLeft(job.deadline)}일'),
            ],
          ),
          if (job.isMyJob && !isAllJobsTab) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editJob(job),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2D3748)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      '수정',
                      style: TextStyle(color: Color(0xFF2D3748), fontSize: 12),
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      '지원자 보기',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isAllJobsTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAllJobsTab ? Icons.search_off : Icons.work_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isAllJobsTab ? '검색 결과가 없습니다' : '등록된 공고가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAllJobsTab
                ? '다른 검색 조건을 시도해보세요'
                : '공고를 등록해서 인재를 찾아보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreateJob,
      backgroundColor: const Color(0xFF2D3748),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        '공고 작성',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 헬퍼 메서드들
  List<AllJobPosting> _getFilteredAllJobs() {
    return _allJobs.where((job) {
      // 검색어 필터
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!job.title.toLowerCase().contains(query) &&
            !job.company.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 지역 필터
      if (_selectedRegion != '전체') {
        if (!job.location.contains(_selectedRegion)) {
          return false;
        }
      }

      // 직무 필터
      if (_selectedPosition != '전체') {
        if (job.position != _selectedPosition) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int _getDaysLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  void _editJob(AllJobPosting job) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${job.title} 수정 기능 준비 중입니다'),
        backgroundColor: const Color(0xFF2D3748),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _viewApplicants(AllJobPosting job) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                  const Icon(Icons.people, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '총 ${job.applicantCount}명이 지원했습니다',
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.engineering,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '지원자 관리 기능 준비 중입니다',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '곧 지원자 목록과 이력서를 확인할 수 있습니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateJob() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JobManagementScreen(),
      ),
    ).then((_) {
      // 공고 작성 후 돌아왔을 때 데이터 새로고침
      _loadAllJobs();
    });
  }
}