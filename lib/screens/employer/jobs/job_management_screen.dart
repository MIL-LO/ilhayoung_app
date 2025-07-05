// lib/screens/employer/jobs/job_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/common/unified_app_header.dart';

// 공고 상태 enum
enum JobStatus { active, closed }

// 공고 데이터 모델
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

class JobManagementScreen extends StatefulWidget {
  const JobManagementScreen({Key? key}) : super(key: key);

  @override
  State<JobManagementScreen> createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends State<JobManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  // 폼 컨트롤러들
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();

  // 폼 상태
  String _selectedPosition = '서빙';
  String _selectedSalaryType = '시급';
  String _selectedWorkTime = '주간';
  List<String> _selectedWorkDays = ['월', '화', '수', '목', '금'];
  bool _isSubmitting = false;

  // 공고 리스트
  List<JobPosting> _jobPostings = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTabs();
    _loadJobPostings();
    _fillTestData();
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
    _tabController = TabController(length: 2, vsync: this);
  }

  void _fillTestData() {
    _titleController.text = '제주맛집카페 서빙 직원 모집';
    _descriptionController.text = '친절하고 성실한 서빙 직원을 모집합니다.\n카페 경험자 우대하며, 초보자도 친절히 교육해드립니다.';
    _salaryController.text = '12000';
    _locationController.text = '제주시 연동 123-45 제주맛집카페';
    _contactController.text = '010-1234-5678';
  }

  void _loadJobPostings() {
    _jobPostings = [
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
        title: '제주흑돼지집 주방 보조 모집',
        company: '제주흑돼지집',
        status: JobStatus.closed,
        position: '주방',
        salary: '시급 13,000원',
        workTime: '17:00 - 01:00',
        location: '제주시 노형동',
        applicantCount: 25,
        viewCount: 234,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        deadline: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    setState(() {});
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '공고 관리',
        subtitle: '공고를 등록하고 관리하세요',
        emoji: '📋',
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
                  _buildJobListTab(),
                  _buildCreateJobTab(),
                ],
              ),
            ),
          ],
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
            icon: Icon(Icons.list, size: 20),
            text: '내 공고',
          ),
          Tab(
            icon: Icon(Icons.add_circle, size: 20),
            text: '새 공고 작성',
          ),
        ],
      ),
    );
  }

  Widget _buildJobListTab() {
    final activeJobs = _jobPostings.where((job) => job.status == JobStatus.active).toList();
    final closedJobs = _jobPostings.where((job) => job.status == JobStatus.closed).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _loadJobPostings();
      },
      color: const Color(0xFF2D3748),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(),
            const SizedBox(height: 20),
            if (activeJobs.isNotEmpty) ...[
              _buildSectionHeader('활성 공고', activeJobs.length, Colors.green),
              const SizedBox(height: 12),
              ...activeJobs.map((job) => _buildJobCard(job)),
              const SizedBox(height: 20),
            ],
            if (closedJobs.isNotEmpty) ...[
              _buildSectionHeader('마감된 공고', closedJobs.length, Colors.grey),
              const SizedBox(height: 12),
              ...closedJobs.map((job) => _buildJobCard(job)),
            ],
            if (_jobPostings.isEmpty) _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateJobTab() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFormHeader(),
            const SizedBox(height: 20),
            _buildFormSection(
              title: '기본 정보',
              icon: Icons.info,
              children: [
                _buildTextField(
                  label: '공고 제목',
                  hint: '예: 제주맛집카페 서빙 직원 모집',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '공고 제목을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: '상세 설명',
                  hint: '업무 내용, 우대사항, 근무환경 등을 자세히 작성해주세요',
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '상세 설명을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: '직무',
                  value: _selectedPosition,
                  items: const ['서빙', '주방', '캐셔', '청소', '배달', '기타'],
                  onChanged: (value) {
                    setState(() {
                      _selectedPosition = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormSection(
              title: '근무 조건',
              icon: Icons.work,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: '급여 형태',
                        value: _selectedSalaryType,
                        items: const ['시급', '일급', '월급'],
                        onChanged: (value) {
                          setState(() {
                            _selectedSalaryType = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: '급여 (원)',
                        hint: '12000',
                        controller: _salaryController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '급여를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: '근무 시간대',
                  value: _selectedWorkTime,
                  items: const ['주간', '야간', '새벽', '심야', '자유시간'],
                  onChanged: (value) {
                    setState(() {
                      _selectedWorkTime = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildWorkDaysSelector(),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormSection(
              title: '근무 위치',
              icon: Icons.location_on,
              children: [
                _buildTextField(
                  label: '근무 장소',
                  hint: '제주시 연동 123-45 제주맛집카페',
                  controller: _locationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '근무 장소를 입력해주세요';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormSection(
              title: '연락처 정보',
              icon: Icons.contact_phone,
              children: [
                _buildTextField(
                  label: '연락처',
                  hint: '010-1234-5678',
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '연락처를 입력해주세요';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('📝', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          const Text(
            '새로운 인재를 찾아보세요!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '구체적이고 매력적인 공고일수록 더 많은 지원자가 모집됩니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalApplicants = _jobPostings.fold(0, (sum, job) => sum + job.applicantCount);
    final totalViews = _jobPostings.fold(0, (sum, job) => sum + job.viewCount);
    final activeCount = _jobPostings.where((job) => job.status == JobStatus.active).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
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
              Expanded(child: _buildStatItem('총 공고', '${_jobPostings.length}개', Icons.work)),
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

  Widget _buildJobCard(JobPosting job) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
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
            '"새 공고 작성" 탭에서 첫 공고를 등록해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2D3748), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
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

  Widget _buildWorkDaysSelector() {
    const workDays = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '근무 요일',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: workDays.map((day) {
            final isSelected = _selectedWorkDays.contains(day);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedWorkDays.remove(day);
                  } else {
                    _selectedWorkDays.add(day);
                  }
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2D3748) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2D3748) : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSubmitting ? null : _submitJob,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '등록 중...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.rocket_launch, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    '공고 등록하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 헬퍼 메서드들
  int _getDaysLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    return difference > 0 ? difference : 0;
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

  void _submitJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWorkDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('근무 요일을 최소 1개 이상 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(seconds: 2));

      final newJob = JobPosting(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        company: '내 업체',
        status: JobStatus.active,
        position: _selectedPosition,
        salary: '$_selectedSalaryType ${_salaryController.text}원',
        workTime: _selectedWorkTime,
        location: _locationController.text,
        applicantCount: 0,
        viewCount: 0,
        createdAt: DateTime.now(),
        deadline: DateTime.now().add(const Duration(days: 30)),
      );

      setState(() {
        _jobPostings.insert(0, newJob);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('공고가 성공적으로 등록되었습니다!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _salaryController.clear();
      _locationController.clear();
      _contactController.clear();
      _selectedPosition = '서빙';
      _selectedSalaryType = '시급';
      _selectedWorkTime = '주간';
      _selectedWorkDays = ['월', '화', '수', '목', '금'];

      _tabController.animateTo(0);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('공고 등록에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}