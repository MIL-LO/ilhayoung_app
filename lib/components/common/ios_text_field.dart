import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';

class IosTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const IosTextField({
    Key? key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  State<IosTextField> createState() => _IosTextFieldState();
}

class _IosTextFieldState extends State<IosTextField> {
  bool _isObscured = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ),

        // 텍스트 필드
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.secondaryBackground,
            border: _isFocused
                ? Border.all(color: AppTheme.primaryBlue, width: 2)
                : Border.all(color: Colors.transparent, width: 2),
            boxShadow: _isFocused
                ? [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
            },
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.isPassword && _isObscured,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              onChanged: widget.onChanged,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                fontFamily: '.SF Pro Text',
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                  widget.prefixIcon,
                  color: _isFocused ? AppTheme.primaryBlue : AppTheme.textSecondary,
                  size: 20,
                )
                    : null,
                suffixIcon: widget.isPassword
                    ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                  child: Icon(
                    _isObscured ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}