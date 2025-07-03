// lib/screens/employer/jobs/job_posting_create_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/common/unified_app_header.dart';

class JobPostingCreateScreen extends StatefulWidget {
  const JobPostingCreateScreen({Key? key}) : super(key: key);

  @override
  State<JobPostingCreateScreen> createState() => _JobPostingCreateScreenState();
}

class _JobPostingCreateScreenState extends State<JobPostingCreateScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 컨트롤러들
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hourlyWageController = TextEditingController();
  final _workLocationController = TextEditingController();
  final _contactController = TextEditingController();

  // 선택 옵션들
  String _selectedJobType = '서빙';
  String _selectedWorkTime = '주간';
  String _selectedContractType = '시급';
  List<String> _selectedWorkDays = [];

  final List<String> _jobTypes = ['서빙', '주방', '캐셔', '청소', '배달', '기타'];
  final List<String> _workTimes = ['주간', '야간', '새벽', '심야', '자유시간'];
  final List<String> _contractTypes = ['시급', '일급', '월급'];
  final List<String> _workDays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  void _fillTestData() {
    _titleController.text = '제주맛집카페 서빙 직원 모집';
    _descriptionController.text = '친절하고 성실한 서빙 직원을 모집합니다.\n카페 경험자 우대하며, 초보자도 친절히 교육해드립니다.\n밝고 긍정적인 분들의 많은 지원 바랍니다!';
    _hourlyWageController.text = '12000';
    _workLocationController.text = '제주시 연동 123-45 제주맛집카페';
    _contactController.text = '010-1234-5678';
    _selectedWorkDays = ['월', '화', '수', '목', '금'];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _hourlyWageController.dispose();
    _workLocationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '공고 작성',
        subtitle: '새로운 인재를 찾아보세요',
        emoji: '📝',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildBasicInfoCard(),
                const SizedBox(height: 20),
                _buildJobDetailsCard(),
                const SizedBox(height: 20),
                _buildWorkConditionsCard(),
                const SizedBox(height: 20),
                _buildContactCard(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3748).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('📝', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '공고 작성',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '좋은 인재를 찾아보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.white.withOpacity(0.9), size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '구체적이고 매력적인 공고일수록\n더 많은 지원자가 모집됩니다!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard(
      title: '기본 정보',
      icon: Icons.info_outline,
      children: [
        _buildTextField(
          controller: _titleController,
          label: '공고 제목',
          hint: '예: 제주맛집카페 서빙 직원 모집',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '공고 제목을 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _descriptionController,
          label: '상세 설명',
          hint: '업무 내용, 우대사항, 근무환경 등을 자세히 작성해주세요',
          maxLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '상세 설명을 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildDropdown(
          label: '직무',
          value: _selectedJobType,
          items: _jobTypes,
          onChanged: (value) {
            setState(() {
              _selectedJobType = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildJobDetailsCard() {
    return _buildCard(
      title: '근무 조건',
      icon: Icons.work_outline,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: '급여 형태',
                value: _selectedContractType,
                items: _contractTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedContractType = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _hourlyWageController,
                label: '급여 (원)',
                hint: '12000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
        const SizedBox(height: 20),
        _buildDropdown(
          label: '근무 시간대',
          value: _selectedWorkTime,
          items: _workTimes,
          onChanged: (value) {
            setState(() {
              _selectedWorkTime = value!;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildWorkDaysSelector(),
      ],
    );
  }

  Widget _buildWorkConditionsCard() {
    return _buildCard(
      title: '근무 위치',
      icon: Icons.location_on_outlined,
      children: [
        _buildTextField(
          controller: _workLocationController,
          label: '근무 장소',
          hint: '제주시 연동 123-45 제주맛집카페',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '근무 장소를 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return _buildCard(
      title: '연락처 정보',
      icon: Icons.contact_phone_outlined,
      children: [
        _buildTextField(
          controller: _contactController,
          label: '연락처',
          hint: '010-1234-5678',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '연락처를 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCard({
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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
          children: _workDays.map((day) {
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3748).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _handleSubmit,
          child: const Center(
            child: Text(
              '공고 등록하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedWorkDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('근무 요일을 하나 이상 선택해주세요'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('공고가 성공적으로 등록되었습니다!'),
            ],
          ),
          backgroundColor: const Color(0xFF2D3748),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // 공고 등록 완료 후 이전 화면으로 이동
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pop(context);
      });
    }
  }
}