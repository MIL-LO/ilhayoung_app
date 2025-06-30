import 'package:flutter/material.dart';

class GoogleLoginButton extends StatelessWidget {
  final bool isLoading;
  final bool isWorker;
  final VoidCallback? onPressed;

  const GoogleLoginButton({
    Key? key,
    required this.isLoading,
    required this.isWorker,
    this.onPressed,
  }) : super(key: key);

  Color get _primaryColor => isWorker
      ? const Color(0xFF00A3A3)
      : const Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(
                Icons.g_mobiledata,
                color: Colors.white,
                size: 22,
              ),
        label: Text(
          isLoading ? '' : 'Google로 시작하기',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}