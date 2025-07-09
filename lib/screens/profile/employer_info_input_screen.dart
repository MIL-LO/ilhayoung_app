// lib/screens/profile/employer_info_input_screen.dart - API 연동된 사업자 회원가입

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/user_type.dart';
import '../../components/common/unified_app_header.dart';
import '../../services/signup_service.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_state_provider.dart';

class EmployerInfoInputScreen extends ConsumerStatefulWidget {
  final Function(UserType) onComplete;

  const EmployerInfoInputScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<EmployerInfoInputScreen> createState() => _EmployerInfoInputScreenState();
}

class _EmployerInfoInputScreenState extends ConsumerState<EmployerInfoInputScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 폼 관련
  final _formKey = GlobalKey<FormState>();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessNumberController = TextEditingController();

  // 상태 변수
  String _selectedBusinessType = '음식점';
  bool _isSubmitting = false;
  bool _isVerifyingBusinessNumber = false;
  bool? _isBusinessNumberVerified; // null: 미검증, true: 검증성공, false: 검증실패
  Map<String, String?> _validationErrors = {};

  // 업종 목록
  final List<String> _businessTypes = [
    '음식점', '카페', '편의점', '서비스업', '소매업', '숙박업', '관광업', '농업', '기타'
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fillTestData(); // 개발용 테스트 데이터
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

  void _fillTestData() {
    // 개발용 테스트 데이터 자동 입력
    _birthDateController.text = '1990-01-01';
    _phoneController.text = '010-1234-5678';
    _businessAddressController.text = '제주시 연동 123-45 오션뷰빌딩 1층';
    _businessNumberController.text = '123-45-67890';
    _selectedBusinessType = '카페';
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _businessAddressController.dispose();
    _businessNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '사업자 정보 입력',
        subtitle: '사업장 정보를 입력해주세요',
        emoji: '🏢',
        showBackButton: true,
        onBackPressed: _handleBackPress,
        backgroundColor: const Color(0xFFF8FFFE),
        foregroundColor: const Color(0xFF2D3748),
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
                      _buildInfoCard(),
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

  /// 🔙 뒤로가기 처리
  void _handleBackPress() {
    final hasInputData = _birthDateController.text.isNotEmpty ||
        _phoneController.text.isNotEmpty ||
        _businessAddressController.text.isNotEmpty ||
        _businessNumberController.text.isNotEmpty;

    if (hasInputData) {
      _showBackConfirmDialog();
    } else {
      _goBackToLogin();
    }
  }

  /// 뒤로가기 확인 다이얼로그
  void _showBackConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[600], size: 24),
            const SizedBox(width: 8),
            const Text('정말 나가시겠습니까?'),
          ],
        ),
        content: const Text(
          '입력하신 정보가 모두 사라지고\n'
              '처음 로그인 화면으로 돌아갑니다.\n'
              '정말로 나가시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goBackToLogin();
            },
            child: Text(
              '나가기',
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }

  /// 로그인 화면으로 돌아가기
  Future<void> _goBackToLogin() async {
    try {
      print('🔙 로그인 화면으로 이동 - 로그아웃 처리');
      await ref.read(authStateProvider.notifier).logout();
      print('✅ 로그아웃 완료');
    } catch (e) {
      print('❌ 로그아웃 처리 오류: $e');
    }
  }

  Widget _buildWelcomeCard() {
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
                child: const Text(
                  '🏢',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사업자 등록',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '제주에서 함께 성장해요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
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
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '입력하신 정보는 구직자에게 표시되며,\n언제든지 수정할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                child: const Icon(
                  Icons.business,
                  color: Color(0xFF2D3748),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '사업자 정보',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 생년월일
          _buildInputField(
            controller: _birthDateController,
            label: '생년월일',
            hint: 'YYYY-MM-DD (예: 1990-01-01)',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.datetime,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
              LengthLimitingTextInputFormatter(10),
              BirthDateFormatter(),
            ],
            errorText: _validationErrors['birthDate'],
            onChanged: (_) => _clearError('birthDate'),
            onTap: () => _selectBirthDate(),
          ),
          const SizedBox(height: 20),

          // 연락처
          _buildInputField(
            controller: _phoneController,
            label: '연락처',
            hint: '010-1234-5678',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
              PhoneNumberFormatter(),
            ],
            errorText: _validationErrors['phone'],
            onChanged: (_) => _clearError('phone'),
          ),
          const SizedBox(height: 20),

          // 사업장 주소
          _buildInputField(
            controller: _businessAddressController,
            label: '사업장 주소',
            hint: '제주시 연동 123-45 오션뷰빌딩 1층',
            icon: Icons.location_on,
            maxLines: 2,
            errorText: _validationErrors['businessAddress'],
            onChanged: (_) => _clearError('businessAddress'),
          ),
          const SizedBox(height: 20),

          // 사업자등록번호 + 검증 버튼
          _buildBusinessNumberField(),
          const SizedBox(height: 20),

          // 업종 선택
          _buildBusinessTypeDropdown(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? errorText,
    Function(String)? onChanged,
    VoidCallback? onTap,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: false, // DatePicker 오류 방지를 위해 읽기 전용 해제
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF2D3748).withOpacity(0.6),
              size: 20,
            ),
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
              borderSide: const BorderSide(
                color: Color(0xFF2D3748),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사업자등록번호',
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
              child: TextFormField(
                controller: _businessNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                  BusinessNumberFormatter(),
                ],
                onChanged: (value) {
                  _clearError('businessNumber');
                  setState(() {
                    _isBusinessNumberVerified = null; // 검증 상태 초기화
                  });
                },
                decoration: InputDecoration(
                  hintText: '000-00-00000',
                  prefixIcon: Icon(
                    Icons.badge,
                    color: const Color(0xFF2D3748).withOpacity(0.6),
                    size: 20,
                  ),
                  suffixIcon: _isBusinessNumberVerified == true
                      ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  )
                      : _isBusinessNumberVerified == false
                      ? const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 20,
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isBusinessNumberVerified == true
                          ? Colors.green
                          : _isBusinessNumberVerified == false
                          ? Colors.red
                          : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isBusinessNumberVerified == true
                          ? Colors.green
                          : _isBusinessNumberVerified == false
                          ? Colors.red
                          : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _isBusinessNumberVerified == true
                          ? Colors.green
                          : _isBusinessNumberVerified == false
                          ? Colors.red
                          : const Color(0xFF2D3748),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  errorText: _validationErrors['businessNumber'],
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              height: 56,
              child: ElevatedButton(
                onPressed: _canVerifyBusinessNumber() ? _verifyBusinessNumber : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isBusinessNumberVerified == true
                      ? Colors.green
                      : _isBusinessNumberVerified == false
                      ? Colors.red
                      : const Color(0xFF2D3748),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isVerifyingBusinessNumber
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Icon(
                  _isBusinessNumberVerified == true
                      ? Icons.check
                      : _isBusinessNumberVerified == false
                      ? Icons.close
                      : Icons.search,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        if (_isBusinessNumberVerified == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '검증 완료된 사업자등록번호입니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          )
        else if (_isBusinessNumberVerified == false)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '검증에 실패했지만 회원가입은 가능합니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBusinessTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '업종',
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
          child: DropdownButtonFormField<String>(
            value: _selectedBusinessType,
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.category,
                color: Color(0xFF2D3748),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: _businessTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedBusinessType = newValue;
                });
                _clearError('businessType');
              }
            },
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
              backgroundColor: const Color(0xFF2D3748),
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
              '🏢 등록 완료',
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

  // 이벤트 핸들러들
  void _clearError(String field) {
    if (_validationErrors.containsKey(field)) {
      setState(() {
        _validationErrors.remove(field);
      });
    }
  }

  /// 생년월일 선택
  Future<void> _selectBirthDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime(1990, 1, 1),
        firstDate: DateTime(1920),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: const Color(0xFF2D3748),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: const Color(0xFF2D3748),
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        setState(() {
          _birthDateController.text = picked.toIso8601String().split('T')[0];
        });
        _clearError('birthDate');
      }
    } catch (e) {
      print('DatePicker 오류: $e');
      // DatePicker 실패 시 수동 입력 안내
      _showSnackBar('생년월일을 YYYY-MM-DD 형식으로 직접 입력해주세요', Colors.orange);
    }
  }

  /// 사업자등록번호 검증 가능 여부
  bool _canVerifyBusinessNumber() {
    final cleanNumber = SignupService.formatBusinessNumber(_businessNumberController.text);
    return cleanNumber.length == 10 && !_isVerifyingBusinessNumber;
  }

  /// 사업자등록번호 검증
  Future<void> _verifyBusinessNumber() async {
    if (_isVerifyingBusinessNumber) return;

    final businessNumber = _businessNumberController.text.trim();
    if (businessNumber.isEmpty) {
      setState(() {
        _validationErrors['businessNumber'] = '사업자등록번호를 입력해주세요';
      });
      return;
    }

    // 로컬 형식 검증
    if (!SignupService.isValidBusinessNumberFormat(businessNumber)) {
      setState(() {
        _validationErrors['businessNumber'] = '올바른 사업자등록번호 형식이 아닙니다';
      });
      return;
    }

    setState(() {
      _isVerifyingBusinessNumber = true;
      _validationErrors.remove('businessNumber');
    });

    try {
      print('🔍 사업자등록번호 검증 시작: $businessNumber');

      final result = await SignupService.verifyBusinessNumber(businessNumber);

      if (mounted) {
        if (result['success']) {
          print('✅ 사업자등록번호 검증 성공');
          setState(() {
            _isBusinessNumberVerified = true;
          });
          _showSnackBar('검증 완료! 유효한 사업자등록번호입니다.', Colors.green);
        } else {
          print('❌ 사업자등록번호 검증 실패: ${result['error']}');
          setState(() {
            _isBusinessNumberVerified = false;
          });
          _showSnackBar('검증 실패! 하지만 회원가입은 가능합니다.', Colors.orange);
        }
      }
    } catch (e) {
      print('❌ 사업자등록번호 검증 중 예외: $e');
      if (mounted) {
        setState(() {
          _isBusinessNumberVerified = false;
        });
        _showSnackBar('검증 실패! 하지만 회원가입은 가능합니다.', Colors.orange);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingBusinessNumber = false;
        });
      }
    }
  }

  /// 입력 데이터 검증
  Map<String, String?> _validateInputs() {
    final errors = <String, String?>{};

    // 생년월일 검증
    if (_birthDateController.text.isEmpty) {
      errors['birthDate'] = '생년월일을 입력해주세요';
    } else if (!SignupService.isValidBirthDate(_birthDateController.text)) {
      errors['birthDate'] = '올바른 생년월일을 입력해주세요';
    }

    // 연락처 검증
    if (_phoneController.text.isEmpty) {
      errors['phone'] = '연락처를 입력해주세요';
    } else {
      final phoneText = _phoneController.text.trim();
      // 010-XXXX-XXXX 형식 검증
      final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
      if (!phoneRegex.hasMatch(phoneText)) {
        errors['phone'] = '010-XXXX-XXXX 형식으로 입력해주세요';
      }
    }

    // 사업장 주소 검증
    if (_businessAddressController.text.trim().isEmpty) {
      errors['businessAddress'] = '사업장 주소를 입력해주세요';
    } else if (_businessAddressController.text.trim().length < 5) {
      errors['businessAddress'] = '사업장 주소를 정확히 입력해주세요';
    }

    // 사업자등록번호 검증 (필수 아님)
    if (_businessNumberController.text.isEmpty) {
      errors['businessNumber'] = '사업자등록번호를 입력해주세요';
    }
    // 사업자등록번호 검증은 선택사항이므로 검증 실패해도 회원가입 가능

    return errors;
  }

  Future<void> _submitForm() async {
    print('=== 🎯 사업자 회원가입 폼 제출 시작 ===');

    // 1️⃣ 입력값 유효성 검사
    final errors = _validateInputs();

    if (errors.isNotEmpty) {
      setState(() {
        _validationErrors = errors;
      });
      _showSnackBar('입력 정보를 확인해주세요.', Colors.red);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationErrors.clear();
    });

    try {
      print('📝 사업자 회원가입 데이터:');
      print('- 생년월일: ${_birthDateController.text.trim()}');
      print('- 연락처: ${_phoneController.text.trim()}');
      print('- 사업장 주소: ${_businessAddressController.text.trim()}');
      print('- 사업자등록번호: ${_businessNumberController.text.trim()}');
      print('- 업종: $_selectedBusinessType');

      // 2️⃣ API 호출
      final result = await SignupService.completeManagerSignup(
        birthDate: _birthDateController.text.trim(),
        phone: _phoneController.text.trim(), // 하이픈 포함된 형태로 전송
        businessAddress: _businessAddressController.text.trim(),
        businessNumber: SignupService.formatBusinessNumber(_businessNumberController.text.trim()),
        businessType: _selectedBusinessType,
      );

      if (mounted) {
        if (result['success']) {
          print('✅ 사업자 회원가입 성공!');

          // 3️⃣ 사용자 상태를 ACTIVE로 업데이트
          await AuthService.updateUserStatusToVerified();
          print('✅ 사용자 상태 ACTIVE로 업데이트 (자동 로그인 활성화)');

          _showSnackBar('사업자 등록이 완료되었습니다! 🎉', const Color(0xFF2D3748));

          // 4️⃣ AuthStateProvider 상태 업데이트 후 콜백 실행
          await Future.delayed(const Duration(milliseconds: 500));
          widget.onComplete(UserType.employer);

        } else {
          print('❌ 사업자 회원가입 실패: ${result['error']}');

          // 서버 에러 메시지 파싱
          String errorMessage = result['error'] ?? '사업자 등록에 실패했습니다';
          if (errorMessage.contains('phone:')) {
            errorMessage = '전화번호 형식이 올바르지 않습니다. 010-XXXX-XXXX 형식으로 입력해주세요.';
          }

          _showSnackBar(errorMessage, Colors.red);
        }
      }
    } catch (e) {
      print('❌ 사업자 회원가입 처리 중 예외: $e');
      if (mounted) {
        _showSnackBar('사업자 등록 중 오류가 발생했습니다', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 🔧 생년월일 포맷터 (YYYY-MM-DD)
class BirthDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    try {
      String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (digits.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      if (digits.length > 8) {
        digits = digits.substring(0, 8);
      }

      String formatted = _formatBirthDate(digits);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } catch (e) {
      print('BirthDateFormatter 오류: $e');
      return newValue;
    }
  }

  String _formatBirthDate(String digits) {
    try {
      switch (digits.length) {
        case 0:
          return '';
        case 1:
        case 2:
        case 3:
        case 4:
          return digits;
        case 5:
        case 6:
          return '${digits.substring(0, 4)}-${digits.substring(4)}';
        case 7:
        case 8:
        default:
          return '${digits.substring(0, 4)}-${digits.substring(4, 6)}-${digits.substring(6)}';
      }
    } catch (e) {
      print('_formatBirthDate 오류: $e');
      return digits;
    }
  }
}

// 🔧 사업자등록번호 포맷터
class BusinessNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    try {
      String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (digits.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      if (digits.length > 10) {
        digits = digits.substring(0, 10);
      }

      String formatted = _formatBusinessNumber(digits);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } catch (e) {
      print('BusinessNumberFormatter 오류: $e');
      String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.length > 10) {
        digitsOnly = digitsOnly.substring(0, 10);
      }
      return TextEditingValue(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );
    }
  }

  String _formatBusinessNumber(String digits) {
    try {
      switch (digits.length) {
        case 0:
          return '';
        case 1:
        case 2:
        case 3:
          return digits;
        case 4:
        case 5:
          return '${digits.substring(0, 3)}-${digits.substring(3)}';
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        default:
          return '${digits.substring(0, 3)}-${digits.substring(3, 5)}-${digits.substring(5)}';
      }
    } catch (e) {
      print('_formatBusinessNumber 오류: $e');
      return digits;
    }
  }
}

// 🔧 개선된 전화번호 포맷터
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    try {
      String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (digits.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      if (digits.length > 11) {
        digits = digits.substring(0, 11);
      }

      String formatted = _formatPhoneNumber(digits);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } catch (e) {
      print('PhoneNumberFormatter 오류: $e');
      String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.length > 11) {
        digitsOnly = digitsOnly.substring(0, 11);
      }
      return TextEditingValue(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );
    }
  }

  String _formatPhoneNumber(String digits) {
    try {
      switch (digits.length) {
        case 0:
          return '';
        case 1:
        case 2:
        case 3:
          return digits;
        case 4:
        case 5:
        case 6:
        case 7:
          return '${digits.substring(0, 3)}-${digits.substring(3)}';
        case 8:
        case 9:
        case 10:
        case 11:
        default:
          return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
      }
    } catch (e) {
      print('_formatPhoneNumber 오류: $e');
      return digits;
    }
  }
}