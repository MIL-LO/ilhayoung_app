import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_theme.dart';

class EmployerMainScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const EmployerMainScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JejuTheme.background,
      appBar: AppBar(
        title: const Text('🏔️ 자영업자 대시보드'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: JejuTheme.basaltDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: '.SF Pro Text',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: JejuTheme.basaltMedium,
            ),
            onPressed: onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // 메인 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    JejuTheme.sunsetOrange.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: JejuTheme.sunsetOrange.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: JejuTheme.sunsetOrange.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: JejuTheme.sunsetGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: JejuTheme.sunsetOrange.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.building_2_fill,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 제목
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🏔️',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '자영업자 대시보드',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: JejuTheme.sunsetOrange,
                          fontFamily: '.SF Pro Text',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 설명
                  const Text(
                    '현무암처럼 든든한 사업 파트너를\n찾아보세요\n\n자영업자용 기능은 곧 업데이트 예정입니다!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: JejuTheme.basaltMedium,
                      fontFamily: '.SF Pro Text',
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 예정된 기능들
            _buildFeaturePreview('📝 공고 등록', '인재 모집 공고를 쉽게 작성하세요'),
            const SizedBox(height: 16),
            _buildFeaturePreview('👥 지원자 관리', '지원자들을 효율적으로 관리하세요'),
            const SizedBox(height: 16),
            _buildFeaturePreview('💰 급여 관리', '급여 지급을 간편하게 처리하세요'),
            const SizedBox(height: 16),
            _buildFeaturePreview('📊 통계 분석', '사업 현황을 한눈에 파악하세요'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePreview(String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: JejuTheme.sunsetOrange.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: JejuTheme.sunsetOrange.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: JejuTheme.sunsetOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.clock,
              color: JejuTheme.sunsetOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: JejuTheme.basaltDark,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: JejuTheme.basaltMedium,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            color: JejuTheme.basaltLight,
            size: 20,
          ),
        ],
      ),
    );
  }
}