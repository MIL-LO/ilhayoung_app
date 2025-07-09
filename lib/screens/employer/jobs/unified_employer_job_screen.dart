// lib/screens/employer/jobs/unified_employer_job_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/common/unified_app_header.dart';
import '../../../providers/employer_job_provider.dart';
import 'job_management_screen.dart' hide JobPosting;

class UnifiedEmployerJobScreen extends ConsumerStatefulWidget {
  final int initialTab; // 0: 전체 공고, 1: 내 공고

  const UnifiedEmployerJobScreen({
    Key? key,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  ConsumerState<UnifiedEmployerJobScreen> createState() => _UnifiedEmployerJobScreenState();
}

class _UnifiedEmployerJobScreenState extends ConsumerState<UnifiedEmployerJobScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTabs();
    _loadInitialData();
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

  void _loadInitialData() {
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobProvider.notifier).loadInitialData();
    });
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
    final jobState = ref.watch(jobProvider);
    final filter = ref.watch(jobFilterProvider);
    final allJobs = ref.read(jobProvider.notifier).filteredAllJobs;

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
            _buildTabBar(allJobs.length, jobState.myJobs.length),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllJobsTab(jobState, allJobs),
                  _buildMyJobsTab(jobState),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildTabBar(int allJobsCount, int myJobsCount) {
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
            text: '전체 공고 ($allJobsCount)',
          ),
          Tab(
            icon: const Icon(Icons.work, size: 20),
            text: '내 공고 ($myJobsCount)',
          ),
        ],
      ),
    );
  }

  Widget _buildAllJobsTab(JobState jobState, List<JobPosting> allJobs) {
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(jobProvider.notifier).loadAllJobs(refresh: true);
            },
            color: const Color(0xFF2D3748),
            child: _buildJobList(allJobs, jobState.isLoading, isAllJobsTab: true),
          ),
        ),
      ],
    );
  }

  Widget _buildMyJobsTab(JobState jobState) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(jobProvider.notifier).loadMyJobs(refresh: true);
      },
      color: const Color(0xFF2D3748),
      child: Column(
        children: [
          _buildMyJobsStats(jobState.myJobs),
          Expanded(
            child: _buildJobList(jobState.myJobs, jobState.isLoading, isAllJobsTab: false),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    final filter = ref.watch(jobFilterProvider);
    final locations = ref.watch(locationsProvider);
    final categories = ref.watch(categoriesProvider);

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
              ref.read(jobFilterProvider.notifier).updateSearchQuery(value);
              // 검색어 변경시 전체 공고 다시 로드
              ref.read(jobProvider.notifier).loadAllJobs();
            },
          ),
          const SizedBox(height: 12),
          // 필터
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: '지역',
                  value: filter.location,
                  items: locations,
                  onChanged: (value) {
                    ref.read(jobFilterProvider.notifier).updateLocation(value!);
                    ref.read(jobProvider.notifier).loadAllJobs();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  label: '직무',
                  value: filter.category,
                  items: categories,
                  onChanged: (value) {
                    ref.read(jobFilterProvider.notifier).updateCategory(value!);
                    ref.read(jobProvider.notifier).loadAllJobs();
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

  Widget _buildMyJobsStats(List<JobPosting> myJobs) {
    final activeJobs = myJobs.where((job) => job.isActive).length;
    final totalApplicants = myJobs.fold<int>(0, (sum, job) => sum + job.applicantCount);
    final totalViews = myJobs.fold<int>(0, (sum, job) => sum + job.viewCount);

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

  Widget _buildJobList(List<JobPosting> jobs, bool isLoading, {required bool isAllJobsTab}) {
    if (isLoading && jobs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2D3748),
        ),
      );
    }

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

  Widget _buildJobCard(JobPosting job, {required bool isAllJobsTab}) {
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
                        if (job.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (job.isMyJob) ...[
                          const SizedBox(width: 4),
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
              if (job.isUrgent)
                _buildJobInfo(Icons.warning, '마감임박', isUrgent: true)
              else
                _buildJobInfo(Icons.access_time, '${job.daysUntilDeadline}일'),
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

  Widget _buildJobInfo(IconData icon, String text, {bool isUrgent = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: isUrgent ? Colors.red : Colors.grey[600],
        ),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: isUrgent ? Colors.red : Colors.grey[600],
            fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isAllJobsTab) {
    final jobState = ref.watch(jobProvider);

    if (jobState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              '데이터를 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              jobState.error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (isAllJobsTab) {
                  ref.read(jobProvider.notifier).loadAllJobs(refresh: true);
                } else {
                  ref.read(jobProvider.notifier).loadMyJobs(refresh: true);
                }
              },
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

  void _editJob(JobPosting job) {
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

  void _viewApplicants(JobPosting job) {
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
      ref.read(jobProvider.notifier).loadInitialData();
    });
  }
}