import 'package:flutter/material.dart';

class UnifiedAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? emoji;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const UnifiedAppHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.emoji,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔍 디버깅 로그 추가
    print('=== UnifiedAppHeader 디버깅 ===');
    print('title: $title');
    print('showBackButton: $showBackButton');
    print('leading: $leading');
    print('backgroundColor: $backgroundColor');
    print('foregroundColor: $foregroundColor');
    print('================================');

    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 숨김
      leading: _buildLeading(context),
      title: _buildTitle(),
      actions: actions,
      bottom: subtitle != null ? _buildSubtitleBar() : null,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    // 🔍 상세 디버깅 로그
    print('--- _buildLeading 디버깅 ---');
    print('leading 파라미터: $leading');
    print('showBackButton 파라미터: $showBackButton');
    print('foregroundColor: $foregroundColor');

    // 1. 커스텀 leading이 제공된 경우 우선 사용
    if (leading != null) {
      print('✅ 커스텀 leading 사용: $leading');
      return leading;
    }

    // 2. showBackButton이 true인 경우 뒤로가기 버튼 생성
    if (showBackButton) {
      print('✅ 뒤로가기 버튼 생성 중...');
      print('  - 아이콘 색상: ${foregroundColor ?? Colors.black}');
      print('  - onPressed 콜백: ${onBackPressed != null ? '커스텀' : '기본'}');

      final backButton = IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: foregroundColor ?? Colors.black,
          size: 24,
        ),
        onPressed: onBackPressed ?? () {
          print('🔙 뒤로가기 버튼 클릭 - Navigator.pop 실행');
          Navigator.pop(context);
        },
      );

      print('✅ 뒤로가기 버튼 생성 완료: $backButton');
      return backButton;
    }

    // 3. 둘 다 없으면 null 반환
    print('❌ leading 위젯 없음 - null 반환');
    return null;
  }

  Widget _buildTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (emoji != null) ...[
          Text(
            emoji!,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget? _buildSubtitleBar() {
    if (subtitle == null) return null;

    return PreferredSize(
      preferredSize: const Size.fromHeight(24),
      child: Container(
        alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
        padding: EdgeInsets.only(
          left: centerTitle ? 0 : 16,
          bottom: 8,
        ),
        child: Text(
          subtitle!,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (subtitle != null ? 24 : 0),
  );
}

// 사용 예시들:
class UnifiedAppHeaderExamples {
  // 기본 헤더
  static Widget basic() {
    return const UnifiedAppHeader(
      title: '제주 일자리',
      emoji: '🌊',
      actions: [
        Icon(Icons.search),
        Icon(Icons.filter_list),
      ],
    );
  }

  // 부제목 포함
  static Widget withSubtitle() {
    return const UnifiedAppHeader(
      title: '제주 일자리',
      subtitle: '바다처럼 넓은 기회를 찾아보세요',
      emoji: '🌊',
      centerTitle: true,
      actions: [
        Icon(Icons.search),
        Icon(Icons.filter_list),
      ],
    );
  }

  // 기존 방식: 커스텀 leading 사용
  static Widget withCustomLeading() {
    return const UnifiedAppHeader(
      title: '일자리 상세',
      leading: BackButton(),
    );
  }

  // 🆕 새로운 방식: showBackButton 사용
  static Widget withAutoBackButton() {
    return const UnifiedAppHeader(
      title: '내 정보',
      subtitle: '구직자 정보',
      emoji: '👤',
      showBackButton: true, // 자동 뒤로가기 버튼
    );
  }

  // 🆕 커스텀 뒤로가기 동작
  static Widget withCustomBackAction() {
    return UnifiedAppHeader(
      title: '중요한 정보',
      emoji: '⚠️',
      showBackButton: true,
      onBackPressed: () {
        // 커스텀 뒤로가기 동작 (예: 확인 다이얼로그)
        print('커스텀 뒤로가기 동작 실행');
      },
    );
  }

  // 커스텀 색상
  static Widget colored() {
    return const UnifiedAppHeader(
      title: '근무관리',
      emoji: '🌊',
      backgroundColor: Color(0xFF00A3A3),
      foregroundColor: Colors.white,
      elevation: 2,
    );
  }

  // 🆕 색상이 적용된 뒤로가기 버튼
  static Widget coloredWithBack() {
    return const UnifiedAppHeader(
      title: '내 정보',
      subtitle: '사업자 정보',
      emoji: '🏢',
      showBackButton: true,
      backgroundColor: Color(0xFF2D3748),
      foregroundColor: Colors.white,
      elevation: 2,
    );
  }
}