// lib/components/jobs/common_job_list.dart - 공통 채용공고 리스트 컴포넌트

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/job_posting_model.dart';
import '../../services/job_api_service.dart';
import 'job_detail_sheet.dart';

class CommonJobList extends StatefulWidget {
  final bool showMyJobsOnly; // true: 내 공고만, false: 전체 공고
  final Function? onJobAction; // 내 공고일 때 액션 (수정, 삭제 등)
  final String? searchQuery;
  final String? selectedLocation;
  final String? selectedCategory;
  final bool isEmployerMode; // 사업자 모드인지 여부

  const CommonJobList({
    Key? key,
    this.showMyJobsOnly = false,
    this.onJobAction,
    this.searchQuery,
    this.selectedLocation,
    this.selectedCategory,
    this.isEmployerMode = false, // 기본값 false (구직자 모드)
  }) : super(key: key);

  @override
  CommonJobListState createState() => CommonJobListState();
}

// State 클래스를 public으로 노출
class CommonJobListState extends State<CommonJobList> {
  final ScrollController _scrollController = ScrollController();

  // 페이지네이션 상태
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;

  // 데이터
  List<JobPosting> _jobPostings = [];
  int _totalElements = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(CommonJobList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 필터가 변경되면 데이터 새로고침
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.selectedLocation != widget.selectedLocation ||
        oldWidget.selectedCategory != widget.selectedCategory ||
        oldWidget.showMyJobsOnly != widget.showMyJobsOnly) {
      _loadJobPostings(isRefresh: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        keyword: widget.searchQuery?.isNotEmpty == true ? widget.searchQuery : null,
        location: widget.selectedLocation,
        jobType: widget.selectedCategory,
        sortBy: 'createdAt',
        sortDirection: 'desc',
        myJobsOnly: widget.showMyJobsOnly, // 내 공고만 조회할지 여부
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
      final backgroundColor = widget.isEmployerMode
          ? const Color(0xFF2D3748)
          : const Color(0xFF00A3A3);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return _buildInitialLoadingWidget();
    }

    return RefreshIndicator(
      color: widget.isEmployerMode ? const Color(0xFF2D3748) : const Color(0xFF00A3A3),
      onRefresh: () => _loadJobPostings(isRefresh: true),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 총 공고 수 배너 - 구직자용에서만 표시
          if (!widget.showMyJobsOnly && widget.onJobAction == null) _buildBanner(),

          // 내 공고 통계 (사업자용)
          if (widget.showMyJobsOnly) _buildMyJobsStats(),

          // 공고 목록
          _buildJobsList(),

          // 로딩 인디케이터
          if (_isLoading) _buildLoadingIndicator(),

          // 하단 여백
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildInitialLoadingWidget() {
    final color = widget.isEmployerMode ? const Color(0xFF2D3748) : const Color(0xFF00A3A3);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            '채용공고를 불러오는 중... 🌊',
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    // 사업자용과 구직자용 색상 구분
    final primaryColor = widget.isEmployerMode ? const Color(0xFF2D3748) : const Color(0xFF00A3A3);
    final secondaryColor = widget.isEmployerMode ? const Color(0xFF4A5568) : const Color(0xFF00D4AA);

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, secondaryColor],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
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
                    // 사업자용에서는 추가 메시지 제거, 구직자용에서만 표시
                    if (!widget.isEmployerMode) ...[
                      const SizedBox(height: 2),
                      const Text(
                        '바다처럼 넓은 기회를 찾아보세요!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ] else ...[
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
                child: Center(
                  child: Text(
                    widget.isEmployerMode ? '📊' : '🌊',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyJobsStats() {
    // 활성 상태이고 마감되지 않은 공고를 활성 공고로 간주
    final activeJobs = _jobPostings.where((job) => job.status == 'ACTIVE' && !job.isExpired).length;
    final totalApplicants = _jobPostings.fold<int>(0, (sum, job) => sum + job.applicationCount);
    // viewCount를 정확하게 사용
    final totalViews = _jobPostings.fold<int>(0, (sum, job) => sum + job.viewCount);

    return SliverToBoxAdapter(
      child: Container(
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
                  widget.showMyJobsOnly ? '등록된 공고가 없습니다' : '채용공고가 없습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.showMyJobsOnly
                      ? '공고를 등록해서 인재를 찾아보세요'
                      : '다른 조건으로 검색해보세요',
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
    final cardColor = widget.isEmployerMode ? const Color(0xFF2D3748) : const Color(0xFF00A3A3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: widget.showMyJobsOnly
            ? Border.all(
          color: cardColor.withOpacity(0.3),
        )
            : null,
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
                    if (widget.showMyJobsOnly)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '내 공고',
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
                color: cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                job.formattedSalary,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: cardColor,
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
            const SizedBox(height: 8),

            // 근무 기간 및 모집인원
            Row(
              children: [
                Icon(Icons.date_range, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _getWorkPeriodText(job),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.group, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '모집 ${_getRecruitmentCount(job)}명',
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
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      job.workSchedule.workPeriodText,
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

            // 내 공고일 때 액션 버튼들
            if (widget.showMyJobsOnly) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _editJob(job),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cardColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        '수정',
                        style: TextStyle(color: cardColor, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _viewApplicants(job),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cardColor,
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
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final color = widget.isEmployerMode ? const Color(0xFF2D3748) : const Color(0xFF00A3A3);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 3,
              ),
              const SizedBox(height: 12),
              Text(
                '더 많은 공고를 불러오는 중... 🌊',
                style: TextStyle(fontSize: 14, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 채용공고 상세보기
  void _showJobDetail(JobPosting job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => JobDetailSheet(
        job: job,
        isEmployerMode: widget.isEmployerMode, // 매니저 모드 전달
        onApply: widget.showMyJobsOnly || widget.isEmployerMode
            ? null // 내 공고이거나 매니저 모드에서는 지원 불가
            : (message) {
          _showSuccessMessage(message);
          _loadJobPostings(isRefresh: true);
        },
      ),
    );
  }

  // 내 공고 수정
  void _editJob(JobPosting job) {
    HapticFeedback.lightImpact();
    if (widget.onJobAction != null) {
      widget.onJobAction!('edit', job);
    }
  }

  // 지원자 보기
  void _viewApplicants(JobPosting job) {
    HapticFeedback.lightImpact();
    if (widget.onJobAction != null) {
      widget.onJobAction!('applicants', job);
    }
  }

  // 공개 메서드: 외부에서 새로고침 호출 가능
  Future<void> refresh() async {
    await _loadJobPostings(isRefresh: true);
  }

  // getter: 현재 공고 수
  int get totalJobs => _totalElements;
  List<JobPosting> get jobs => _jobPostings;

  String _getWorkPeriodText(JobPosting job) {
    if (job.workStartDate != null && job.workEndDate != null) {
      String dateRange = '${job.workStartDate.toString().substring(0, 10)} - ${job.workEndDate.toString().substring(0, 10)}';
      if (job.workDurationMonths != null) {
        return '$dateRange (${job.workDurationMonths}개월)';
      }
      return dateRange;
    }
    if (job.workDurationMonths != null) {
      return '${job.workDurationMonths}개월';
    }
    return '기간 미정';
  }

  String _getRecruitmentCount(JobPosting job) {
    if (job.recruitmentCount != null) {
      return job.recruitmentCount.toString();
    }
    return '미정';
  }
}