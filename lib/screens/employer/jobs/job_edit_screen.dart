// lib/screens/employer/jobs/job_edit_screen.dart - 채용공고 수정 화면

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/job_posting_model.dart';
import '../../../services/applicant_management_service.dart';
import '../../../services/job_api_service.dart';

const List<String> unifiedJobCategories = [
  '카페/음료',
  '음식점',
  '숙박업',
  '관광/레저',
  '농업',
  '유통/판매',
  '서비스업',
  'IT/개발',
  '기타',
];

class JobEditScreen extends StatefulWidget {
  final JobPosting jobPosting;

  const JobEditScreen({
    Key? key,
    required this.jobPosting,
  }) : super(key: key);

  @override
  State<JobEditScreen> createState() => _JobEditScreenState();
}

class _JobEditScreenState extends State<JobEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 폼 컨트롤러들
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
    
    // 첫 번째 프레임이 빌드된 후 컨트롤러 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    print('=== 공고 수정 화면 초기화 시작 ===');
    print('받은 공고 데이터: ${widget.jobPosting.toJson()}');
    
    // 기존 공고 데이터로 컨트롤러 초기화
    _titleController.text = widget.jobPosting.title;
    _descriptionController.text = widget.jobPosting.description ?? '';
    _positionController.text = widget.jobPosting.position;
    _salaryController.text = widget.jobPosting.salary.toString();
    _startTimeController.text = widget.jobPosting.workSchedule.startTime;
    _endTimeController.text = widget.jobPosting.workSchedule.endTime;
    _paymentDateController.text = widget.jobPosting.paymentDate ?? '매월 25일';
    _recruitmentCountController.text = widget.jobPosting.recruitmentCount?.toString() ?? '1';

    // 업체 정보 (수정 불가)
    _companyNameController.text = widget.jobPosting.companyName;
    _companyAddressController.text = widget.jobPosting.workLocation;
    _companyContactController.text = widget.jobPosting.companyContact ?? '';
    _representativeNameController.text = widget.jobPosting.representativeName ?? '';

    // 근무 조건 설정
    _selectedGender = widget.jobPosting.gender ?? '무관';
    _selectedWorkDays = List<String>.from(widget.jobPosting.workSchedule.days);
    _selectedWorkStartDate = widget.jobPosting.workStartDate ?? DateTime.now().add(const Duration(days: 7));
    _selectedWorkEndDate = widget.jobPosting.workEndDate ?? DateTime.now().add(const Duration(days: 90));
    _selectedWorkPeriod = widget.jobPosting.workSchedule.workPeriod;
    _selectedDeadline = widget.jobPosting.deadline;
    // 직무 분야 설정 - 목록에 없는 값이면 기본값으로 설정
    final jobType = widget.jobPosting.jobType;
    _selectedJobType = unifiedJobCategories.contains(jobType) ? jobType! : '카페/음료';
    
    print('=== 컨트롤러 값 설정 완료 ===');
    print('제목: ${_titleController.text}');
    print('설명: ${_descriptionController.text}');
    print('직책: ${_positionController.text}');
    print('급여: ${_salaryController.text}');
    print('시작시간: ${_startTimeController.text}');
    print('종료시간: ${_endTimeController.text}');
    print('모집인원: ${_recruitmentCountController.text}');
    print('업체명: ${_companyNameController.text}');
    print('업체주소: ${_companyAddressController.text}');
    print('연락처: ${_companyContactController.text}');
    print('대표자명: ${_representativeNameController.text}');
    print('성별: $_selectedGender');
    print('직무분야: $_selectedJobType');
    print('근무기간: $_selectedWorkPeriod');
    print('근무일: $_selectedWorkDays');
    print('마감일: $_selectedDeadline');
    print('근무시작일: $_selectedWorkStartDate');
    print('근무종료일: $_selectedWorkEndDate');
    print('========================');
    
    // UI 업데이트를 위해 setState 호출
    setState(() {});
  }

  @override
  void dispose() {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '공고 수정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _updateJobPosting,
            child: Text(
              '완료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isSubmitting ? Colors.grey : const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
      body: _isSubmitting
          ? _buildLoadingWidget()
          : Form(
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
                    const SizedBox(height: 32),
                    _buildDeleteSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
          ),
          SizedBox(height: 16),
          Text(
            '공고를 수정하는 중...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
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
          const Text('✏️', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          const Text(
            '공고를 수정해보세요!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '더 나은 공고로 더 많은 지원자를 모집하세요',
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

  Widget _buildBasicInfoSection() {
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
          items: unifiedJobCategories,
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
          controller: _companyAddressController,
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
                  fontSize: 18,
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
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
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
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[400]!),
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
    // 중복된 값 제거
    final uniqueItems = items.toSet().toList();
    
    // 현재 값이 목록에 없으면 null로 설정 (드롭다운에서 선택되지 않은 상태)
    final validValue = uniqueItems.contains(value) ? value : null;
    
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
            value: validValue,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: uniqueItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final displayText = itemLabels != null && index < itemLabels.length 
                  ? itemLabels[index] 
                  : item;
              return DropdownMenuItem(
                value: item,
                child: Text(displayText),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null) {
                return '${label}을 선택해주세요';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkDaysSelector() {
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
          children: ['월', '화', '수', '목', '금', '토', '일'].map((day) {
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
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDeadline,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              setState(() {
                _selectedDeadline = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_selectedDeadline.year}-${_selectedDeadline.month.toString().padLeft(2, '0')}-${_selectedDeadline.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
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
          onTap: _isSubmitting ? null : _updateJobPosting,
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
                    '수정 중...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.save, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    '공고 수정하기',
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

  Widget _buildDeleteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚠️ 위험 구역',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '공고를 삭제하면 모든 지원자 정보도 함께 삭제되며 복구할 수 없습니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showDeleteConfirmDialog,
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('공고 삭제'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateJobPosting() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 근무 기간 계산 (개월수)
      int workDurationMonths = 0;
      if (_selectedWorkStartDate != null && _selectedWorkEndDate != null) {
        final difference = _selectedWorkEndDate.difference(_selectedWorkStartDate);
        workDurationMonths = (difference.inDays / 30).round();
        if (workDurationMonths < 1) workDurationMonths = 1;
      }

      final result = await JobApiService.updateJob(
        recruitId: widget.jobPosting.id,
        title: _titleController.text.trim(),
        workLocation: _companyAddressController.text.trim(),
        salary: int.tryParse(_salaryController.text.trim()),
        jobType: _selectedJobType,
        position: _positionController.text.trim(),
        workSchedule: {
          'days': _selectedWorkDays,
          'startTime': _startTimeController.text.trim(),
          'endTime': _endTimeController.text.trim(),
          'workPeriod': _selectedWorkPeriod,
        },
        gender: _selectedGender,
        description: _descriptionController.text.trim(),
        deadline: _selectedDeadline.toIso8601String(),
        paymentDate: _paymentDateController.text.trim(),
        companyName: _companyNameController.text.trim(),
        companyAddress: _companyAddressController.text.trim(),
        companyContact: _companyContactController.text.trim(),
        representativeName: _representativeNameController.text.trim(),
        recruitmentCount: int.tryParse(_recruitmentCountController.text.trim()),
        workStartDate: _selectedWorkStartDate.toIso8601String().substring(0, 10),
        workEndDate: _selectedWorkEndDate.toIso8601String().substring(0, 10),
        workDurationMonths: workDurationMonths,
      );

      if (result['success']) {
        _showSuccessMessage(result['message'] ?? '공고가 수정되었습니다');
        Navigator.pop(context, true);
      } else {
        _showErrorMessage(result['error']);
      }
    } catch (e) {
      _showErrorMessage('수정 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '⚠️ 공고 삭제',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '정말로 "${widget.jobPosting.title}" 공고를 삭제하시겠습니까?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Text(
                '⚠️ 삭제된 공고는 복구할 수 없으며, 모든 지원자 정보도 함께 삭제됩니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
            onPressed: () => _deleteJobPosting(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteJobPosting() async {
    Navigator.pop(context);

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ApplicantManagementService.deleteJobPosting(widget.jobPosting.id);

      if (result['success']) {
        _showSuccessMessage(result['message'] ?? '공고가 삭제되었습니다');
        Navigator.pop(context, 'deleted');
      } else {
        _showErrorMessage(result['error']);
      }
    } catch (e) {
      _showErrorMessage('삭제 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}