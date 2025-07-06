// lib/screens/profile/user_info_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/enums/user_type.dart';
import '../../services/user_info_update_service.dart';
import '../../components/common/unified_app_header.dart';

class UserInfoEditScreen extends StatefulWidget {
  final UserType userType;
  final Map<String, dynamic> userInfo;
  final Function(Map<String, dynamic>) onSaved;

  const UserInfoEditScreen({
    Key? key,
    required this.userType,
    required this.userInfo,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<UserInfoEditScreen> createState() => _UserInfoEditScreenState();
}

class _UserInfoEditScreenState extends State<UserInfoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isLoading = false;
  Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _phoneController.text = widget.userInfo['phone'] ?? '';
    _addressController.text = widget.userInfo['address'] ?? '';
    _experienceController.text = widget.userInfo['experience'] ?? '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmployer = widget.userType == UserType.employer;
    final Color primaryColor = isEmployer
        ? const Color(0xFF2D3748)
        : const Color(0xFF00A3A3);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '정보 수정',
        subtitle: '개인정보를 수정하세요',
        emoji: '✏️',
        showBackButton: true,
        backgroundColor: const Color(0xFFF8FFFE),
        foregroundColor: primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 안내 메시지
              _buildInfoCard(primaryColor),
              const SizedBox(height: 24),

              // 수정 폼
              _buildEditForm(primaryColor),
              const SizedBox(height: 32),

              // 저장 버튼
              _buildSaveButton(primaryColor),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: primaryColor,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            '정보 수정 안내',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• 전화번호, 주소, 경험 정보를 수정할 수 있습니다\n'
                '• 이름, 이메일 등 기본 정보는 수정할 수 없습니다\n'
                '• 수정된 정보는 즉시 반영됩니다',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            '수정 가능한 정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // 전화번호 입력
          _buildTextFormField(
            controller: _phoneController,
            label: '전화번호',
            icon: Icons.phone,
            hintText: '010-0000-0000',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            onChanged: (value) {
              // 실시간 전화번호 포맷팅
              final formatted = UserInfoUpdateService.formatPhoneNumber(value);
              if (formatted != value) {
                _phoneController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
            errorText: _errors['phone'],
          ),

          const SizedBox(height: 20),

          // 주소 입력
          _buildTextFormField(
            controller: _addressController,
            label: '주소',
            icon: Icons.location_on,
            hintText: '제주특별자치도 제주시...',
            maxLines: 2,
            errorText: _errors['address'],
          ),

          const SizedBox(height: 20),

          // 경험 입력
          _buildTextFormField(
            controller: _experienceController,
            label: '경험',
            icon: Icons.work_outline,
            hintText: '카페 아르바이트 6개월, 음식점 서빙 경험...',
            maxLines: 3,
            errorText: _errors['experience'],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    Function(String)? onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF00A3A3), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00A3A3), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '저장 중...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save, size: 20),
            const SizedBox(width: 8),
            const Text(
              '저장하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    // 입력값 검증
    final errors = UserInfoUpdateService.validateStaffInfo(
      phone: _phoneController.text,
      address: _addressController.text,
      experience: _experienceController.text,
    );

    setState(() {
      _errors = errors;
    });

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('입력값을 확인해주세요.'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // API 호출
      final result = await UserInfoUpdateService.updateStaffInfo(
        phone: _phoneController.text,
        address: _addressController.text,
        experience: _experienceController.text,
      );

      if (mounted) {
        if (result['success']) {
          // 🔥 성공 시 콜백 호출 및 화면 닫기
          widget.onSaved(result['data']);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '정보가 성공적으로 수정되었습니다.'),
              backgroundColor: Colors.green[400],
              behavior: SnackBarBehavior.floating,
            ),
          );

          // 🔥 성공 결과를 반환하면서 화면 닫기
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? '정보 수정에 실패했습니다.'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}