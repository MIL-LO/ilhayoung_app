import 'package:flutter/material.dart';

class JejuMessageCard extends StatelessWidget {
  final bool isWorker;

  const JejuMessageCard({
    Key? key,
    required this.isWorker,
  }) : super(key: key);

  Color get _primaryColor => isWorker
      ? const Color(0xFF00A3A3)
      : const Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWorker ? Colors.teal[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            isWorker
                ? '🌊 제주 바다에서 꿈을 펼치세요'
                : '🏔️ 현무암 위에서 사업을 키우세요',
            style: TextStyle(
              fontSize: 15,
              color: _primaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isWorker
                ? '청정 제주에서 새로운 시작을 도와드릴게요'
                : '든든한 파트너와 함께 성장해보세요',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}