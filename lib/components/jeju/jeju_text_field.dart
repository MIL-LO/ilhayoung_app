import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';

class JejuTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const JejuTextField({
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
  State<JejuTextField> createState() => _JejuTextFieldState();
}

class _JejuTextFieldState extends State<JejuTextField>
    with SingleTickerProviderStateMixin {
  bool _isObscured = true;
  bool _isFocused = false;
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: JejuTheme.basaltDark,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ),

        // 텍스트 필드
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    _isFocused
                        ? JejuTheme.emeraldFoam.withOpacity(0.3)
                        : JejuTheme.stoneBeige.withOpacity(0.5),
                  ],
                ),
                border: Border.all(
                  color: _isFocused
                      ? JejuTheme.emeraldBright
                      : JejuTheme.basaltLight.withOpacity(0.2),
                  width: _isFocused ? 2.5 : 1.5,
                ),
                boxShadow: _isFocused
                    ? [
                  BoxShadow(
                    color: JejuTheme.emeraldBright.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: JejuTheme.emeraldBright.withOpacity(0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ]
                    : [
                  BoxShadow(
                    color: JejuTheme.basaltDark.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isFocused = hasFocus;
                  });

                  if (hasFocus) {
                    _focusController.forward();
                  } else {
                    _focusController.reverse();
                  }
                },
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: widget.isPassword && _isObscured,
                  keyboardType: widget.keyboardType,
                  validator: widget.validator,
                  onChanged: widget.onChanged,
                  style: const TextStyle(
                    fontSize: 17,
                    color: JejuTheme.basaltDark,
                    fontFamily: '.SF Pro Text',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(
                      color: JejuTheme.basaltLight.withOpacity(0.7),
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    prefixIcon: widget.prefixIcon != null
                        ? Container(
                      margin: const EdgeInsets.only(left: 8, right: 8),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? JejuTheme.emeraldBright
                            : JejuTheme.basaltLight,
                        size: 22,
                      ),
                    )
                        : null,
                    suffixIcon: widget.isPassword
                        ? Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isObscured
                                ? JejuTheme.basaltLight.withOpacity(0.1)
                                : JejuTheme.emeraldBright.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _isObscured ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                            color: _isObscured
                                ? JejuTheme.basaltLight
                                : JejuTheme.emeraldBright,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}