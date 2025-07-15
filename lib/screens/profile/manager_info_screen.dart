// lib/screens/profile/manager_info_screen.dart - 사업자 정보 조회/수정 화면

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/common/unified_app_header.dart';
import '../../services/manager_info_service.dart';

class ManagerInfoScreen extends StatefulWidget {
  const ManagerInfoScreen({Key? key}) : super(key: key);

  @override
  State<ManagerInfoScreen> createState() => _ManagerInfoScreenState();
}

class _ManagerInfoScreenState extends State<ManagerInfoScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // 폼 관련
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _businessAddressController = TextEditingController();

  // 상태 변수
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _selectedBusinessType = '음식점';

  // 원본 데이터 (수정 취소 시 복원용)
  Map<String, dynamic>? _originalData;

  // 업종 목록
  final List<String> _businessTypes = [
    '음식점', '카페', '편의점', '서비스업', '소매업', '숙박업', '관광업', '농업', '기타'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadManagerInfo();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  /// 사업자 정보 로드
  Future<void> _loadManagerInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final managerInfo = await ManagerInfoService.getManagerInfo();

      if (managerInfo != null) {
        setState(() {
          _originalData = Map.from(managerInfo);
          _phoneController.text = managerInfo['phone'] ?? '';
          _businessAddressController.text = managerInfo['businessAddress'] ?? '';
          _selectedBusinessType = managerInfo['businessType'] ?? '음식점';
          _isLoading = false;
        });

        _animationController.forward();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '사업자 정보를 불러올 수 없습니다';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '사업자 정보를 불러오는 중 오류가 발생했습니다';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '사업자 정보',
        subtitle: _isEditing ? '정보를 수정하세요' : '사업자 정보를 확인하세요',
        emoji: '🏢',
        showBackButton: true,
        backgroundColor: const Color(0xFFF8FFFE),
        foregroundColor: const Color(0xFF2D3748),
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: const Color(0xFF2D3748),
              ),
              onPressed: _isSubmitting ? null : _toggleEditMode,
            ),
        ],
      ),
      body: _buildBody(),
      bottomSheet: _isEditing ? _buildUpdateButton() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2D3748)),
            SizedBox(height: 16),
            Text(
              '사업자 정보를 불러오는 중...',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadManagerInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3748),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInfoCard(),
              if (_isEditing) const SizedBox(height: 100), // 하단 버튼 여백
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
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
              Expanded(
                child: Text(
                  _isEditing ? '정보 수정' : '사업자 정보',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '수정 모드',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // 기본 정보 (읽기 전용)
          if (_originalData != null) ...[
            _buildReadOnlyField(
              '사업장명',
              _originalData!['companyName'] ?? '정보 없음',
              Icons.store,
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              '사업자명',
              _originalData!['name'] ?? '정보 없음',
              Icons.person,
            ),
            const SizedBox(height: 16),

            _buildReadOnlyField(
              '사업자등록번호',
              _originalData!['businessNumber'] ?? '정보 없음',
              Icons.badge,
            ),
            const SizedBox(height: 16),

            _buildReadOnlyField(
              '이메일',
              _originalData!['email'] ?? '정보 없음',
              Icons.email,
            ),
            const SizedBox(height: 16),

            _buildReadOnlyField(
              '생년월일',
              _originalData!['birthDate'] ?? '정보 없음',
              Icons.calendar_today,
            ),
            const SizedBox(height: 24),

            // 구분선
            Container(
              height: 1,
              color: Colors.grey[200],
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            const SizedBox(height: 16),
          ],

          // 수정 가능한 필드들
          _buildEditableField(
            controller: _phoneController,
            label: '연락처',
            hint: '010-1234-5678',
            icon: Icons.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
              PhoneNumberFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '연락처를 입력해주세요';
              }
              if (!ManagerInfoService.isValidPhoneNumber(value)) {
                return '010-XXXX-XXXX 형식으로 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildEditableField(
            controller: _businessAddressController,
            label: '사업장 주소',
            hint: '제주시 연동 123-45 오션뷰빌딩 1층',
            icon: Icons.location_on,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '사업장 주소를 입력해주세요';
              }
              if (!ManagerInfoService.isValidBusinessAddress(value)) {
                return '사업장 주소를 정확히 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildBusinessTypeDropdown(),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
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
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
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
          enabled: _isEditing,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: _isEditing
                  ? const Color(0xFF2D3748).withOpacity(0.6)
                  : Colors.grey[500],
              size: 20,
            ),
            filled: true,
            fillColor: _isEditing ? Colors.grey[50] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isEditing ? Colors.grey[300]! : Colors.grey[300]!,
              ),
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
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
            color: _isEditing ? Colors.grey[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedBusinessType,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.category,
                color: _isEditing
                    ? const Color(0xFF2D3748).withOpacity(0.6)
                    : Colors.grey[500],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
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
            onChanged: _isEditing ? (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedBusinessType = newValue;
                });
              }
            } : null,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : _cancelEdit,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2D3748)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _updateManagerInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3748),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  '💼 정보 수정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 이벤트 핸들러들
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // 수정 모드를 끄면 원본 데이터로 복원
        _restoreOriginalData();
      }
    });
  }

  void _restoreOriginalData() {
    if (_originalData != null) {
      _phoneController.text = _originalData!['phone'] ?? '';
      _businessAddressController.text = _originalData!['businessAddress'] ?? '';
      _selectedBusinessType = _originalData!['businessType'] ?? '음식점';
    }
  }

  void _cancelEdit() {
    _restoreOriginalData();
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _updateManagerInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ManagerInfoService.updateManagerInfo(
        phone: _phoneController.text.trim(),
        businessAddress: _businessAddressController.text.trim(),
        businessType: _selectedBusinessType,
      );

      if (result['success']) {
        // 성공 시 원본 데이터 업데이트
        _originalData = {
          ..._originalData!,
          'phone': _phoneController.text.trim(),
          'businessAddress': _businessAddressController.text.trim(),
          'businessType': _selectedBusinessType,
        };

        setState(() {
          _isEditing = false;
        });

        _showSnackBar(
          result['message'] ?? '사업자 정보가 수정되었습니다',
          Colors.green,
        );

        // 이전 화면으로 수정 완료 알림
        Navigator.pop(context, true);
      } else {
        _showSnackBar(
          result['error'] ?? '사업자 정보 수정에 실패했습니다',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar('사업자 정보 수정 중 오류가 발생했습니다', Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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

// 🔧 전화번호 포맷터
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
      return newValue;
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
      return digits;
    }
  }
}