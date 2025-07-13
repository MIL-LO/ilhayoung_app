// lib/screens/employer/jobs/unified_employer_job_screen.dart - UnifiedAppHeader 적용

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/jobs/common_job_list.dart';
import '../../../components/common/jeju_select_box.dart';
import '../../../components/jobs/job_actions_row.dart';
import '../../../components/common/unified_app_header.dart';
import '../../../models/job_posting_model.dart';
import 'job_management_screen.dart';
import 'job_edit_screen.dart';
import '../applicants/applicant_management_screen.dart';

class UnifiedEmployerJobScreen extends StatefulWidget {
  final int initialTab;

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
  String _selectedLocation = '제주 전체';
  String _selectedCategory = '전체';
  String _searchQuery = '';

  // 필터 옵션
  final List<String> _locations = [
    '제주 전체', '제주시', '서귀포시', '애월읍', '한림읍',
    '구좌읍', '성산읍', '표선면', '남원읍'
  ];
  final List<String> _categories = [
    '전체', '카페/음료', '음식점', '숙박업', '관광/레저',
    '농업', '유통/판매', '서비스업'
  ];

  // 새로고침을 위한 상태 변수
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTabs();
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

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Helper 메서드들 - 기존 모델과 호환
  bool _getJobActiveStatus(JobPosting job) {
    try {
      return (job as dynamic).isActive ?? job.deadline.isAfter(DateTime.now());
    } catch (e) {
      return job.deadline.isAfter(DateTime.now());
    }
  }

  int _getApplicantCount(JobPosting job) {
    try {
      return (job as dynamic).applicantCount ?? 0;
    } catch (e) {
      return 0;
    }
  }

  int _getViewCount(JobPosting job) {
    try {
      return (job as dynamic).viewCount ?? 0;
    } catch (e) {
      return 0;
    }
  }

  String _getJobPosition(JobPosting job) {
    try {
      return (job as dynamic).position ?? job.title;
    } catch (e) {
      return job.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '공고 관리',
        subtitle: '사업자님의 채용을 도와드립니다',
        emoji: '🏢',
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 22),
            onPressed: _showSearchDialog,
            tooltip: '검색',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white, size: 22),
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
            _buildTabBar(),
            _buildSearchAndFilters(),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(6),
        ),
        indicatorPadding: const EdgeInsets.all(3),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF2D3748),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.public, size: 18),
            text: '전체 공고',
          ),
          Tab(
            icon: Icon(Icons.business, size: 18),
            text: '내 공고',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    if (_tabController.index != 0) {
      return const SizedBox.shrink();
    }

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
          JejuSelectBox(
            label: '지역',
            value: _selectedLocation,
            icon: Icons.location_on,
            color: const Color(0xFF2D3748),
            onTap: _showLocationPicker,
          ),
          const SizedBox(width: 8),
          JejuSelectBox(
            label: '업종',
            value: _selectedCategory,
            icon: Icons.category,
            color: const Color(0xFF4A5568),
            onTap: _showCategoryPicker,
          ),
        ],
      ),
    );
  }

  Widget _buildAllJobsTab() {
    return CommonJobList(
      key: ValueKey('all_jobs_$_refreshCounter'),
      showMyJobsOnly: false,
      onJobAction: _handleJobAction,
      searchQuery: _searchQuery,
      selectedLocation: _selectedLocation != '제주 전체' ? _selectedLocation : null,
      selectedCategory: _selectedCategory != '전체' ? _selectedCategory : null,
      isEmployerMode: true, // 매니저 모드 활성화
    );
  }

  Widget _buildMyJobsTab() {
    return CommonJobList(
      key: ValueKey('my_jobs_$_refreshCounter'),
      showMyJobsOnly: true,
      onJobAction: _handleJobAction,
      isEmployerMode: true, // 매니저 모드 활성화
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

  void _showLocationPicker() {
    _showPickerBottomSheet(
      title: '🌍 지역 선택',
      items: _locations,
      selectedItem: _selectedLocation,
      onSelected: (location) {
        setState(() {
          _selectedLocation = location;
        });
      },
    );
  }

  void _showCategoryPicker() {
    _showPickerBottomSheet(
      title: '📂 업종 선택',
      items: _categories,
      selectedItem: _selectedCategory,
      onSelected: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  void _showPickerBottomSheet({
    required String title,
    required List<String> items,
    required String selectedItem,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
              decoration: BoxDecoration(
                color: const Color(0xFF2D3748).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF2D3748)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == selectedItem;

                  return ListTile(
                    title: Text(
                      item,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF2D3748) : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF2D3748))
                        : null,
                    onTap: () {
                      onSelected(item);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    String tempSearchQuery = _searchQuery;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🔍 일자리 검색',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        content: TextField(
          controller: TextEditingController(text: tempSearchQuery),
          autofocus: true,
          decoration: InputDecoration(
            hintText: '회사명, 직무 등을 검색하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748), width: 2),
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF2D3748)),
          ),
          onChanged: (value) {
            tempSearchQuery = value;
          },
          onSubmitted: (value) {
            Navigator.pop(context);
            setState(() {
              _searchQuery = value;
            });
          },
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
              setState(() {
                _searchQuery = tempSearchQuery;
              });
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🎯 필터 설정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        content: const Text('상세 필터 기능을 곧 추가할 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: Color(0xFF2D3748)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleJobAction(String action, JobPosting job) {
    switch (action) {
      case 'edit':
        _editJob(job);
        break;
      case 'applicants':
        _viewApplicants(job);
        break;
    }
  }

  void _editJob(JobPosting job) {
    HapticFeedback.lightImpact();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobEditScreen(jobPosting: job),
      ),
    ).then((result) {
      // 수정이나 삭제가 완료되면 새로고침
      if (result == true || result == 'deleted') {
        _refreshJobLists();
      }
    });
  }

  void _viewApplicants(JobPosting job) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicantManagementScreen(jobPosting: job),
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
      _refreshJobLists();
    });
  }

  // 새로고침 메서드 - ValueKey 방식
  void _refreshJobLists() {
    setState(() {
      _refreshCounter++;
    });
  }
}