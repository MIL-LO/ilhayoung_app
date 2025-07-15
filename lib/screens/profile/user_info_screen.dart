// lib/screens/profile/user_info_screen.dart - 수정 기능 추가

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/enums/user_type.dart';
import '../../services/user_info_service.dart';
import '../../components/common/unified_app_header.dart';
import 'user_info_edit_screen.dart'; // 🔥 수정 화면 import

class UserInfoScreen extends StatefulWidget {
  final UserType userType;

  const UserInfoScreen({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userInfo;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await UserInfoService.getCurrentUserInfo();

      if (mounted) {
        if (result['success']) {
          setState(() {
            _userInfo = result['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = result['error'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '정보를 불러오는 중 오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmployer = widget.userType == UserType.manager;
    final Color primaryColor = isEmployer
        ? const Color(0xFF2D3748)
        : const Color(0xFF00A3A3);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '내 정보',
        subtitle: isEmployer ? '사업자 정보' : '구직자 정보',
        emoji: isEmployer ? '🏢' : '👤',
        showBackButton: true,
        backgroundColor: const Color(0xFFF8FFFE),
        foregroundColor: primaryColor,
        // 🔥 수정 버튼 추가 (STAFF인 경우만)
        actions: _userInfo != null && _userInfo!['userType'] == 'STAFF'
            ? [
          IconButton(
            onPressed: _showEditScreen,
            icon: const Icon(Icons.edit),
            tooltip: '정보 수정',
          ),
        ]
            : null,
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _errorMessage != null
          ? _buildErrorWidget(primaryColor)
          : _buildUserInfoWidget(primaryColor, isEmployer),
    );
  }

  // 🔥 수정 화면 이동
  void _showEditScreen() {
    if (_userInfo == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoEditScreen(
          userType: widget.userType,
          userInfo: _userInfo!,
          onSaved: (updatedData) {
            // 수정된 데이터로 화면 업데이트
            setState(() {
              _userInfo = {..._userInfo!, ...updatedData};
            });
          },
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF00A3A3)),
          SizedBox(height: 16),
          Text(
            '사용자 정보를 불러오는 중...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              '정보를 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '알 수 없는 오류가 발생했습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoWidget(Color primaryColor, bool isEmployer) {
    if (_userInfo == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 프로필 카드
          _buildProfileCard(primaryColor, isEmployer),
          const SizedBox(height: 24),

          // 기본 정보
          _buildInfoSection('기본 정보', primaryColor, [
            _buildInfoItem('이름', _getDisplayName(), Icons.person),
            _buildInfoItem('이메일', _userInfo!['email'] ?? '정보 없음', Icons.email),
            _buildInfoItem('사용자 타입', _getUserTypeText(), Icons.category),
            _buildInfoItem('가입일', _formatDate(_userInfo!['createdAt']), Icons.calendar_today),
          ]),

          const SizedBox(height: 20),

          // 상세 정보 (STAFF인 경우만)
          if (_userInfo!['userType'] == 'STAFF') ...[
            _buildInfoSection('상세 정보', primaryColor, [
              _buildInfoItem('생년월일', _userInfo!['birthDate'] ?? '정보 없음', Icons.cake),
              _buildInfoItem('연락처', _userInfo!['phone'] ?? '정보 없음', Icons.phone),
              _buildInfoItem('주소', _userInfo!['address'] ?? '정보 없음', Icons.location_on),
              _buildInfoItem('경험', _userInfo!['experience'] ?? '정보 없음', Icons.work_outline),
            ]),
            const SizedBox(height: 20),

            // 🔥 수정 안내 카드 (STAFF만)
            _buildEditInfoCard(primaryColor),
            const SizedBox(height: 20),
          ],

          // 계정 정보
          _buildInfoSection('계정 정보', primaryColor, [
            _buildInfoItem('사용자 ID', _userInfo!['userId'] ?? '정보 없음', Icons.fingerprint),
            _buildInfoItem('OAuth 제공자', _getProviderText(), Icons.login),
            _buildInfoItem('Provider ID', _userInfo!['providerId'] ?? '정보 없음', Icons.vpn_key),
          ]),

          const SizedBox(height: 32),

          // 버튼들
          Row(
            children: [
              // 새로고침 버튼
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loadUserInfo,
                  icon: const Icon(Icons.refresh),
                  label: const Text('새로고침'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // 🔥 수정 버튼 (STAFF만)
              if (_userInfo!['userType'] == 'STAFF') ...[
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showEditScreen,
                    icon: const Icon(Icons.edit),
                    label: const Text('정보 수정'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 100), // 하단 여백
        ],
      ),
    );
  }

  // 🔥 수정 안내 카드
  Widget _buildEditInfoCard(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit_outlined,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '정보 수정 가능',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '연락처, 주소, 경험 정보를 수정할 수 있습니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: primaryColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Color primaryColor, bool isEmployer) {
    final name = _getDisplayName();
    final email = _userInfo!['email'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEmployer
              ? [const Color(0xFF2D3748), const Color(0xFF4A5568)]
              : [const Color(0xFF00A3A3), const Color(0xFF00B8B8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              isEmployer ? Icons.business : Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, Color primaryColor, List<Widget> items) {
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00A3A3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF00A3A3), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onLongPress: () {
                    // 길게 누르면 클립보드에 복사
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$label 복사됨: $value'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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

  // 🎯 개선된 이름 표시 로직
  String _getDisplayName() {
    // 1. 백엔드에서 제공하는 name 필드 우선 사용
    if (_userInfo!['name'] != null && _userInfo!['name'].toString().isNotEmpty) {
      return _userInfo!['name'];
    }

    // 2. 이메일에서 사용자명 추출 (@ 앞부분)
    final email = _userInfo!['email'] ?? '';
    if (email.isNotEmpty && email.contains('@')) {
      final username = email.split('@')[0];
      // 이메일 username이 의미있는 경우 사용
      if (username.length > 2) {
        return username;
      }
    }

    // 3. 사용자 타입에 따른 기본 이름
    final userType = _userInfo!['userType'] ?? '';
    switch (userType) {
      case 'STAFF':
        return '구직자';
      case 'MANAGER':
        return '사업자';
      default:
        return '사용자';
    }
  }

  String _getUserTypeText() {
    final userType = _userInfo!['userType'];
    switch (userType) {
      case 'STAFF':
        return '구직자 👷‍♀️';
      case 'MANAGER':
        return '사업자 👔';
      default:
        return userType ?? '알 수 없음';
    }
  }

  // 🎯 OAuth 제공자 표시 개선
  String _getProviderText() {
    final provider = _userInfo!['provider']?.toString().toLowerCase();
    switch (provider) {
      case 'kakao':
        return '카카오 🟡';
      case 'google':
        return '구글 🔴';
      case 'naver':
        return '네이버 🟢';
      default:
        return provider ?? '정보 없음';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '정보 없음';

    try {
      final date = DateTime.parse(dateString);
      return '${date.year}년 ${date.month}월 ${date.day}일';
    } catch (e) {
      return dateString;
    }
  }
}