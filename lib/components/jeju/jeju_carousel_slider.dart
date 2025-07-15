import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';

class JejuCarouselSlider extends StatefulWidget {
  final double height;
  final Duration autoPlayDuration;
  final bool showIndicators;
  final bool showText;
  final Map<String, int>? categoryCounts; // 카테고리별 공고 수

  JejuCarouselSlider({
    Key? key,
    this.height = 120,
    this.autoPlayDuration = const Duration(seconds: 3),
    this.showIndicators = false,
    this.showText = true,
    this.categoryCounts,
  }) : super(key: key);

  @override
  State<JejuCarouselSlider> createState() => _JejuCarouselSliderState();
}

class _JejuCarouselSliderState extends State<JejuCarouselSlider> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  // jobType에 따른 아이콘 매핑
  final Map<String, CategoryIconData> _categoryIcons = {
    '카페/음료': CategoryIconData(
      category: '카페/음료',
      emoji: '☕',
      label: '카페',
      description: '카페/음료',
    ),
    '음식점/요리': CategoryIconData(
      category: '음식점/요리',
      emoji: '🍽️',
      label: '음식점',
      description: '음식점/요리',
    ),
    '매장/판매': CategoryIconData(
      category: '매장/판매',
      emoji: '🛍️',
      label: '판매',
      description: '매장/판매',
    ),
    '호텔/펜션': CategoryIconData(
      category: '호텔/펜션',
      emoji: '🏨',
      label: '숙박',
      description: '호텔/펜션',
    ),
    '관광/레저': CategoryIconData(
      category: '관광/레저',
      emoji: '🏖️',
      label: '관광',
      description: '관광/레저',
    ),
    '농업/축산': CategoryIconData(
      category: '농업/축산',
      emoji: '🌾',
      label: '농업',
      description: '농업/축산',
    ),
    '건설/공사': CategoryIconData(
      category: '건설/공사',
      emoji: '🏗️',
      label: '건설',
      description: '건설/공사',
    ),
    '기타 서비스': CategoryIconData(
      category: '기타 서비스',
      emoji: '💼',
      label: '서비스',
      description: '기타 서비스',
    ),
    '전체': CategoryIconData(
      category: '전체',
      emoji: '📋',
      label: '전체',
      description: '모든 일자리',
    ),
  };

  // 실제 공고가 있는 카테고리만 필터링
  List<CategoryIconData> get _availableCategories {
    if (widget.categoryCounts == null || widget.categoryCounts!.isEmpty) {
      return [];
    }
    
    final List<CategoryIconData> categories = [];
    
    for (final entry in widget.categoryCounts!.entries) {
      final jobType = entry.key;
      final count = entry.value;
      
      if (count > 0 && _categoryIcons.containsKey(jobType)) {
        categories.add(_categoryIcons[jobType]!);
      }
    }
    
    return categories;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayDuration, (timer) {
      if (_pageController.hasClients) {
        final nextIndex = (_currentIndex + 1) % _availableCategories.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = _availableCategories;
    
    // 공고가 없을 때
    if (availableCategories.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00A3A3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00A3A3).withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '📋',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '다양한 일자리를 찾아보세요!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00A3A3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // 카테고리 아이콘들 (슬라이드당 1개)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: availableCategories.length,
                itemBuilder: (context, pageIndex) {
                  return _buildSingleCategory(pageIndex);
                },
              ),
            ),
            
            // 현재 카테고리의 공고 수 표시
            if (widget.showText && widget.categoryCounts != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A3A3).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: _buildCategoryInfo(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleCategory(int pageIndex) {
    final category = _availableCategories[pageIndex];
    final count = widget.categoryCounts?[category.category] ?? 0;
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8), // 패딩 줄임
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘
          Container(
            width: 50, // 크기 줄임
            height: 50, // 크기 줄임
            decoration: BoxDecoration(
              color: const Color(0xFF00A3A3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00A3A3).withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                category.emoji,
                style: const TextStyle(fontSize: 24), // 폰트 크기 줄임
              ),
            ),
          ),
          
          const SizedBox(height: 4), // 간격 줄임
          
          // 카테고리 라벨
          if (widget.showText)
            Flexible( // Flexible로 감싸서 오버플로우 방지
              child: Text(
                category.label,
                style: const TextStyle(
                  fontSize: 12, // 폰트 크기 줄임
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A3A3),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // 오버플로우 처리
                maxLines: 1, // 최대 1줄
              ),
            ),
          
          const SizedBox(height: 2), // 간격 줄임
          

        ],
      ),
    );
  }

  Widget _buildCategoryInfo() {
    final currentCategory = _availableCategories[_currentIndex];
    final count = widget.categoryCounts?[currentCategory.category] ?? 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentCategory.emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Text(
          '${currentCategory.label} ${count}건의 공고가 있어요!',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00A3A3),
          ),
        ),
      ],
    );
  }
}

// 📊 카테고리 아이콘 데이터 모델
class CategoryIconData {
  final String category;
  final String emoji;
  final String label;
  final String description;

  CategoryIconData({
    required this.category,
    required this.emoji,
    required this.label,
    required this.description,
  });
}