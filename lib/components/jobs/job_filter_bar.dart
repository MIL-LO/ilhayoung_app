// lib/components/jobs/job_filter_bar.dart
import 'package:flutter/material.dart';

class JobFilterBar extends StatelessWidget {
  final String selectedLocation;
  final String selectedJobType;
  final String selectedWage;
  final String searchQuery;
  final Function(String) onLocationChanged;
  final Function(String) onJobTypeChanged;
  final Function(String) onWageChanged;
  final Function(String) onSearchChanged;

  const JobFilterBar({
    Key? key,
    required this.selectedLocation,
    required this.selectedJobType,
    required this.selectedWage,
    required this.searchQuery,
    required this.onLocationChanged,
    required this.onJobTypeChanged,
    required this.onWageChanged,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색 바
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: '공고 제목, 회사명으로 검색',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 필터 칩들
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // 지역 필터
                _buildFilterChip(
                  label: '지역: $selectedLocation',
                  isSelected: selectedLocation != '전체',
                  onTap: () => _showLocationFilter(context),
                ),
                const SizedBox(width: 8),

                // 업종 필터
                _buildFilterChip(
                  label: '업종: $selectedJobType',
                  isSelected: selectedJobType != '전체',
                  onTap: () => _showJobTypeFilter(context),
                ),
                const SizedBox(width: 8),

                // 시급 필터
                _buildFilterChip(
                  label: '시급: $selectedWage',
                  isSelected: selectedWage != '전체',
                  onTap: () => _showWageFilter(context),
                ),
                const SizedBox(width: 8),

                // 초기화 버튼
                if (selectedLocation != '전체' ||
                    selectedJobType != '전체' ||
                    selectedWage != '전체')
                  _buildFilterChip(
                    label: '초기화',
                    isSelected: false,
                    onTap: () {
                      onLocationChanged('전체');
                      onJobTypeChanged('전체');
                      onWageChanged('전체');
                    },
                    isReset: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isReset = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isReset
              ? Colors.red[50]
              : isSelected
              ? const Color(0xFF2D3748)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReset
                ? Colors.red[300]!
                : isSelected
                ? const Color(0xFF2D3748)
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isReset
                ? Colors.red[700]
                : isSelected
                ? Colors.white
                : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  void _showLocationFilter(BuildContext context) {
    final locations = ['전체', '제주시', '서귀포시', '한림읍', '애월읍', '조천읍', '구좌읍'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '지역 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: locations.map((location) {
                final isSelected = selectedLocation == location;
                return GestureDetector(
                  onTap: () {
                    onLocationChanged(location);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D3748) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      location,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showJobTypeFilter(BuildContext context) {
    final jobTypes = [
      '전체',
      '카페·음료',
      '식당·주방',
      '편의점',
      '소매·판매',
      '레저·스포츠',
      '농업',
      '숙박·관광',
      '기타'
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '업종 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: jobTypes.map((jobType) {
                final isSelected = selectedJobType == jobType;
                return GestureDetector(
                  onTap: () {
                    onJobTypeChanged(jobType);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D3748) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      jobType,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showWageFilter(BuildContext context) {
    final wages = ['전체', '9,620원 이상', '10,000원 이상', '12,000원 이상', '15,000원 이상'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '시급 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: wages.map((wage) {
                final isSelected = selectedWage == wage;
                return GestureDetector(
                  onTap: () {
                    onWageChanged(wage);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D3748) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2D3748) : Colors.grey[200]!,
                      ),
                    ),
                    child: Text(
                      wage,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}