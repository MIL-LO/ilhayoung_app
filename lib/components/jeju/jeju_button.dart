import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/theme/app_theme.dart';

enum JejuButtonStyle {
  ocean,      // 에메랄드 바다
  basalt,     // 현무암
  sunset,     // 제주 노을
  secondary,  // 보조 버튼
  destructive // 삭제/위험
}

class JejuButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final JejuButtonStyle style;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;

  const JejuButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style = JejuButtonStyle.ocean,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
  }) : super(key: key);

  @override
  State<JejuButton> createState() => _JejuButtonState();
}

class _JejuButtonState extends State<JejuButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    if (widget.style == JejuButtonStyle.ocean) {
      _shimmerController.repeat(period: const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  LinearGradient get gradient {
    switch (widget.style) {
      case JejuButtonStyle.ocean:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            JejuTheme.emeraldBright,
            JejuTheme.emeraldDeep,
          ],
        );
      case JejuButtonStyle.basalt:
        return JejuTheme.basaltGradient;
      case JejuButtonStyle.sunset:
        return JejuTheme.sunsetGradient;
      case JejuButtonStyle.secondary:
        return const LinearGradient(
          colors: [
            JejuTheme.stoneBeige,
            Color(0xFFEEECE9),
          ],
        );
      case JejuButtonStyle.destructive:
        return const LinearGradient(
          colors: [
            JejuTheme.systemRed,
            Color(0xFFCC2A41),
          ],
        );
    }
  }

  Color get foregroundColor {
    switch (widget.style) {
      case JejuButtonStyle.secondary:
        return JejuTheme.basaltDark;
      default:
        return Colors.white;
    }
  }

  List<BoxShadow> get shadows {
    if (widget.style == JejuButtonStyle.secondary || widget.isLoading) {
      return [];
    }

    Color shadowColor;
    switch (widget.style) {
      case JejuButtonStyle.ocean:
        shadowColor = JejuTheme.emeraldBright;
        break;
      case JejuButtonStyle.basalt:
        shadowColor = JejuTheme.basaltDark;
        break;
      case JejuButtonStyle.sunset:
        shadowColor = JejuTheme.sunsetOrange;
        break;
      default:
        shadowColor = JejuTheme.systemRed;
    }

    return [
      BoxShadow(
        color: shadowColor.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: shadowColor.withOpacity(0.1),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height ?? 56,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: shadows,
            border: widget.style == JejuButtonStyle.secondary
                ? Border.all(
              color: JejuTheme.basaltLight.withOpacity(0.2),
              width: 1,
            )
                : null,
          ),
          child: Stack(
            children: [
              // shimmer 효과 (바다 버튼에만)
              if (widget.style == JejuButtonStyle.ocean && !widget.isLoading)
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                            end: Alignment(-0.5 + _shimmerAnimation.value, 0.0),
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // 버튼 콘텐츠
              CupertinoButton(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(18),
                onPressed: widget.isLoading ? null : widget.onPressed,
                child: widget.isLoading
                    ? CupertinoActivityIndicator(
                  color: foregroundColor,
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: foregroundColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        fontFamily: '.SF Pro Text',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}