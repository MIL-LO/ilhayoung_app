import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

// 공통 헤더 import
import '../../../components/common/jeju_common_header.dart';
// 셀렉트 박스 컴포넌트 import
import '../../../components/common/jeju_select_box.dart';

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

  // 제주 지역 필터
  final List<String> _locations = [
    '제주 전체', '제주시', '서귀포시', '애월읍', '한림읍', '구좌읍', '성산읍', '표선면', '남원읍'
  ];

  // 카테고리 필터
  final List<String> _categories = [
    '전체', '카페/음료', '음식점', '숙박업', '관광/레저', '농업', '유통/판매', '서비스업'
  ];

  // 샘플 공고 데이터 (페이지당 20개)
  List<JejuJobItem> _allJobs = [];
  List<JejuJobItem> _displayedJobs = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateSampleJobs();
    _loadInitialJobs();
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

  void _generateSampleJobs() {
    final List<String> companies = [
      '제주 오션뷰 카페', '한라산 펜션', '제주감귤농장', '성산일출호텔', '애월해변카페',
      '제주관광농원', '서귀포리조트', '제주흑돼지구이', '한라봉농장', '제주마트',
      '제주돌문화공원', '제주신화월드', '제주유나이티드', '제주도청', '제주은행',
      '제주국제대학교', '제주KAL호텔', '제주롯데호텔', '제주하얏트호텔', '제주파라다이스'
    ];

    final List<String> jobTitles = [
      '바리스타', '서빙', '프론트데스크', '하우스키핑', '주방보조',
      '감귤수확', '농장관리', '판매사원', '매장관리', '고객상담',
      '가이드', '리셉션', '마케팅', '사무보조', '배송기사'
    ];

    final List<String> regions = [
      '제주시', '서귀포시', '애월읍', '한림읍', '구좌읍', '성산읍', '표선면', '남원읍'
    ];

    final List<int> salaries = [
      10000, 11000, 12000, 13000, 14000, 15000, 16000, 17000, 18000, 20000
    ];

    _allJobs = List.generate(100, (index) {
      final companyIndex = index % companies.length;
      final titleIndex = index % jobTitles.length;
      final regionIndex = index % regions.length;
      final salaryIndex = index % salaries.length;

      return JejuJobItem(
        id: index + 1,
        title: '${jobTitles[titleIndex]} 모집',
        company: companies[companyIndex],
        salary: '시급 ${salaries[salaryIndex].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
        location: regions[regionIndex],
        isUrgent: index % 7 == 0,
        tags: _generateTags(index),
        workType: index % 3 == 0 ? '정규직' : (index % 3 == 1 ? '아르바이트' : '계약직'),
        postedDate: DateTime.now().subtract(Duration(days: index % 30)),
      );
    });
  }

  List<String> _generateTags(int index) {
    final allTags = [
      '주말근무', '평일근무', '야간근무', '장기근무', '단기근무',
      '4대보험', '퇴직금', '교통비', '식비제공', '숙식제공'
    ];

    final selectedTags = <String>[];
    for (int i = 0; i < 3; i++) {
      selectedTags.add(allTags[(index + i) % allTags.length]);
    }
    return selectedTags;
  }

  void _loadInitialJobs() {
    setState(() {
      _displayedJobs = _allJobs.take(20).toList();
      _currentPage = 1;
    });
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

    Future.delayed(Duration(milliseconds: 1000), () {
      final nextPageStart = _currentPage * 20;
      final nextPageEnd = nextPageStart + 20;

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
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // 🎯 공통 헤더 컴포넌트 사용
                  JejuCommonHeader(
                    emoji: '🌊',
                    title: '제주 일자리',
                    subtitle: '바다처럼 넓은 기회를 찾아보세요',
                    expandedHeight: 80,
                    actions: [
                      IconButton(
                        icon: Icon(Icons.search, color: Color(0xFF00A3A3), size: 20),
                        onPressed: () => _showSearchDialog(),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.all(4),
                      ),
                      IconButton(
                        icon: Icon(Icons.filter_list, color: Color(0xFF00A3A3), size: 20),
                        onPressed: () => _showFilterDialog(),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.all(4),
                      ),
                    ],
                  ),
                  _buildSearchAndFilters(),
                  _buildJejuBanner(),
                  _buildJobsList(),
                  if (_isLoading) _buildLoadingIndicator(),
                  SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            JejuSelectBox(
              label: '지역',
              value: _selectedLocation,
              icon: Icons.location_on,
              color: Color(0xFF00A3A3),
              onTap: () => _showLocationPicker(),
            ),
            SizedBox(width: 8),
            JejuSelectBox(
              label: '업종',
              value: _selectedCategory,
              icon: Icons.category,
              color: Color(0xFFFF6B35),
              onTap: () => _showCategoryPicker(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJejuBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 8, 16, 12),
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00A3A3), Color(0xFF00D4AA)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00A3A3).withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🌊 총 ${_allJobs.length}개의 일자리',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '제주에서 꿈을 펼쳐보세요!',
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
                child: Center(
                  child: Text('🏔️', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= _displayedJobs.length) return null;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildJobCard(_displayedJobs[index]),
          );
        },
        childCount: _displayedJobs.length,
      ),
    );
  }

  Widget _buildJobCard(JejuJobItem job) {
    return GestureDetector(
      onTap: () => _showJobDetail(job),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: job.isUrgent
                ? Color(0xFFFF6B35).withOpacity(0.3)
                : Color(0xFF00A3A3).withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.company,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00A3A3),
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (job.isUrgent)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '급구',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 4),

            // 공고명
            Text(
              job.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 6),

            // 급여
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Color(0xFF00A3A3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                job.salary,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00A3A3),
                ),
              ),
            ),

            SizedBox(height: 4),

            // 지역 정보
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                SizedBox(width: 2),
                Text(
                  job.location,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                SizedBox(width: 8),
                Icon(Icons.work_outline, size: 12, color: Colors.grey[600]),
                SizedBox(width: 2),
                Text(
                  job.workType,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),

            SizedBox(height: 6),

            // 태그
            Wrap(
              spacing: 3,
              runSpacing: 2,
              children: job.tags.take(2).map((tag) => Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SliverToBoxAdapter(
      child: Container(
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

  // 다이얼로그들
  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    '🌊 ',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '제주 지역 선택',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF00A3A3),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  final isSelected = _selectedLocation == location;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: isSelected ? Color(0xFF00A3A3).withOpacity(0.1) : null,
                      title: Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Color(0xFF00A3A3) : Colors.grey[800],
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: Color(0xFF00A3A3), size: 20)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLocation = location;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    '🍊 ',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '업종 선택',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: isSelected ? Color(0xFFFF6B35).withOpacity(0.1) : null,
                      title: Text(
                        category,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Color(0xFFFF6B35) : Colors.grey[800],
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: Color(0xFFFF6B35), size: 20)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
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
              borderSide: BorderSide(color: Color(0xFF00A3A3).withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF00A3A3)),
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
                SnackBar(
                  content: Text('검색 기능 준비 중입니다 🔍'),
                  backgroundColor: Color(0xFF00A3A3),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00A3A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
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
        title: Text(
          '🎯 필터 설정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF6B35),
          ),
        ),
        content: Text('상세 필터 기능 준비 중입니다'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '확인',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
  }

  void _showJobDetail(JejuJobItem job) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 핸들
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 헤더
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.company,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF00A3A3),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          job.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (job.isUrgent)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF6B35), Color(0xFFFF8A50)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🚨 급구',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 급여 정보
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF00A3A3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        job.salary,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00A3A3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 20),

                    // 기본 정보
                    _buildDetailSection('📍 근무지역', job.location),
                    _buildDetailSection('💼 근무형태', job.workType),
                    _buildDetailSection('📅 등록일',
                        '${job.postedDate.year}-${job.postedDate.month.toString().padLeft(2, '0')}-${job.postedDate.day.toString().padLeft(2, '0')}'),

                    SizedBox(height: 20),

                    // 태그
                    Text(
                      '🏷️ 근무 조건',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: job.tags.map((tag) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF00A3A3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFF00A3A3).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF00A3A3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // 지원하기 버튼
            Container(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${job.title} 지원이 완료되었습니다! 🌊'),
                      backgroundColor: Color(0xFF00A3A3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00A3A3),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '🌊 지원하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
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
}

// 제주 일자리 아이템 모델
class JejuJobItem {
  final int id;
  final String title;
  final String company;
  final String salary;
  final String location;
  final bool isUrgent;
  final List<String> tags;
  final String workType;
  final DateTime postedDate;

  JejuJobItem({
    required this.id,
    required this.title,
    required this.company,
    required this.salary,
    required this.location,
    required this.isUrgent,
    required this.tags,
    required this.workType,
    required this.postedDate,
  });
}