// lib/screens/employer/jobs/job_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/common/unified_app_header.dart';
import '../../../providers/employer_job_provider.dart';

class JobManagementScreen extends ConsumerStatefulWidget {
  const JobManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JobManagementScreen> createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends ConsumerState<JobManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  // 폼 컨트롤러들
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _workLocationController = TextEditingController();
  final _positionController = TextEditingController();
  final _paymentDateController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyContactController = TextEditingController();
  final _representativeNameController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  // 폼 상태
  String _selectedJobType = '카페/음료';
  String _selectedGender = '무관';
  String _selectedWorkPeriod = 'ONE_TO_THREE';
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 30));
  List<String> _selectedWorkDays = ['월', '화', '수', '목', '금'];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTabs();
    _loadInitialData();
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

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobProvider.notifier).loadMyJobs(refresh: true);
    });
  }

  void _fillTestData() {
    _titleController.text = '제주 연동 카페 홀 스태프 모집';
    _descriptionController.text = '친절하고 밝은 성격의 홀 스태프를 모집합니다. 카페 운영 경험이 있으시면 우대합니다.';
    _salaryController.text = '10000';
    _workLocationController.text = '제주시 연동';
    _positionController.text = '홀 스태프';
    _paymentDateController.text = '매월 25일';
    _companyNameController.text = '제주 힐링 카페';
    _companyAddressController.text = '제주시 연동 123-45';
    _companyContactController.text = '064-123-4567';
    _representativeNameController.text = '김제주';
    _startTimeController.text = '09:00';
    _endTimeController.text = '18:00';
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _workLocationController.dispose();
    _positionController.dispose();
    _paymentDateController.dispose();
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyContactController.dispose();
    _representativeNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
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
    final jobState = ref.watch(jobProvider);

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
            icon: const Icon(Icons.list, size: 20),
            text: '내 공고 (${jobState.myJobs.length})',
          ),
          const Tab(
            icon: Icon(Icons.add_circle, size: 20),
            text: '새 공고 작성',
          ),
        ],
      ),
    );
  }

  Widget _buildJobListTab() {
    final jobState = ref.watch(jobProvider);
    final myJobs = jobState.myJobs;
    final activeJobs = myJobs.where((job) => job.isActive).toList();
    final inactiveJobs = myJobs.where((job) => !job.isActive).toList();

    if (jobState.isLoading && myJobs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2D3748),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(jobProvider.notifier).loadMyJobs(refresh: true);
      },
      color: const Color(0xFF2D3748),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(myJobs),
            const SizedBox(height: 20),
            if (jobState.error != null) ...[
              _buildErrorWidget(jobState.error!),
              const SizedBox(height: 20),
            ],
            if (activeJobs.isNotEmpty) ...[
              _buildSectionHeader('활성 공고', activeJobs.length, Colors.green),
              const SizedBox(height: 12),
              ...activeJobs.map((job) => _buildJobCard(job)),
              const SizedBox(height: 20),
            ],
            if (inactiveJobs.isNotEmpty) ...[
              _buildSectionHeader('비활성 공고', inactiveJobs.length, Colors.grey),
              const SizedBox(height: 12),
              ...inactiveJobs.map((job) => _buildJobCard(job)),
            ],
            if (myJobs.isEmpty && !jobState.isLoading) _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateJobTab() {
    final categories = ref.watch(categoriesProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFormHeader(),
            const SizedBox(height: 20),
            _buildBasicInfoSection(categories),
            const SizedBox(height: 16),
            _buildWorkConditionSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            _buildCompanySection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(List<String> categories) {
    return _buildFormSection(
      title: '기본 정보',
      icon: Icons.info,
      children: [
        _buildTextField(
          label: '공고 제목',
          hint: '예: 제주 연동 카페 홀 스태프 모집',
          controller: _titleController,
          validator: (value) => value?.isEmpty == true ? '공고 제목을 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '상세 설명',
          hint: '업무 내용, 우대사항, 근무환경 등을 자세히 작성해주세요',
          controller: _descriptionController,
          maxLines: 4,
          validator: (value) => value?.isEmpty == true ? '상세 설명을 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: '직무 분야',
          value: _selectedJobType,
          items: categories.where((category) => category != '전체').toList(),
          onChanged: (value) => setState(() => _selectedJobType = value!),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '세부 직무',
          hint: '예: 홀 스태프, 바리스타, 주방 보조 등',
          controller: _positionController,
          validator: (value) => value?.isEmpty == true ? '세부 직무를 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: '성별',
          value: _selectedGender,
          items: const ['무관', '남성', '여성'],
          onChanged: (value) => setState(() => _selectedGender = value!),
        ),
      ],
    );
  }

  Widget _buildWorkConditionSection() {
    return _buildFormSection(
      title: '근무 조건',
      icon: Icons.work,
      children: [
        _buildTextField(
          label: '시급 (원)',
          hint: '10000',
          controller: _salaryController,
          keyboardType: TextInputType.number,
          validator: (value) => value?.isEmpty == true ? '시급을 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: '근무 시작 시간',
                hint: '09:00',
                controller: _startTimeController,
                validator: (value) => value?.isEmpty == true ? '시작 시간을 입력해주세요' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                label: '근무 종료 시간',
                hint: '18:00',
                controller: _endTimeController,
                validator: (value) => value?.isEmpty == true ? '종료 시간을 입력해주세요' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: '근무 기간',
          value: _selectedWorkPeriod,
          items: const ['ONE_TO_THREE', 'THREE_TO_SIX', 'SIX_TO_TWELVE', 'OVER_ONE_YEAR'],
          itemLabels: const ['1개월 ~ 3개월', '3개월 ~ 6개월', '6개월 ~ 1년', '1년 이상'],
          onChanged: (value) => setState(() => _selectedWorkPeriod = value!),
        ),
        const SizedBox(height: 16),
        _buildWorkDaysSelector(),
        const SizedBox(height: 16),
        _buildDeadlinePicker(),
        const SizedBox(height: 16),
        _buildTextField(
          label: '급여 지급일',
          hint: '매월 25일',
          controller: _paymentDateController,
          validator: (value) => value?.isEmpty == true ? '급여 지급일을 입력해주세요' : null,
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildFormSection(
      title: '근무 위치',
      icon: Icons.location_on,
      children: [
        _buildTextField(
          label: '근무 지역',
          hint: '제주시 연동',
          controller: _workLocationController,
          validator: (value) => value?.isEmpty == true ? '근무 지역을 입력해주세요' : null,
        ),
      ],
    );
  }

  Widget _buildCompanySection() {
    return _buildFormSection(
      title: '업체 정보',
      icon: Icons.business,
      children: [
        _buildTextField(
          label: '업체명',
          hint: '제주 힐링 카페',
          controller: _companyNameController,
          validator: (value) => value?.isEmpty == true ? '업체명을 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '업체 주소',
          hint: '제주시 연동 123-45',
          controller: _companyAddressController,
          validator: (value) => value?.isEmpty == true ? '업체 주소를 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '업체 연락처',
          hint: '064-123-4567',
          controller: _companyContactController,
          keyboardType: TextInputType.phone,
          validator: (value) => value?.isEmpty == true ? '업체 연락처를 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '대표자명',
          hint: '김제주',
          controller: _representativeNameController,
          validator: (value) => value?.isEmpty == true ? '대표자명을 입력해주세요' : null,
        ),
      ],
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

  Widget _buildStatsCard(List<JobPosting> myJobs) {
    final totalApplicants = myJobs.fold<int>(0, (sum, job) => sum + job.applicantCount);
    final totalViews = myJobs.fold<int>(0, (sum, job) => sum + job.viewCount);
    final activeCount = myJobs.where((job) => job.isActive).length;

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
              Expanded(child: _buildStatItem('총 공고', '${myJobs.length}개', Icons.work)),
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

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '데이터를 불러올 수 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[600],
                  ),
                ),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[500],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => ref.read(jobProvider.notifier).loadMyJobs(refresh: true),
            child: Text('재시도', style: TextStyle(color: Colors.red[600])),
          ),
        ],
      ),
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
          color: job.isActive
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
                      ],
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
                  color: job.isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.isActive ? '활성' : '마감',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: job.isActive ? Colors.green : Colors.grey,
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
              if (job.isUrgent)
                _buildJobInfo(Icons.warning, '마감임박', isUrgent: true)
              else
                _buildJobInfo(Icons.access_time, '${job.daysUntilDeadline}일 남음'),
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

  Widget _buildJobInfo(IconData icon, String text, {bool isUrgent = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isUrgent ? Colors.red : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isUrgent ? Colors.red : Colors.grey[600],
            fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
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
    List<String>? itemLabels,
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
            items: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final displayText = itemLabels != null && index < itemLabels.length
                  ? itemLabels[index]
                  : item;

              return DropdownMenuItem<String>(
                value: item,
                child: Text(displayText),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlinePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '마감일',
          style: TextStyle(
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
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              '${_selectedDeadline.year}년 ${_selectedDeadline.month}월 ${_selectedDeadline.day}일',
              style: const TextStyle(fontSize: 14),
            ),
            trailing: const Icon(Icons.calendar_today, color: Color(0xFF2D3748)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDeadline,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF2D3748),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedDeadline = picked;
                });
              }
            },
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
      _showErrorSnackBar('근무 요일을 최소 1개 이상 선택해주세요');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      HapticFeedback.mediumImpact();

      final success = await ref.read(jobProvider.notifier).createJob(
        title: _titleController.text,
        description: _descriptionController.text,
        position: _positionController.text,
        salary: '시급 ${_salaryController.text}원',
        workTime: '${_startTimeController.text} - ${_endTimeController.text}',
        location: _workLocationController.text,
        contact: _companyContactController.text,
        workDays: _selectedWorkDays,
        workLocation: _workLocationController.text,
        salaryAmount: int.parse(_salaryController.text),
        jobType: _selectedJobType,
        gender: _selectedGender,
        deadline: _selectedDeadline.toIso8601String(),
        paymentDate: _paymentDateController.text,
        companyName: _companyNameController.text,
        companyAddress: _companyAddressController.text,
        companyContact: _companyContactController.text,
        representativeName: _representativeNameController.text,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        workPeriod: _selectedWorkPeriod,
      );

      if (success) {
        _showSuccessSnackBar('공고가 성공적으로 등록되었습니다!');
        _clearForm();
        _tabController.animateTo(0);
      } else {
        final jobState = ref.read(jobProvider);
        _showErrorSnackBar(jobState.error ?? '공고 등록에 실패했습니다');
      }
    } catch (e) {
      _showErrorSnackBar('공고 등록에 실패했습니다: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _salaryController.clear();
    _workLocationController.clear();
    _positionController.clear();
    _paymentDateController.clear();
    _companyNameController.clear();
    _companyAddressController.clear();
    _companyContactController.clear();
    _representativeNameController.clear();
    _startTimeController.clear();
    _endTimeController.clear();

    setState(() {
      _selectedJobType = '카페/음료';
      _selectedGender = '무관';
      _selectedWorkPeriod = 'ONE_TO_THREE';
      _selectedDeadline = DateTime.now().add(const Duration(days: 30));
      _selectedWorkDays = ['월', '화', '수', '목', '금'];
    });
  }
}