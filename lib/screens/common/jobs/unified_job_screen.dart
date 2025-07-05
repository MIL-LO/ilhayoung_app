// lib/screens/common/jobs/unified_job_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnifiedJobScreen extends StatefulWidget {
  final String userType; // 'worker' or 'employer'

  const UnifiedJobScreen({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  State<UnifiedJobScreen> createState() => _UnifiedJobScreenState();
}

class _UnifiedJobScreenState extends State<UnifiedJobScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 필터 상태
  String _selectedLocation = '전체';
  String _selectedJobType = '전체';
  String _selectedWage = '전체';
  String _searchQuery = '';
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    // 사용자 타입에 따라 탭 개수 결정
    int tabCount = widget.userType == 'employer' ? 3 : 2;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('📋 공고'),
        backgroundColor: widget.userType == 'employer'
            ? const Color(0xFF2D3748)
            : const Color(0xFF0EA5E9),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              _isFilterExpanded ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 탭 바
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: widget.userType == 'employer'
                  ? const Color(0xFF2D3748)
                  : const Color(0xFF0EA5E9),
              labelColor: widget.userType == 'employer'
                  ? const Color(0xFF2D3748)
                  : const Color(0xFF0EA5E9),
              unselectedLabelColor: Colors.grey[600],
              tabs: widget.userType == 'employer'
                  ? [
                const Tab(text: '전체 공고'),
                const Tab(text: '내 공고'),
                const Tab(text: '새 공고'),
              ]
                  : [
                const Tab(text: '전체 공고'),
                const Tab(text: '관심 공고'),
              ],
            ),
          ),

          // 필터 바 (확장 가능)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isFilterExpanded ? 120 : 0,
            child: _buildFilterBar(),
          ),

          // 탭 컨텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.userType == 'employer'
                  ? [
                _buildAllJobsTab(),
                _buildMyJobsTab(),
                _buildCreateJobTab(),
              ]
                  : [
                _buildAllJobsTab(),
                _buildFavoriteJobsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    if (!_isFilterExpanded) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색 바
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: '공고 제목, 회사명으로 검색',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 필터 칩들
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  label: '지역: $_selectedLocation',
                  isSelected: _selectedLocation != '전체',
                  onTap: () => _showLocationFilter(),
                ),
                const SizedBox(width: 8),

                _buildFilterChip(
                  label: '업종: $_selectedJobType',
                  isSelected: _selectedJobType != '전체',
                  onTap: () => _showJobTypeFilter(),
                ),
                const SizedBox(width: 8),

                _buildFilterChip(
                  label: '시급: $_selectedWage',
                  isSelected: _selectedWage != '전체',
                  onTap: () => _showWageFilter(),
                ),
                const SizedBox(width: 8),

                if (_selectedLocation != '전체' ||
                    _selectedJobType != '전체' ||
                    _selectedWage != '전체')
                  _buildFilterChip(
                    label: '초기화',
                    isSelected: false,
                    onTap: () {
                      setState(() {
                        _selectedLocation = '전체';
                        _selectedJobType = '전체';
                        _selectedWage = '전체';
                      });
                    },
                    isReset: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isReset = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isReset
              ? Colors.red[50]
              : isSelected
              ? (widget.userType == 'employer' ? const Color(0xFF2D3748) : const Color(0xFF0EA5E9))
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReset
                ? Colors.red[300]!
                : isSelected
                ? (widget.userType == 'employer' ? const Color(0xFF2D3748) : const Color(0xFF0EA5E9))
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isReset
                ? Colors.red[700]
                : isSelected
                ? Colors.white
                : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildAllJobsTab() {
    return Column(
      children: [
        // 통계 카드 (사업자용)
        if (widget.userType == 'employer') ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildStatsCard(),
          ),
        ],

        // 공고 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _filteredJobs.length,
            itemBuilder: (context, index) {
              final job = _filteredJobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildJobCard(job),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyJobsTab() {
    final myJobs = _allJobs.where((job) => job['isMyJob'] == true).toList();

    return Column(
      children: [
        // 내 공고 통계
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildMyJobsStatsCard(myJobs),
        ),

        // 내 공고 리스트
        Expanded(
          child: myJobs.isEmpty
              ? _buildEmptyMyJobs()
              : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: myJobs.length,
            itemBuilder: (context, index) {
              final job = myJobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildJobCard(job, isMyJob: true),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCreateJobTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormHeader(),
          const SizedBox(height: 24),
          _buildJobForm(),
        ],
      ),
    );
  }

  Widget _buildFavoriteJobsTab() {
    final favoriteJobs = _allJobs.where((job) => job['isFavorite'] == true).toList();

    return favoriteJobs.isEmpty
        ? _buildEmptyFavorites()
        : ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: favoriteJobs.length,
      itemBuilder: (context, index) {
        final job = favoriteJobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildJobCard(job),
        );
      },
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('총 공고', '156', Icons.work_outline),
          _buildStatItem('내 공고', '5', Icons.business_center),
          _buildStatItem('신규 지원자', '12', Icons.person_add),
          _buildStatItem('총 조회수', '234', Icons.visibility),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2D3748), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyJobsStatsCard(List<Map<String, dynamic>> myJobs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem('내 공고', myJobs.length.toString(), Icons.work),
          _buildStatItem('지원자', myJobs.fold(0, (sum, job) => sum + (job['applicants'] as int)).toString(), Icons.people),
          _buildStatItem('조회수', myJobs.fold(0, (sum, job) => sum + (job['views'] as int)).toString(), Icons.visibility),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, {bool isMyJob = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.userType == 'worker')
                GestureDetector(
                  onTap: () => _toggleFavorite(job),
                  child: Icon(
                    job['isFavorite'] == true ? Icons.favorite : Icons.favorite_border,
                    color: job['isFavorite'] == true ? Colors.red : Colors.grey[400],
                    size: 20,
                  ),
                ),
              if (isMyJob) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _editJob(job),
                  child: Icon(Icons.edit_outlined, color: Colors.grey[600], size: 20),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _deleteJob(job),
                  child: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildJobInfoChip('💰 ${job['wage']}원', const Color(0xFF10B981)),
              const SizedBox(width: 8),
              _buildJobInfoChip('📍 ${job['location']}', const Color(0xFF6366F1)),
              const SizedBox(width: 8),
              _buildJobInfoChip('⏰ ${job['workTime']}', const Color(0xFFF59E0B)),
            ],
          ),
          if (isMyJob) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '지원자 ${job['applicants']}명',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '조회수 ${job['views']}회',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyMyJobs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '등록된 공고가 없어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 공고를 등록해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _tabController.animateTo(2),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3748),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('새 공고 작성'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '관심 공고가 없어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '마음에 드는 공고에 하트를 눌러보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '새 공고 작성',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '인재를 찾기 위한 공고를 작성해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormField('공고 제목', '예: 카페 아르바이트 구함'),
          const SizedBox(height: 16),
          _buildFormField('상세 설명', '업무 내용, 근무 환경 등을 상세히 작성해주세요', maxLines: 4),
          const SizedBox(height: 16),
          _buildFormField('시급', '예: 12000'),
          const SizedBox(height: 16),
          _buildFormField('근무 시간', '예: 09:00 ~ 18:00'),
          const SizedBox(height: 16),
          _buildFormField('근무 지역', '예: 제주시'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3748),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '공고 등록하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  // 필터링된 공고 리스트
  List<Map<String, dynamic>> get _filteredJobs {
    return _allJobs.where((job) {
      if (_selectedLocation != '전체' && job['location'] != _selectedLocation) {
        return false;
      }
      if (_selectedJobType != '전체' && job['jobType'] != _selectedJobType) {
        return false;
      }
      if (_selectedWage != '전체') {
        int wage = job['wage'] as int;
        switch (_selectedWage) {
          case '9,620원 이상':
            if (wage < 9620) return false;
            break;
          case '10,000원 이상':
            if (wage < 10000) return false;
            break;
          case '12,000원 이상':
            if (wage < 12000) return false;
            break;
        }
      }
      if (_searchQuery.isNotEmpty) {
        return job['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  // 더미 데이터
  final List<Map<String, dynamic>> _allJobs = [
    {
      'id': '1',
      'title': '🏖️ 해변 카페 아르바이트',
      'description': '제주 협재해변 앞 카페에서 함께 일할 친구를 찾아요',
      'jobType': '카페·음료',
      'location': '제주시',
      'wage': 12000,
      'workTime': '09:00 ~ 18:00',
      'company': '바다뷰 카페',
      'applicants': 8,
      'views': 45,
      'isMyJob': false,
      'isFavorite': false,
    },
    {
      'id': '2',
      'title': '🍊 감귤농장 수확 알바',
      'description': '감귤 수확 시즌 단기 알바생 모집',
      'jobType': '농업',
      'location': '서귀포시',
      'wage': 10000,
      'workTime': '08:00 ~ 17:00',
      'company': '제주 감귤농장',
      'applicants': 12,
      'views': 67,
      'isMyJob': false,
      'isFavorite': true,
    },
    {
      'id': '3',
      'title': '🛍️ 제주 기념품샵 판매직',
      'description': '관광객을 위한 제주 특산품 판매',
      'jobType': '소매·판매',
      'location': '제주시',
      'wage': 9620,
      'workTime': '10:00 ~ 22:00',
      'company': '제주마실',
      'applicants': 5,
      'views': 23,
      'isMyJob': true,
      'isFavorite': false,
    },
    {
      'id': '4',
      'title': '🌊 서핑샵 스태프',
      'description': '서핑 장비 관리 및 고객 응대',
      'jobType': '레저·스포츠',
      'location': '제주시',
      'wage': 15000,
      'workTime': '08:00 ~ 18:00',
      'company': '제주 서핑클럽',
      'applicants': 15,
      'views': 89,
      'isMyJob': false,
      'isFavorite': true,
    },
    {
      'id': '5',
      'title': '🍜 한식당 홀서빙',
      'description': '제주 향토음식 전문점에서 함께 일하실 분',
      'jobType': '식당·주방',
      'location': '서귀포시',
      'wage': 11000,
      'workTime': '11:00 ~ 21:00',
      'company': '제주맛집',
      'applicants': 3,
      'views': 34,
      'isMyJob': true,
      'isFavorite': false,
    },
  ];

  void _showLocationFilter() {
    final locations = ['전체', '제주시', '서귀포시', '한림읍', '애월읍', '조천읍', '구좌읍'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '지역 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: locations.map((location) {
                final isSelected = _selectedLocation == location;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedLocation = location);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D3748) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      location,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showJobTypeFilter() {
    final jobTypes = ['전체', '카페·음료', '식당·주방', '편의점', '소매·판매', '레저·스포츠', '농업', '숙박·관광', '기타'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '업종 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: jobTypes.map((jobType) {
                final isSelected = _selectedJobType == jobType;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedJobType = jobType);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D3748) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      jobType,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showWageFilter() {
    final wages = ['전체', '9,620원 이상', '10,000원 이상', '12,000원 이상', '15,000원 이상'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '시급 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Column(
              children: wages.map((wage) {
                final isSelected = _selectedWage == wage;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedWage = wage);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D3748) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2D3748) : Colors.grey[200]!,
                      ),
                    ),
                    child: Text(
                      wage,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite(Map<String, dynamic> job) {
    setState(() {
      job['isFavorite'] = !job['isFavorite'];
    });
    HapticFeedback.lightImpact();
  }

  void _editJob(Map<String, dynamic> job) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${job['title']} 수정 화면으로 이동')),
    );
  }

  void _deleteJob(Map<String, dynamic> job) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공고 삭제'),
        content: Text('${job['title']}을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allJobs.removeWhere((j) => j['id'] == job['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('공고가 삭제되었습니다')),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _submitJob() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공고가 성공적으로 등록되었습니다!')),
    );
    _tabController.animateTo(1); // 내 공고 탭으로 이동
  }
}