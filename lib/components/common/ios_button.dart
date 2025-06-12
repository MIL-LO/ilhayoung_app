import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';

enum IosButtonStyle { primary, secondary, worker, employer, destructive }

class IosButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IosButtonStyle style;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;

  const IosButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.style = IosButtonStyle.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
  }) : super(key: key);

  @override
  State<IosButton> createState() => _IosButtonState();
}

class _IosButtonState extends State<IosButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  Color get backgroundColor {
    switch (widget.style) {
      case IosButtonStyle.primary:
        return AppTheme.primaryBlue;
      case IosButtonStyle.secondary:
        return AppTheme.secondaryBackground;
      case IosButtonStyle.worker:
        return AppTheme.primaryBlue;
      case IosButtonStyle.employer:
        return AppTheme.primaryOrange;
      case IosButtonStyle.destructive:
        return AppTheme.systemRed;
    }
  }

  Color get foregroundColor {
    switch (widget.style) {
      case IosButtonStyle.secondary:
        return AppTheme.primaryBlue;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height ?? 50,
          decoration: BoxDecoration(
            gradient: widget.style == IosButtonStyle.secondary
                ? null
                : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor,
                backgroundColor.withOpacity(0.8),
              ],
            ),
            color: widget.style == IosButtonStyle.secondary ? backgroundColor : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.style != IosButtonStyle.secondary && !widget.isLoading
                ? [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(14),
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
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: '.SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}