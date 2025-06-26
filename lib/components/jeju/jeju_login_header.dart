import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class JejuLoginHeader extends StatefulWidget {
  final Widget? logoWidget;

  const JejuLoginHeader({Key? key, this.logoWidget}) : super(key: key);

  @override
  State<JejuLoginHeader> createState() => _JejuLoginHeaderState();
}

class _JejuLoginHeaderState extends State<JejuLoginHeader>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _cloudController;
  late Animation<double> _waveAnimation;
  late Animation<double> _cloudAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _cloudController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _cloudAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _cloudController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _waveController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = ResponsiveHelper.isMobile(context) ? 120.0 : 140.0;
    final titleSize = ResponsiveHelper.getFontSize(context, 36);
    final subtitleSize = ResponsiveHelper.getFontSize(context, 16);

    return Container(
      height: ResponsiveHelper.isMobile(context) ? 320 : 380,
      decoration: const BoxDecoration(
        gradient: JejuTheme.jejuOceanGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          // 현무암 레이어 (바닥)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    JejuTheme.basaltDark.withOpacity(0.3),
                    JejuTheme.basaltDark.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),

          // 바다 파도 애니메이션
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 40),
                  painter: WavePainter(_waveAnimation.value),
                ),
              );
            },
          ),

          // 구름 애니메이션
          AnimatedBuilder(
            animation: _cloudAnimation,
            builder: (context, child) {
              return Positioned(
                top: 30,
                left: -100 + (_cloudAnimation.value * (MediaQuery.of(context).size.width + 200)),
                child: Container(
                  width: 80,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              );
            },
          ),

          // 메인 콘텐츠
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 32,
                vertical: ResponsiveHelper.isMobile(context) ? 40 : 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 영역 (현무암 스타일)
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          JejuTheme.basaltSoft,
                          JejuTheme.basaltMedium,
                          JejuTheme.basaltDark,
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: JejuTheme.basaltDark.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(-2, -2),
                        ),
                      ],
                    ),
                    child: widget.logoWidget ??
                        Icon(
                          CupertinoIcons.location_solid,
                          size: logoSize * 0.45,
                          color: Colors.white,
                        ),
                  ),

                  SizedBox(height: ResponsiveHelper.isMobile(context) ? 24 : 28),

                  // 앱 제목
                  Text(
                    '일하영',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: '.SF Pro Display',
                      letterSpacing: -1.5,
                      shadows: [
                        Shadow(
                          color: JejuTheme.basaltDark.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 부제목 (현무암 배경)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          JejuTheme.basaltMedium.withOpacity(0.6),
                          JejuTheme.basaltDark.withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '제주 청년 × 자영업자 연결',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.white,
                        fontFamily: '.SF Pro Text',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 제주 특색 설명
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🌊',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '현무암 위에서 시작하는 에메랄드 꿈',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontFamily: '.SF Pro Text',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '🏔️',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          JejuTheme.emeraldFoam,
          JejuTheme.emeraldLight,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 15.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = waveHeight *
          (sin((x / waveLength) * 2 * pi + (animationValue * 2 * pi)) +
              sin((x / (waveLength * 0.7)) * 2 * pi + (animationValue * 2 * pi * 1.5)) * 0.5);
      path.lineTo(x, size.height - y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}