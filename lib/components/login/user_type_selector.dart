import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserTypeSelector extends StatelessWidget {
  final bool isWorker;
  final Function(bool) onTypeChanged;

  const UserTypeSelector({
    Key? key,
    required this.isWorker,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            text: '🌊 구직자',
            isSelected: isWorker,
            onTap: () => onTypeChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeButton(
            text: '🏔️ 자영업자',
            isSelected: !isWorker,
            onTap: () => onTypeChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = isSelected
        ? (text.contains('구직자')
            ? const Color(0xFF00A3A3)
            : const Color(0xFF2D2D2D))
        : Colors.grey[600];

    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor! : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}