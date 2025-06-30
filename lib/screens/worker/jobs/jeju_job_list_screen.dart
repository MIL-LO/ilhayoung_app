import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// 컴포넌트 imports
import '../../../components/common/jeju_select_box.dart';
import '../../../components/jobs/job_card.dart';
import '../../../components/jobs/job_banner.dart';
import '../../../components/jobs/filter_bottom_sheet.dart';
import '../../../components/jobs/job_detail_bottom_sheet.dart';
import '../../../models/jeju_job_item.dart';
import '../../../services/mock_data_service.dart';

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

  int _currentPage = 1;
  bool _isLoading = false;
  String _selectedLocation = '제주 전체';
  String _selectedCategory = '전체';
  String _searchQuery = '';

  List<String> _locations = [];
  List<String> _categories = [];
  List<JejuJobItem> _allJobs = [];
  List<JejuJobItem> _displayedJobs = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
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

  Future<void> _loadData() async {
    try {
      // 병렬로 데이터 로드
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
    } catch (e) {
      // 에러 처리 - MockDataService가 없으면 fallback 데이터 사용
      _generateFallbackData();
    }
  }

  void _generateFallbackData() {
    // MockDataService가 없을 경우 대체 데이터
    _locations = [
      '제주 전체', '제주시', '서귀포시', '애월읍', '한림읍', '구좌읍', '성산읍', '표선면', '남원읍'
    ];
    _categories = [
      '전체', '카페/음료', '음식점', '숙박업', '관광/레저', '농업', '유통/판매', '서비스업'
    ];

    final companies = [
      '제주 오션뷰 카페', '한라산 펜션', '제주감귤농장', '성산일출호텔', '애월해변카페',
      '제주관광농원', '서귀포리조트', '제주흑돼지구이', '한라봉농장', '제주마트',
    ];

    final jobTitles = [
      '바리스타', '서빙', '프론트데스크', '하우스키핑', '주방보조',
      '감귤수확', '농장관리', '판매사원', '매장관리', '고객상담',
    ];

    final regions = ['제주시', '서귀포시', '애월읍', '한림읍', '구좌읍'];
    final salaries = [10000, 12000, 14000, 16000, 18000];
    final allTags = ['주말근무', '평일근무', '4대보험', '퇴직금', '교통비'];

    _allJobs = List.generate(50, (index) {
      final company = companies[index % companies.length];
      final jobTitle = jobTitles[index % jobTitles.length];
      final region = regions[index % regions.length];
      final hourlyWage = salaries[index % salaries.length];

      return JejuJobItem(
        id: (index + 1).toString(),
        title: '$jobTitle 모집',
        company: company,
        location: region,
        fullAddress: '제주특별자치도 $region ${_generateAddress(index)}',
        salary: _formatSalary(hourlyWage),
        hourlyWage: hourlyWage,
        workType: index % 3 == 0 ? '정규직' : (index % 3 == 1 ? '아르바이트' : '계약직'),
        workSchedule: _generateWorkSchedule(index),
        isUrgent: index % 7 == 0,
        isNew: index % 10 == 0,
        category: _categories[(index % (_categories.length - 1)) + 1],
        createdAt: DateTime.now().subtract(Duration(days: index % 30)),
        description: '성실하고 책임감 있는 분을 모집합니다. 자세한 사항은 연락처로 문의해주세요.',
        contactNumber: '064-${720 + (index % 50)}-${1000 + (index % 9000)}',
        representativeName: '${['김', '이', '박', '최', '정'][index % 5]}$jobTitle',
        email: index % 3 == 0 ? null : 'contact$index@$company.co.kr',
        benefits: [
          allTags[index % allTags.length],
          allTags[(index + 1) % allTags.length],
        ],
        requirements: [
          '성실하고 책임감 있는 분',
          '고객 서비스 마인드 보유자',
        ],
        companyDescription: '$company은(는) 제주 지역의 대표적인 기업입니다.',
        tags: [
          allTags[index % allTags.length],
          allTags[(index + 1) % allTags.length],
          allTags[(index + 2) % allTags.length],
        ],
        postedDate: DateTime.now().subtract(Duration(days: index % 30)),
      );
    });

    setState(() {
      _displayedJobs = _allJobs.take(20).toList();
      _currentPage = 1;
    });
  }

  String _generateAddress(int index) {
    final addresses = [
      '연동 1234-5 오션뷰빌딩 1층',
      '중앙동 567-8 한라산타워 2층',
      '노형동 890-12 제주플라자 3층',
      '이도이동 345-67 성산빌딩 1층',
      '삼도이동 789-10 애월센터 2층',
      '용담이동 456-78 서귀포타워 1층',
      '건입동 123-45 관광빌딩 4층',
      '화북동 678-90 펜션단지 내',
    ];
    return addresses[index % addresses.length];
  }

  String _generateWorkSchedule(int index) {
    final schedules = [
      '09:00 - 18:00',
      '10:00 - 19:00',
      '14:00 - 22:00',
      '06:00 - 14:00',
      '22:00 - 06:00',
      '08:00 - 17:00',
      '13:00 - 21:00',
      '07:00 - 16:00',
    ];
    return schedules[index % schedules.length];
  }

  String _formatSalary(int salary) {
    return '시급 ${salary.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    )}원';
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreJobs();
    }
  }

  void _loadMoreJobs() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      final nextPageStart = _currentPage * 20;

      if (nextPageStart < _allJobs.length) {
        final newJobs = _allJobs.skip(nextPageStart).take(20).toList();

        setState(() {
          _displayedJobs.addAll(newJobs);
          _currentPage++;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
              child: CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  _buildJobsList(),
                  if (_isLoading) _buildLoadingIndicator(),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
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
    return JobBanner(totalJobs: _allJobs.length);
  }

  Widget _buildJobsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= _displayedJobs.length) return null;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: JobCard(
              job: _displayedJobs[index],
              onTap: () => _showJobDetail(_displayedJobs[index]),
            ),
          );
        },
        childCount: _displayedJobs.length,
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
                '제주 일자리를 불러오는 중... 🌊',
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
          '🔍 일자리 검색',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00A3A3),
          ),
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00A3A3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00A3A3)),
            ),
          ),
          onChanged: (value) {
            _searchQuery = value;
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('검색 기능 준비 중입니다 🔍'),
                  backgroundColor: Color(0xFF00A3A3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
        content: const Text('상세 필터 기능 준비 중입니다'),
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