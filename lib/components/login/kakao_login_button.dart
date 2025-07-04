import 'package:flutter/material.dart';

class KakaoLoginButton extends StatelessWidget {
  final bool isLoading;
  final bool isWorker;
  final VoidCallback? onPressed;

  const KakaoLoginButton({
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
        color: const Color(0xFFFFE812), // 카카오 노란색
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFE812).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3A1D1D)),
          ),
        )
            : Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF3A1D1D),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'K',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFE812),
              ),
            ),
          ),
        ),
        label: Text(
          isLoading ? '' : '카카오로 시작하기',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A1D1D),
          ),
        ),
      ),
    );
  }
}