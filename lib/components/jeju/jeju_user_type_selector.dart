// lib/components/jeju/jeju_user_type_selector.dart

import 'package:flutter/material.dart';
import '../../core/enums/user_type.dart'; // 통합된 UserType enum 사용

// 기존의 enum UserType { ... } 코드는 완전히 제거

class JejuUserTypeSelector extends StatefulWidget {
  final UserType? selectedUserType;
  final Function(UserType) onUserTypeSelected;

  const JejuUserTypeSelector({
    Key? key,
    this.selectedUserType,
    required this.onUserTypeSelected,
  }) : super(key: key);

  @override
  State<JejuUserTypeSelector> createState() => _JejuUserTypeSelectorState();
}

class _JejuUserTypeSelectorState extends State<JejuUserTypeSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '어떤 유형의 사용자인가요?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildUserTypeCard(
                userType: UserType.worker,
                title: UserType.worker.displayName,
                subtitle: '일자리를 찾고 있어요',
                icon: '👨‍💼',
                color: const Color(0xFF16A085),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildUserTypeCard(
                userType: UserType.manager,
                title: UserType.manager.displayName,
                subtitle: '직원을 구하고 있어요',
                icon: '🏢',
                color: const Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTypeCard({
    required UserType userType,
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
  }) {
    final isSelected = widget.selectedUserType == userType;

    return GestureDetector(
      onTap: () => widget.onUserTypeSelected(userType),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}