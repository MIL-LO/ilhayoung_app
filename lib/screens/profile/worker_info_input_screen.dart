// lib/screens/profile/worker_info_input_screen.dart - 수정된 구직자 회원가입

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums/user_type.dart';
import '../../components/common/unified_app_header.dart';
import '../../services/signup_service.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 추가


class WorkerInfoInputScreen extends ConsumerStatefulWidget {
  final Function(UserType) onComplete;

  const WorkerInfoInputScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<WorkerInfoInputScreen> createState() => _WorkerInfoInputScreenState();
}

class _WorkerInfoInputScreenState extends ConsumerState<WorkerInfoInputScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // 폼 관련
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _dongController = TextEditingController();

  // 상태 변수
  DateTime? _selectedBirthDate;
  String? _selectedCity;
  String? _selectedDistrict;
  bool _isSubmitting = false;

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

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // 🔍 회원가입 화면 진입 시 토큰 상태 확인
    _debugTokenStatus();
  }

  /// 🔍 토큰 상태 디버깅
  Future<void> _debugTokenStatus() async {
    print('=== 🔍 회원가입 화면 토큰 상태 확인 ===');
    await AuthService.checkFullAuthStatus();
    print('================================');
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
        showBackButton: true,
        onBackPressed: _handleBackPress,
        backgroundColor: const Color(0xFFF8FFFE),
        foregroundColor: const Color(0xFF00A3A3),
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

                      // 🔍 디버깅 버튼 추가 (개발 중에만)
                      _buildDebugButtons(),
                      const SizedBox(height: 24),

                      _buildBirthDateField(),
                      const SizedBox(height: 20),
                      _buildPhoneField(),
                      const SizedBox(height: 20),
                      _buildAddressSection(),
                      const SizedBox(height: 20),
                      _buildExperienceField(),
                      const SizedBox(height: 100),
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
    final hasInputData = _selectedBirthDate != null ||
        _phoneController.text.isNotEmpty ||
        _selectedCity != null ||
        _selectedDistrict != null ||
        _dongController.text.isNotEmpty ||
        _experienceController.text.isNotEmpty;

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

      // 로그아웃 처리
      await ref.read(authStateProvider.notifier).logout();

      print('✅ 로그아웃 완료');
    } catch (e) {
      print('❌ 로그아웃 처리 오류: $e');
    }
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
            PhoneNumberFormatter(),
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

            // 전화번호 유효성 검사
            if (value.replaceAll('-', '').length < 10) {
              return '올바른 연락처를 입력해주세요';
            }
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
                    _selectedDistrict = null;
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
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 80)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 14)),
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

  Future<void> _submitForm() async {
    print('=== 🎯 STAFF 회원가입 폼 제출 시작 ===');

    // 폼 유효성 검사
    if (!_formKey.currentState!.validate()) {
      print('❌ 폼 유효성 검사 실패');
      return;
    }

    if (_selectedBirthDate == null) {
      _showSnackBar('생년월일을 선택해주세요', Colors.red);
      return;
    }

    if (_selectedCity == null || _selectedDistrict == null) {
      _showSnackBar('거주 주소를 선택해주세요', Colors.red);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 데이터 준비
      String birthDate = "${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}";
      String address = '$_selectedCity $_selectedDistrict';
      if (_dongController.text.trim().isNotEmpty) {
        address += ' ${_dongController.text.trim()}';
      }
      String experience = _experienceController.text.trim();
      if (experience.isEmpty) {
        experience = '경험 없음';
      }

      print('📝 STAFF 회원가입 데이터:');
      print('- 생년월일: $birthDate');
      print('- 연락처: ${_phoneController.text.trim()}');
      print('- 주소: $address');
      print('- 경험: $experience');

      // SignupService.completeStaffSignup 호출
      final result = await SignupService.completeStaffSignup(
        birthDate: birthDate,
        phone: _phoneController.text.trim(),
        address: address,
        experience: experience,
      );

      if (mounted) {
        if (result['success']) {
          print('✅ STAFF 회원가입 성공!');

          _showSnackBar('회원가입이 완료되었습니다! 🎉', const Color(0xFF00A3A3));

          // AuthStateProvider 상태 업데이트 후 콜백 실행
          await Future.delayed(const Duration(milliseconds: 500));
          widget.onComplete(UserType.worker);

        } else {
          print('❌ STAFF 회원가입 실패: ${result['error']}');
          _showSnackBar(result['error'] ?? '회원가입에 실패했습니다', Colors.red);
        }
      }
    } catch (e) {
      print('❌ STAFF 회원가입 처리 중 예외: $e');
      if (mounted) {
        _showSnackBar('회원가입 중 오류가 발생했습니다', Colors.red);
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

  /// 🔍 디버깅 버튼들
  Widget _buildDebugButtons() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.yellow[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Column(
            children: [
              const Text(
                '🔍 개발자 디버깅 도구',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        print('=== 🔧 토큰 저장 테스트 시작 ===');

                        // 1. SharedPreferences 직접 접근해서 저장
                        final prefs = await SharedPreferences.getInstance();
                        const testToken = 'direct_save_token_1234567890';

                        // 직접 저장
                        await prefs.setString('access_token', testToken);
                        await prefs.setString('user_status', 'ACTIVE');
                        await prefs.setString('user_type', 'STAFF');
                        await prefs.setString('user_email', '1bfish106@kakao.com');

                        print('✅ SharedPreferences 직접 저장 완료');

                        // 2. 즉시 확인
                        final savedToken = prefs.getString('access_token');
                        final savedStatus = prefs.getString('user_status');
                        print('저장된 토큰: $savedToken');
                        print('저장된 상태: $savedStatus');

                        // 3. AuthService로도 확인
                        final authToken = await AuthService.getAccessToken();
                        print('AuthService 토큰: $authToken');

                        // 4. 모든 키 확인
                        final allKeys = prefs.getKeys();
                        print('모든 저장된 키: $allKeys');

                        _showSnackBar('토큰 저장 테스트 완료 - 콘솔 확인', Colors.blue);

                        print('=== 🔧 토큰 저장 테스트 완료 ===');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('🔧 토큰저장테스트', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        print('=== 🚀 강제 메인화면 이동 ===');

                        // SharedPreferences 직접 조작
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('access_token', 'force_main_token_1234567890');
                        await prefs.setString('user_status', 'ACTIVE');
                        await prefs.setString('user_type', 'STAFF');
                        await prefs.setString('user_email', '1bfish106@kakao.com');

                        // 즉시 확인
                        print('저장 후 토큰: ${prefs.getString('access_token')}');
                        print('저장 후 상태: ${prefs.getString('user_status')}');

                        _showSnackBar('강제로 메인화면으로 이동합니다!', const Color(0xFF00A3A3));

                        // AuthStateProvider 강제 새로고침
                        await ref.read(authStateProvider.notifier).refresh();

                        // 혹시나 해서 직접 콜백도 호출
                        widget.onComplete(UserType.worker);

                        print('=== 🚀 강제 메인화면 이동 완료 ===');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A3A3)),
                      child: const Text('🚀 강제메인이동', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await AuthService.forceSetActiveStatus();
                        _showSnackBar('상태가 ACTIVE로 설정되었습니다', Colors.green);
                        await _debugTokenStatus();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text('🎉 ACTIVE설정', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await AuthService.clearAllUserData();
                        print('✅ 모든 데이터 삭제 완료');
                        _showSnackBar('모든 데이터가 삭제되었습니다', Colors.red);
                        await _debugTokenStatus();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('🗑️ 데이터삭제', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 🔧 안전한 전화번호 포맷터 (RangeError 방지)
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
      print('❌ PhoneNumberFormatter 오류: $e');
      // 오류 발생 시 숫자만 남기고 반환
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
    if (digits.isEmpty) return '';

    try {
      if (digits.length <= 3) {
        return digits;
      } else if (digits.length <= 7) {
        return '${digits.substring(0, 3)}-${digits.substring(3)}';
      } else {
        // 안전한 범위 확인
        int firstPart = 3;
        int secondPart = 7;

        if (digits.length < secondPart) {
          secondPart = digits.length;
        }

        return '${digits.substring(0, firstPart)}-${digits.substring(firstPart, secondPart)}-${digits.substring(secondPart)}';
      }
    } catch (e) {
      print('❌ _formatPhoneNumber 오류: $e');
      return digits;
    }
  }
}