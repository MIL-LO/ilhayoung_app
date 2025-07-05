import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../core/enums/user_type.dart';
import '../../components/common/unified_app_header.dart';

class WorkerInfoInputScreen extends StatefulWidget {
  final Function(UserType) onComplete;

  const WorkerInfoInputScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<WorkerInfoInputScreen> createState() => _WorkerInfoInputScreenState();
}

class _WorkerInfoInputScreenState extends State<WorkerInfoInputScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 폼 컨트롤러들
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _dongController = TextEditingController();

  // 생년월일
  DateTime? _selectedBirthDate;

  // 주소 선택
  String? _selectedCity;
  String? _selectedDistrict;

  // 제주도 지역 데이터
  final Map<String, List<String>> _jejuRegions = {
    '제주시': [
      '한림읍', '애월읍', '구좌읍', '조천읍', '일도1동', '일도2동', '이도1동',
      '이도2동', '삼도1동', '삼도2동', '용담1동', '용담2동', '건입동',
      '화북동', '삼양동', '봉개동', '아라동', '오라동', '연동', '노형동',
      '외도동', '이호동', '도두동'
    ],
    '서귀포시': [
      '대정읍', '남원읍', '성산읍', '안덕면', '표선면', '송산동', '정방동',
      '중앙동', '천지동', '효돈동', '영천동', '동홍동', '서홍동', '대륜동',
      '대천동', '중문동', '예래동'
    ],
  };

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
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

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _dongController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '프로필 설정',
        subtitle: '구직자 정보를 입력해주세요',
        emoji: '👤',
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),
                      _buildNameField(),
                      const SizedBox(height: 20),
                      _buildBirthDateField(),
                      const SizedBox(height: 20),
                      _buildPhoneField(),
                      const SizedBox(height: 20),
                      _buildAddressSection(),
                      const SizedBox(height: 20),
                      _buildExperienceField(),
                      const SizedBox(height: 100), // 하단 버튼 여백
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _buildSubmitButton(),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A3A3), Color(0xFF00D4AA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A3A3).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🌊',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            '제주에서의 새로운 시작!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '정확한 정보를 입력하시면 더 좋은 일자리를 찾아드릴게요',
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

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이름 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00A3A3),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '실명을 입력해주세요',
            prefixIcon: const Icon(Icons.person, color: Color(0xFF00A3A3)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00A3A3), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '이름을 입력해주세요';
            }
            if (value.trim().length < 2) {
              return '이름은 2글자 이상 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '생년월일 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00A3A3),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectBirthDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF00A3A3)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedBirthDate != null
                        ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일'
                        : '생년월일을 선택해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedBirthDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '연락처 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00A3A3),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
            PhoneNumberFormatter(), // 자동 하이픈 추가
          ],
          decoration: InputDecoration(
            hintText: '010-0000-0000',
            prefixIcon: const Icon(Icons.phone, color: Color(0xFF00A3A3)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00A3A3), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '연락처를 입력해주세요';
            }
            if (value.replaceAll('-', '').length < 10) {
              return '올바른 연락처를 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '거주 주소 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00A3A3),
          ),
        ),
        const SizedBox(height: 8),

        // 시/군 선택
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                hint: '시/군 선택',
                value: _selectedCity,
                items: _jejuRegions.keys.toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                    _selectedDistrict = null; // 시/군 변경시 구/읍면 초기화
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                hint: '구/읍면 선택',
                value: _selectedDistrict,
                items: _selectedCity != null ? _jejuRegions[_selectedCity!]! : [],
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value;
                  });
                },
                enabled: _selectedCity != null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 동 입력 (선택사항)
        TextFormField(
          controller: _dongController,
          decoration: InputDecoration(
            hintText: '동 입력 (선택사항)',
            prefixIcon: const Icon(Icons.location_on, color: Color(0xFF00A3A3)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00A3A3), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '경력 또는 관련 경험',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00A3A3),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '예시: 한식 주점 홀 아르바이트 3개월',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _experienceController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '관련 경험이나 경력을 자유롭게 작성해주세요',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.work_outline, color: Color(0xFF00A3A3)),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00A3A3), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A3A3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    '🌊 시작하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        items: enabled ? items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 14)),
        )).toList() : null,
        onChanged: enabled ? onChanged : null,
        icon: Icon(Icons.keyboard_arrow_down, color: enabled ? Colors.grey[600] : Colors.grey[400]),
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        dropdownColor: Colors.white,
        validator: enabled ? (value) {
          if (value == null || value.isEmpty) {
            return hint.contains('시/군') ? '시/군을 선택해주세요' : '구/읍면을 선택해주세요';
          }
          return null;
        } : null,
      ),
    );
  }

  // 이벤트 핸들러들
  void _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)), // 20세
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 80)), // 80세
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 14)), // 14세
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00A3A3),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('생년월일을 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCity == null || _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('거주 주소를 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 여기서 실제로 데이터를 저장하는 로직 구현
      await Future.delayed(const Duration(seconds: 2)); // 임시 지연

      // 성공 시 콜백 실행
      widget.onComplete(UserType.worker);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('정보 저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}


class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    try {
      // 숫자만 추출
      String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

      // 최대 11자리로 제한
      if (digitsOnly.length > 11) {
        digitsOnly = digitsOnly.substring(0, 11);
      }

      // 빈 문자열 처리
      if (digitsOnly.isEmpty) {
        return const TextEditingValue(text: '');
      }

      String formatted = _formatPhoneNumber(digitsOnly);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } catch (e) {
      // 오류 발생 시 원본 값 반환
      print('PhoneNumberFormatter 오류: $e');
      return newValue;
    }
  }

  String _formatPhoneNumber(String digits) {
    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 7) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else if (digits.length <= 11) {
      // 마지막 부분 길이 계산
      int lastPartLength = digits.length - 7;
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }

    return digits;
  }
}