import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class IosLoginHeader extends StatelessWidget {
  final Widget? logoWidget;

  const IosLoginHeader({Key? key, this.logoWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logoSize = ResponsiveHelper.isMobile(context) ? 100.0 : 120.0;
    final titleSize = ResponsiveHelper.getFontSize(context, 34);
    final subtitleSize = ResponsiveHelper.getFontSize(context, 16);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: ResponsiveHelper.isMobile(context) ? 40 : 48,
      ),
      child: Column(
        children: [
          // 로고 영역
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: logoWidget ??
                Icon(
                  CupertinoIcons.location_solid,
                  size: logoSize * 0.5,
                  color: Colors.white,
                ),
          ),

          SizedBox(height: ResponsiveHelper.isMobile(context) ? 20 : 24),

          // 앱 제목
          Text(
            '일하영',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: '.SF Pro Display',
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 8),

          // 부제목
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '제주 청년 × 자영업자 연결',
              style: TextStyle(
                fontSize: subtitleSize,
                color: Colors.white.withOpacity(0.95),
                fontFamily: '.SF Pro Text',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 제주 이모지와 함께한 작은 설명
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🌴',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                '제주에서 시작하는 새로운 연결',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  fontFamily: '.SF Pro Text',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '🌊',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}