import 'package:flutter/material.dart';
import 'package:ilhayoung_app/components/common/unified_app_header.dart';
import 'package:ilhayoung_app/services/user_info_service.dart';

class HiredWorkersScreen extends StatefulWidget {
  final List<dynamic> hiredWorkers;

  const HiredWorkersScreen({
    super.key,
    required this.hiredWorkers,
  });

  @override
  State<HiredWorkersScreen> createState() => _HiredWorkersScreenState();
}

class _HiredWorkersScreenState extends State<HiredWorkersScreen> {
  Map<String, Map<String, dynamic>> _userInfoCache = {};

  @override
  void initState() {
    super.initState();
    _loadUserInfoForWorkers();
  }

  /// 고용된 직원들의 사용자 정보를 로드
  Future<void> _loadUserInfoForWorkers() async {
    for (final worker in widget.hiredWorkers) {
      final applicationId = worker['applicationId']?.toString();
      if (applicationId != null && applicationId.isNotEmpty) {
        try {
          // 지원자 ID를 사용하여 사용자 정보 조회
          final userInfo = await UserInfoService.getUserInfoById(applicationId);
          if (userInfo != null) {
            setState(() {
              _userInfoCache[applicationId] = userInfo;
            });
          }
        } catch (e) {
          print('사용자 정보 로드 실패 (ID: $applicationId): $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: const UnifiedAppHeader(
        title: '고용된 인원',
        subtitle: '고용된 직원들의 목록입니다',
        emoji: '👥',
        showBackButton: true,
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    if (widget.hiredWorkers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.hiredWorkers.length,
      itemBuilder: (context, index) {
        final worker = widget.hiredWorkers[index];
        return _buildWorkerCard(worker);
      },
    );
  }

  Widget _buildWorkerCard(Map<String, dynamic> worker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showWorkerDetail(worker),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF2D3748),
                  radius: 25,
                  child: Text(
                    worker['name']?.toString().isNotEmpty == true 
                        ? worker['name'][0].toUpperCase() 
                        : '?',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker['name']?.toString() ?? '이름 없음',
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        worker['position']?.toString() ?? '직책 없음',
                        style: TextStyle(
                          fontSize: 14, 
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        worker['companyName']?.toString() ?? '회사명 없음',
                        style: TextStyle(
                          fontSize: 13, 
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                  ),
                  child: const Text(
                    '고용됨',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '고용된 직원이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '채용공고에 지원한 인원을 고용하면\n여기에 표시됩니다',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showWorkerDetail(Map<String, dynamic> worker) {
    final applicationId = worker['applicationId']?.toString();
    final userInfo = applicationId != null ? _userInfoCache[applicationId] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF2D3748),
                        radius: 30,
                        child: Text(
                          worker['name']?.toString().isNotEmpty == true 
                              ? worker['name'][0].toUpperCase() 
                              : '?',
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker['name']?.toString() ?? '이름 없음',
                              style: const TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              worker['position']?.toString() ?? '직책 없음',
                              style: TextStyle(
                                fontSize: 16, 
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 상세 정보
                  _buildDetailItem('연락처', worker['contact']?.toString() ?? '연락처 없음', Icons.phone),
                  _buildDetailItem('주소', userInfo?['address']?.toString() ?? '주소 없음', Icons.location_on),
                  _buildDetailItem('생년월일', _formatDate(userInfo?['birthDate']), Icons.cake),
                  _buildDetailItem('고용일', _formatDate(worker['hiredDate']), Icons.work),
                  _buildDetailItem('회사명', worker['companyName']?.toString() ?? '회사명 없음', Icons.business),
                  _buildDetailItem('기후 점수', '${worker['climateScore']?.toString() ?? '0'}점', Icons.star),
                  
                  const SizedBox(height: 24),
                  
                  // 액션 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('닫기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D3748),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2D3748)),
          const SizedBox(width: 12),
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '날짜 없음';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '날짜 형식 오류';
    }
  }
} 