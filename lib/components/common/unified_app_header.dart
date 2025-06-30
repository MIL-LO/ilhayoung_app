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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: leading,
      title: _buildTitle(),
      actions: actions,
      bottom: subtitle != null ? _buildSubtitleBar() : null,
    );
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

  // 뒤로가기 포함
  static Widget withBack() {
    return const UnifiedAppHeader(
      title: '일자리 상세',
      leading: BackButton(),
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
}