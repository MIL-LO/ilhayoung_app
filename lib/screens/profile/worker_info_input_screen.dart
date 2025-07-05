// lib/screens/profile/worker_info_input_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod import 추가
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences import 추가
import '../../core/enums/user_type.dart';
import '../../components/common/unified_app_header.dart';
import '../../services/signup_service.dart'; // SignupService import 추가
import '../../services/auth_service.dart'; // AuthService import 추가
import '../../providers/auth_state_provider.dart'; // AuthStateProvider import 추가
import '../auth/auth_wrapper.dart'; // AuthWrapper import 추가

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

  // 폼 컨트롤러들
  final _formKey = GlobalKey<FormState>();
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
        showBackButton: true, // 🔥 뒤로가기 버튼 추가!
        onBackPressed: () {
          print('🎯 UnifiedAppHeader onBackPressed 호출됨!'); // 디버깅 로그
          _handleBackPress(); // 커스텀 뒤로가기 동작
        },
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
                      // 🚨 임시 디버깅 섹션 - 이미 가입된 사용자인 경우
                      _buildCurrentStatusDebug(),
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),
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

  // 🔙 커스텀 뒤로가기 처리 - 로그인 화면으로 이동
  void _handleBackPress() {
    print('🔙 _handleBackPress 호출됨!'); // 디버깅 로그

    // 입력된 정보가 있는지 확인
    bool hasInputData = _selectedBirthDate != null ||
        _phoneController.text.isNotEmpty ||
        _selectedCity != null ||
        _selectedDistrict != null ||
        _dongController.text.isNotEmpty ||
        _experienceController.text.isNotEmpty;

    print('📋 입력된 데이터 존재: $hasInputData'); // 디버깅 로그
    print('  - 생년월일: ${_selectedBirthDate != null}');
    print('  - 연락처: ${_phoneController.text.isNotEmpty}');
    print('  - 도시: ${_selectedCity != null}');
    print('  - 구역: ${_selectedDistrict != null}');
    print('  - 동: ${_dongController.text.isNotEmpty}');
    print('  - 경험: ${_experienceController.text.isNotEmpty}');

    if (hasInputData) {
      print('⚠️ 확인 다이얼로그 표시'); // 디버깅 로그
      // 입력된 정보가 있으면 확인 다이얼로그 표시
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
              onPressed: () {
                print('❌ 취소 버튼 클릭'); // 디버깅 로그
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                print('✅ 나가기 버튼 클릭'); // 디버깅 로그
                Navigator.pop(context); // 다이얼로그 닫기
                _goToLoginScreen(); // 로그인 화면으로 이동
              },
              child: Text(
                '나가기',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        ),
      );
    } else {
      print('🚀 바로 로그인 화면으로 이동'); // 디버깅 로그
      // 입력된 정보가 없으면 바로 로그인 화면으로 이동
      _goToLoginScreen();
    }
  }

  // 🏠 로그인 화면으로 이동 - 로그아웃 처리 포함 (🔥 async로 변경)
  Future<void> _goToLoginScreen() async {
    print('🏠 로그인 화면으로 이동 - 로그아웃 처리 시작');

    try {
      print('📞 AuthService.logout() 호출 중...');
      // 🔥 핵심: 로그아웃 처리로 인증 상태 초기화
      final logoutSuccess = await AuthService.logout();
      print('✅ 로그아웃 처리 완료: $logoutSuccess');

      // 🔍 로그아웃 후 상태 확인
      print('🔍 로그아웃 후 상태 확인:');
      final isLoggedIn = await AuthService.isLoggedIn();
      final needsSignup = await AuthService.needsSignup();
      print('  - isLoggedIn: $isLoggedIn');
      print('  - needsSignup: $needsSignup');

      // Navigator 스택을 모두 제거하고 AuthWrapper로 이동
      // AuthWrapper가 인증 상태를 다시 확인하여 로그인 화면으로 보냄
      if (mounted) {
        print('🚀 AuthWrapper로 네비게이션 시작...');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthWrapper()),
              (route) => false, // 모든 이전 화면 제거
        );
        print('✅ AuthWrapper로 네비게이션 완료');
      }

    } catch (e) {
      print('❌ 로그아웃 처리 중 오류: $e');

      // 🛡️ 오류가 발생해도 강제로 로컬 데이터 삭제 시도
      try {
        print('🛡️ 수동 데이터 삭제 시도...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print('✅ 수동 데이터 삭제 완료');
      } catch (clearError) {
        print('❌ 수동 데이터 삭제 실패: $clearError');
      }

      // 오류가 발생해도 AuthWrapper로 이동 (안전장치)
      if (mounted) {
        print('🚀 강제 AuthWrapper로 네비게이션...');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthWrapper()),
              (route) => false,
        );
        print('✅ 강제 AuthWrapper로 네비게이션 완료');
      }
    }
  }

  // 🚨 임시 디버깅 섹션 - 현재 상태 확인 및 자동 수정
  Widget _buildCurrentStatusDebug() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Column(
        children: [
          Text(
            '🚨 이미 가입된 사용자입니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '회원가입 화면이 나오면 안 되는 상황입니다.\n현재 상태를 확인하고 수정합니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    print('🔍 현재 상태 확인 버튼 클릭');
                    await AuthService.debugStoredData();
                  },
                  icon: const Icon(Icons.search, size: 16),
                  label: const Text('현재 상태 확인', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[500],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    print('🔧 자동 수정 버튼 클릭');

                    // 1. 사용자 상태를 ACTIVE로 업데이트
                    await AuthService.forceUpdateToVerified();

                    // 2. AuthStateProvider 새로고침
                    ref.read(authStateProvider.notifier).refresh();

                    // 3. AuthWrapper로 이동하여 상태 재확인
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => AuthWrapper()),
                            (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: const Text('자동 수정', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
    print('=== 회원가입 폼 제출 시작 ===');

    // 폼 유효성 검사
    if (!_formKey.currentState!.validate()) {
      print('폼 유효성 검사 실패');
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
      // 생년월일을 API 형식으로 변환 (YYYY-MM-DD)
      String birthDate = "${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}";

      // 주소 조합
      String address = '$_selectedCity $_selectedDistrict';
      if (_dongController.text.trim().isNotEmpty) {
        address += ' ${_dongController.text.trim()}';
      }

      // 경험 입력 (빈 값이면 기본 메시지)
      String experience = _experienceController.text.trim();
      if (experience.isEmpty) {
        experience = '경험 없음';
      }

      print('회원가입 데이터 준비 완료:');
      print('- 생년월일: $birthDate');
      print('- 연락처: ${_phoneController.text.trim()}');
      print('- 주소: $address');
      print('- 경험: $experience');

      // SignupService를 통해 API 호출
      final result = await SignupService.completeStaffSignup(
        birthDate: birthDate,
        phone: _phoneController.text.trim(),
        address: address,
        experience: experience,
      );

      if (mounted) {
        if (result['success']) {
          print('✅ 회원가입 성공!');

          // 🔥 회원가입 성공 시 사용자 상태를 ACTIVE로 업데이트하여 자동 로그인 활성화
          await AuthService.updateUserStatusToVerified();
          print('✅ 사용자 상태 ACTIVE로 업데이트 완료 (자동 로그인 활성화)');

          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '회원가입이 완료되었습니다!'),
              backgroundColor: const Color(0xFF00A3A3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          // 🔥 잠깐 기다린 후 콜백 실행 (AuthStateProvider에서 자동 로그인 활성화)
          await Future.delayed(const Duration(milliseconds: 500));
          widget.onComplete(UserType.worker);

        } else {
          print('❌ 회원가입 실패: ${result['error']}');

          // 실패 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? '회원가입에 실패했습니다'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ 회원가입 처리 중 예외 발생: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
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
}

// 🔥 완전히 새로 작성된 안전한 PhoneNumberFormatter
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue,) {
    try {
      // 숫자만 추출
      String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

      // 빈 문자열 처리
      if (digits.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      // 최대 11자리로 제한
      if (digits.length > 11) {
        digits = digits.substring(0, 11);
      }

      // 안전한 포맷팅
      String formatted = _safeFormatPhoneNumber(digits);

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } catch (e) {
      // 모든 오류 상황에서 안전한 처리
      print('PhoneNumberFormatter 오류: $e');

      // 숫자만 추출해서 반환 (포맷팅 없이)
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

  String _safeFormatPhoneNumber(String digits) {
    try {
      // 길이별 안전한 포맷팅
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
        // 010-1234
          return '${digits.substring(0, 3)}-${digits.substring(3)}';
        case 8:
        case 9:
        case 10:
        case 11:
        default:
        // 010-1234-5678
          return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits
              .substring(7)}';
      }
    } catch (e) {
      // 포맷팅 실패 시 원본 반환
      print('_safeFormatPhoneNumber 오류: $e');
      return digits;
    }
  }
}