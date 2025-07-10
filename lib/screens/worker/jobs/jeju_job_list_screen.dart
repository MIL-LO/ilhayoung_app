// lib/screens/worker/jobs/jeju_job_list_screen.dart - 컴포넌트화된 상세보기 적용

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// API 서비스 import
import '../../../services/job_api_service.dart';
import '../../../models/job_posting_model.dart';

// 컴포넌트 imports
import '../../../components/common/jeju_select_box.dart';
import '../../../components/jobs/job_banner.dart';
import '../../../components/jobs/filter_bottom_sheet.dart';
import '../../../components/jobs/job_detail_sheet.dart'; // 새로운 상세보기 컴포넌트

class JejuJobListScreen extends StatefulWidget {
  final Function? onLogout;

  const JejuJobListScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<JejuJobListScreen> createState() => _JejuJobListScreenState();
}

class _JejuJobListScreenState extends State<JejuJobListScreen>
    with TickerProviderStateMixin {

  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 페이지네이션 상태
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;

  // 필터 상태
  String _selectedLocation = '제주 전체';
  String _selectedCategory = '전체';
  String _searchQuery = '';

  // 데이터
  List<String> _locations = ['제주 전체', '제주시', '서귀포시', '애월읍', '한림읍', '구좌읍', '성산읍', '표선면', '남원읍'];
  List<String> _categories = ['전체', '카페/음료', '음식점', '숙박업', '관광/레저', '농업', '유통/판매', '서비스업'];
  List<JobPosting> _jobPostings = [];

  // 페이지네이션 정보
  int _totalElements = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
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

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
    });

    await _loadJobPostings(isRefresh: true);

    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _loadJobPostings({bool isRefresh = false}) async {
    if (_isLoading) return;

    if (isRefresh) {
      setState(() {
        _currentPage = 0;
        _hasMore = true;
        _jobPostings.clear();
      });
    }

    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await JobApiService.getJobPostings(
        page: _currentPage,
        size: 20,
        keyword: _searchQuery.isNotEmpty ? _searchQuery : null,
        location: _selectedLocation,
        jobType: _selectedCategory,
        sortBy: 'createdAt',
        sortDirection: 'desc',
      );

      if (result['success']) {
        final List<JobPosting> newJobs = result['data'];
        final pagination = result['pagination'];

        setState(() {
          if (isRefresh) {
            _jobPostings = newJobs;
          } else {
            _jobPostings.addAll(newJobs);
          }

          _totalElements = pagination['totalElements'];
          _totalPages = pagination['totalPages'];
          _hasMore = pagination['hasNext'];
          _currentPage++;
        });
      } else {
        _showErrorMessage(result['error'] ?? '채용공고를 불러오는데 실패했습니다.');
      }
    } catch (e) {
      _showErrorMessage('네트워크 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadJobPostings();
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

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF00A3A3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
            Text('🌊 ', style: TextStyle(fontSize: 20)),
            Text(
              '제주 일자리',
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
              '바다처럼 넓은 기회를 찾아보세요',
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
            icon: const Icon(Icons.search, color: Color(0xFF00A3A3), size: 22),
            onPressed: _showSearchDialog,
            tooltip: '검색',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF00A3A3), size: 22),
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
            _buildSearchAndFilters(),
            _buildBanner(),
            Expanded(
              child: _isInitialLoading
                  ? _buildInitialLoadingWidget()
                  : RefreshIndicator(
                color: const Color(0xFF00A3A3),
                onRefresh: () => _loadJobPostings(isRefresh: true),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildJobsList(),
                    if (_isLoading) _buildLoadingIndicator(),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            ),
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
          JejuSelectBox(
            label: '지역',
            value: _selectedLocation,
            icon: Icons.location_on,
            color: const Color(0xFF00A3A3),
            onTap: _showLocationPicker,
          ),
          const SizedBox(width: 8),
          JejuSelectBox(
            label: '업종',
            value: _selectedCategory,
            icon: Icons.category,
            color: const Color(0xFFFF6B35),
            onTap: _showCategoryPicker,
          ),
        ],
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
          colors: [Color(0xFF00A3A3), Color(0xFF00D4AA)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A3A3).withOpacity(0.2),
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
                    '🏢 총 ${_totalElements.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                    )}개의 공고',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '바다처럼 넓은 기회를 찾아보세요!',
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
                child: Text('🌊', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A3A3)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            '제주 일자리를 불러오는 중... 🌊',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF00A3A3),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    if (_jobPostings.isEmpty && !_isLoading) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          child: Center(
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
                  '채용공고가 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '다른 조건으로 검색해보세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index >= _jobPostings.length) return null;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildJobCard(_jobPostings[index]),
          );
        },
        childCount: _jobPostings.length,
      ),
    );
  }

  Widget _buildJobCard(JobPosting job) {
    return Container(
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
        onTap: () => _showJobDetail(job),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 정보
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 회사명
                      Text(
                        job.companyName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 공고 제목
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 태그들
                Column(
                  children: [
                    if (job.isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (job.isUrgent)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '급구',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 급여 정보
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00A3A3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                job.formattedSalary,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A3A3),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 근무 정보
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  job.workLocation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  job.workScheduleText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 근무 요일
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  job.workDaysText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 하단 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${job.applicationCount}명 지원',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                Text(
                  job.daysUntilDeadline > 0
                      ? 'D-${job.daysUntilDeadline}'
                      : '마감',
                  style: TextStyle(
                    fontSize: 11,
                    color: job.daysUntilDeadline > 0
                        ? (job.daysUntilDeadline <= 3 ? Colors.red : Colors.grey[500])
                        : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A3A3)),
                strokeWidth: 3,
              ),
              SizedBox(height: 12),
              Text(
                '더 많은 일자리를 불러오는 중... 🌊',
                style: TextStyle(fontSize: 14, color: Color(0xFF00A3A3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 다이얼로그 및 바텀시트 메서드들
  void _showLocationPicker() {
    FilterBottomSheet.showLocationPicker(
      context,
      _locations,
      _selectedLocation,
          (location) {
        setState(() {
          _selectedLocation = location;
        });
        _loadJobPostings(isRefresh: true);
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
        _loadJobPostings(isRefresh: true);
      },
    );
  }

  /// 🎯 컴포넌트화된 상세보기 사용
  void _showJobDetail(JobPosting job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => JobDetailSheet(
        job: job,
        onApply: (message) {
          // 지원 성공 시 성공 메시지 표시
          _showSuccessMessage(message);
          // 목록 새로고침 (지원자 수 업데이트)
          _loadJobPostings(isRefresh: true);
        },
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
            color: Color(0xFF00A3A3),
          ),
        ),
        content: TextField(
          controller: TextEditingController(text: tempSearchQuery),
          autofocus: true,
          decoration: InputDecoration(
            hintText: '회사명, 직무 등을 검색하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00A3A3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00A3A3), width: 2),
            ),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF00A3A3)),
          ),
          onChanged: (value) {
            tempSearchQuery = value;
          },
          onSubmitted: (value) {
            Navigator.pop(context);
            setState(() {
              _searchQuery = value;
            });
            _loadJobPostings(isRefresh: true);
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
              _loadJobPostings(isRefresh: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A3A3),
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
            color: Color(0xFFFF6B35),
          ),
        ),
        content: const Text('상세 필터 기능을 곧 추가할 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
  }
}