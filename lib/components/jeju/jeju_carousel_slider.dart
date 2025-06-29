import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';

class JejuCarouselSlider extends StatefulWidget {
  final double height;
  final Duration autoPlayDuration;
  final bool showIndicators;
  final bool showText;

  const JejuCarouselSlider({
    Key? key,
    this.height = 120,
    this.autoPlayDuration = const Duration(seconds: 3),
    this.showIndicators = false,
    this.showText = false,
  }) : super(key: key);

  @override
  State<JejuCarouselSlider> createState() => _JejuCarouselSliderState();
}

class _JejuCarouselSliderState extends State<JejuCarouselSlider> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  final List<JejuIconData> _icons = [
    JejuIconData(emoji: '🌊', label: '바다'),
    JejuIconData(emoji: '🏔️', label: '한라산'),
    JejuIconData(emoji: '🍊', label: '감귤'),
    JejuIconData(emoji: '🌺', label: '자연'),
    JejuIconData(emoji: '☁️', label: '하늘'),
    JejuIconData(emoji: '🐚', label: '해변'),
    JejuIconData(emoji: '🌿', label: '숲'),
    JejuIconData(emoji: '⭐', label: '별'),
  ];

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
        final nextIndex = (_currentIndex + 1) % 2;
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
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: 2,
          itemBuilder: (context, pageIndex) {
            return _buildIconGrid(pageIndex);
          },
        ),
      ),
    );
  }

  Widget _buildIconGrid(int pageIndex) {
    final startIndex = pageIndex * 4;
    final endIndex = (startIndex + 4).clamp(0, _icons.length);
    final pageIcons = _icons.sublist(startIndex, endIndex);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: pageIcons.map((iconData) => _buildIconItem(iconData)).toList(),
      ),
    );
  }

  Widget _buildIconItem(JejuIconData iconData) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF00A3A3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00A3A3).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                iconData.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (widget.showText)
            Text(
              iconData.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

// 📊 아이콘 데이터 모델
class JejuIconData {
  final String emoji;
  final String label;

  JejuIconData({
    required this.emoji,
    required this.label,
  });
}