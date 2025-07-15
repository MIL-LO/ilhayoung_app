// lib/screens/employer/jobs/job_create_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/common/unified_app_header.dart';
import '../../../providers/employer_job_provider.dart';
import '../../../services/manager_info_service.dart';
import '../../../models/job_posting_model.dart';
import '../../../providers/categories_provider.dart';

class JobCreateScreen extends ConsumerStatefulWidget {
  const JobCreateScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JobCreateScreen> createState() => _JobCreateScreenState();
}

class _JobCreateScreenState extends ConsumerState<JobCreateScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
  final _recruitmentCountController = TextEditingController();

  // 폼 상태
  String _selectedJobType = '카페/음료';
  String _selectedGender = '무관';
  String _selectedWorkPeriod = 'ONE_TO_THREE';
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 30));
  DateTime _selectedWorkStartDate = DateTime.now().add(const Duration(days: 7));
  DateTime _selectedWorkEndDate = DateTime.now().add(const Duration(days: 90));
  List<String> _selectedWorkDays = ['월', '화', '수', '목', '금'];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadManagerInfo();
    });
  }

  Future<void> _loadManagerInfo() async {
    try {
      print('=== 매니저 정보 로드 시작 ===');
      
      final managerInfo = await ManagerInfoService.getManagerInfo();
      
      if (managerInfo != null && mounted) {
        print('✅ 매니저 정보 로드 성공: $managerInfo');
        
        setState(() {
          _companyNameController.text = managerInfo['companyName'] ?? '';
          _companyAddressController.text = managerInfo['businessAddress'] ?? '';
          _companyContactController.text = managerInfo['phone'] ?? '';
          _representativeNameController.text = managerInfo['name'] ?? '';
          _workLocationController.text = managerInfo['businessAddress'] ?? '';
        });
        
        print('✅ 업체 정보 자동 입력 완료');
      } else {
        print('⚠️ 매니저 정보가 없거나 로드 실패');
      }
    } catch (e) {
      print('❌ 매니저 정보 로드 중 오류: $e');
    }
  }

  void _fillTestData() {
    if (_companyNameController.text.isEmpty) {
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
      _recruitmentCountController.text = '2';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
    _recruitmentCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '새 공고 작성',
        subtitle: '인재를 찾기 위한 공고를 작성하세요',
        emoji: '📝',
        showBackButton: true,
        backgroundColor: const Color(0xFFF8FFFE),
        foregroundColor: const Color(0xFF2D3748),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFormHeader(),
                const SizedBox(height: 20),
                _buildBasicInfoSection(),
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
        ),
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

  Widget _buildBasicInfoSection() {
    final categories = ref.watch(categoriesProvider);
    
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
          enabled: false, // 수정 불가 - 업체 주소와 동일
          validator: (value) => value?.isEmpty == true ? '근무 지역을 입력해주세요' : null,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '근무 위치는 업체 주소와 동일하게 설정됩니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
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
          enabled: false, // 수정 불가
          validator: (value) => value?.isEmpty == true ? '업체명을 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '업체 주소',
          hint: '제주시 연동 123-45',
          controller: _companyAddressController,
          enabled: false, // 수정 불가
          validator: (value) => value?.isEmpty == true ? '업체 주소를 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '업체 연락처',
          hint: '064-123-4567',
          controller: _companyContactController,
          enabled: false, // 수정 불가
          keyboardType: TextInputType.phone,
          validator: (value) => value?.isEmpty == true ? '업체 연락처를 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '대표자명',
          hint: '김제주',
          controller: _representativeNameController,
          enabled: false, // 수정 불가
          validator: (value) => value?.isEmpty == true ? '대표자명을 입력해주세요' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: '모집인원',
          hint: '2',
          controller: _recruitmentCountController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty == true) return '모집인원을 입력해주세요';
            final count = int.tryParse(value!);
            if (count == null || count <= 0) return '1명 이상의 모집인원을 입력해주세요';
            if (count > 100) return '모집인원은 100명 이하여야 합니다';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildWorkDatePickers(),
      ],
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2D3748), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
    bool enabled = true,
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
          enabled: enabled,
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    List<String>? itemLabels,
    required Function(String?) onChanged,
  }) {
    final labels = itemLabels ?? items;
    
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
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return DropdownMenuItem<String>(
              value: item,
              child: Text(labels[index]),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitJob,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D3748),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '공고 등록하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ref.read(jobProvider.notifier).createJob(
        title: _titleController.text,
        description: _descriptionController.text,
        position: _positionController.text,
        salary: _salaryController.text,
        workTime: '${_startTimeController.text} ~ ${_endTimeController.text}',
        location: _workLocationController.text,
        contact: _companyContactController.text,
        workDays: _selectedWorkDays,
        workLocation: _workLocationController.text,
        salaryAmount: int.tryParse(_salaryController.text),
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
        recruitmentCount: int.tryParse(_recruitmentCountController.text),
        workStartDate: _selectedWorkStartDate.toIso8601String(),
        workEndDate: _selectedWorkEndDate.toIso8601String(),
        workDurationMonths: _calculateMonths(_selectedWorkStartDate, _selectedWorkEndDate),
      );

      if (result) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('공고가 성공적으로 등록되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ref.read(jobProvider).error ?? '공고 등록에 실패했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildWorkDaysSelector() {
    final workDays = ['월', '화', '수', '목', '금', '토', '일'];
    
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: workDays.map((day) {
            final isSelected = _selectedWorkDays.contains(day);
            return FilterChip(
              label: Text(day),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedWorkDays.add(day);
                  } else {
                    _selectedWorkDays.remove(day);
                  }
                });
              },
              selectedColor: const Color(0xFF2D3748),
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeadlinePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDeadline,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDeadline = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '모집 마감일',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_selectedDeadline.year}-${_selectedDeadline.month.toString().padLeft(2, '0')}-${_selectedDeadline.day.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkDatePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '근무 기간',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                label: '근무 시작일',
                value: _selectedWorkStartDate,
                onChanged: (date) => setState(() => _selectedWorkStartDate = date),
                validator: (date) {
                  if (date.isBefore(DateTime.now())) {
                    return '근무 시작일은 오늘 이후여야 합니다';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePicker(
                label: '근무 종료일',
                value: _selectedWorkEndDate,
                onChanged: (date) => setState(() => _selectedWorkEndDate = date),
                validator: (date) {
                  if (date.isBefore(_selectedWorkStartDate)) {
                    return '근무 종료일은 시작일 이후여야 합니다';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
    String? Function(DateTime)? validator,
  }) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateMonths(DateTime start, DateTime end) {
    return ((end.year - start.year) * 12 + end.month - start.month).abs();
  }
} 