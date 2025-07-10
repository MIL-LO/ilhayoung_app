// lib/screens/employer/jobs/job_edit_screen.dart - 채용공고 수정 화면

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/job_posting_model.dart';
import '../../../services/applicant_management_service.dart';
import '../../../components/common/jeju_select_box.dart';

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
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _salaryController;
  late TextEditingController _descriptionController;
  late TextEditingController _experienceController;

  String _selectedLocation = '';
  String _selectedCategory = '';
  String _selectedWorkType = '';
  DateTime? _selectedDeadline;

  bool _isLoading = false;

  // 옵션 리스트
  final List<String> _locations = [
    '제주시', '서귀포시', '애월읍', '한림읍',
    '구좌읍', '성산읍', '표선면', '남원읍'
  ];
  final List<String> _categories = [
    '카페/음료', '음식점', '숙박업', '관광/레저',
    '농업', '유통/판매', '서비스업', '기타'
  ];
  final List<String> _workTypes = [
    '정규직', '계약직', '파트타임', '알바', '인턴'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // 기존 값으로 초기화 (안전한 방식)
    _titleController = TextEditingController(text: widget.jobPosting.title);
    _companyController = TextEditingController(text: _getJobCompany());
    _salaryController = TextEditingController(text: _getJobSalary());
    _descriptionController = TextEditingController(text: _getJobDescription());
    _experienceController = TextEditingController(text: _getJobExperience());

    _selectedLocation = _getJobLocation();
    _selectedCategory = _getJobCategory();
    _selectedWorkType = _getJobWorkType();
    _selectedDeadline = widget.jobPosting.deadline;
  }

  // Helper 메서드들 - 기존 모델과 호환
  String _getJobCompany() {
    try {
      return (widget.jobPosting as dynamic).company ?? '';
    } catch (e) {
      return ''; // 기본값
    }
  }

  String _getJobSalary() {
    try {
      final salary = (widget.jobPosting as dynamic).salary;
      if (salary is int) {
        return salary.toString();
      } else if (salary is String) {
        return salary;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  String _getJobDescription() {
    try {
      return (widget.jobPosting as dynamic).description ?? '';
    } catch (e) {
      return '';
    }
  }

  String _getJobExperience() {
    try {
      return (widget.jobPosting as dynamic).experience ?? '';
    } catch (e) {
      return '';
    }
  }

  String _getJobLocation() {
    try {
      return (widget.jobPosting as dynamic).location ?? _locations.first;
    } catch (e) {
      return _locations.first;
    }
  }

  String _getJobCategory() {
    try {
      return (widget.jobPosting as dynamic).category ?? _categories.first;
    } catch (e) {
      return _categories.first;
    }
  }

  String _getJobWorkType() {
    try {
      return (widget.jobPosting as dynamic).workType ?? _workTypes.first;
    } catch (e) {
      return _workTypes.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
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
            onPressed: _isLoading ? null : _updateJobPosting,
            child: Text(
              '완료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isLoading ? Colors.grey : const Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('기본 정보', Icons.info_outline),
              const SizedBox(height: 16),
              _buildBasicInfoSection(),

              const SizedBox(height: 32),
              _buildSectionHeader('근무 조건', Icons.work_outline),
              const SizedBox(height: 16),
              _buildWorkConditionsSection(),

              const SizedBox(height: 32),
              _buildSectionHeader('상세 내용', Icons.description_outlined),
              const SizedBox(height: 16),
              _buildDetailsSection(),

              const SizedBox(height: 32),
              _buildDeleteSection(),

              const SizedBox(height: 100), // 하단 여백
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2D3748), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildTextFormField(
          controller: _titleController,
          label: '공고 제목',
          hint: '예: 카페 바리스타 모집',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '공고 제목을 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _companyController,
          label: '회사명',
          hint: '예: 제주 카페',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '회사명을 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: JejuSelectBox(
                label: '지역',
                value: _selectedLocation,
                icon: Icons.location_on,
                color: const Color(0xFF2D3748),
                onTap: () => _showLocationPicker(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: JejuSelectBox(
                label: '업종',
                value: _selectedCategory,
                icon: Icons.category,
                color: const Color(0xFF4A5568),
                onTap: () => _showCategoryPicker(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkConditionsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: JejuSelectBox(
                label: '고용형태',
                value: _selectedWorkType,
                icon: Icons.work,
                color: const Color(0xFF2D3748),
                onTap: () => _showWorkTypePicker(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextFormField(
                controller: _salaryController,
                label: '급여',
                hint: '예: 시급 12,000원',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '급여를 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDeadlinePicker(),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: _experienceController,
          label: '경력 요구사항',
          hint: '예: 경력무관, 1년 이상',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return _buildTextFormField(
      controller: _descriptionController,
      label: '상세 설명',
      hint: '업무 내용, 우대사항, 복리후생 등을 작성해주세요',
      maxLines: 8,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '상세 설명을 입력해주세요';
        }
        return null;
      },
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
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
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
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
        InkWell(
          onTap: _selectDeadline,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedDeadline != null
                      ? '${_selectedDeadline!.year}.${_selectedDeadline!.month.toString().padLeft(2, '0')}.${_selectedDeadline!.day.toString().padLeft(2, '0')}'
                      : '마감일을 선택해주세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDeadline != null ? Colors.black87 : Colors.grey[500],
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
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

  void _showWorkTypePicker() {
    _showPickerBottomSheet(
      title: '💼 고용형태 선택',
      items: _workTypes,
      selectedItem: _selectedWorkType,
      onSelected: (workType) {
        setState(() {
          _selectedWorkType = workType;
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

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
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

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Future<void> _updateJobPosting() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation.isEmpty) {
      _showErrorMessage('지역을 선택해주세요');
      return;
    }

    if (_selectedCategory.isEmpty) {
      _showErrorMessage('업종을 선택해주세요');
      return;
    }

    if (_selectedWorkType.isEmpty) {
      _showErrorMessage('고용형태를 선택해주세요');
      return;
    }

    if (_selectedDeadline == null) {
      _showErrorMessage('마감일을 선택해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final jobData = {
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'location': _selectedLocation,
        'category': _selectedCategory,
        'salary': _salaryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'experience': _experienceController.text.trim(),
        'workType': _selectedWorkType,
        'deadline': _selectedDeadline!.toIso8601String(),
      };

      final result = await ApplicantManagementService.updateJobPosting(
        widget.jobPosting.id,
        jobData,
      );

      if (result['success']) {
        _showSuccessMessage(result['message'] ?? '공고가 수정되었습니다');
        Navigator.pop(context, true); // 수정 성공 신호와 함께 돌아가기
      } else {
        _showErrorMessage(result['error']);
      }
    } catch (e) {
      _showErrorMessage('수정 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
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
    Navigator.pop(context); // 다이얼로그 닫기

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApplicantManagementService.deleteJobPosting(widget.jobPosting.id);

      if (result['success']) {
        _showSuccessMessage(result['message'] ?? '공고가 삭제되었습니다');
        Navigator.pop(context, 'deleted'); // 삭제 신호와 함께 돌아가기
      } else {
        _showErrorMessage(result['error']);
      }
    } catch (e) {
      _showErrorMessage('삭제 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
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