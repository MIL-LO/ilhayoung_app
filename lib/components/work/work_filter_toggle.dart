import 'package:flutter/material.dart';

class WorkFilterToggle extends StatelessWidget {
  final bool showMyWorkOnly;
  final Function(bool) onToggle;

  const WorkFilterToggle({
    Key? key,
    required this.showMyWorkOnly,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '필터',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                '내 근무만 보기',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onToggle(!showMyWorkOnly),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: showMyWorkOnly
                      ? const Color(0xFF00A3A3)
                      : Colors.grey[300],
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: showMyWorkOnly
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: showMyWorkOnly
                        ? const Icon(
                            Icons.person,
                            size: 16,
                            color: Color(0xFF00A3A3),
                          )
                        : Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}