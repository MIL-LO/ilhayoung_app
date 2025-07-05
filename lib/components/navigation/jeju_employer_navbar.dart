// lib/components/navigation/jeju_employer_navbar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum EmployerNavTab { createJob, manageStaff, home, salary, mypage }

class JejuEmployerNavBar extends StatefulWidget {
  final EmployerNavTab selectedTab;
  final Function(EmployerNavTab) onTabChanged;
  final int applicationCount;
  final bool hasActiveJobs;
  final bool showBadge;

  const JejuEmployerNavBar({
    Key? key,
    required this.selectedTab,
    required this.onTabChanged,
    this.applicationCount = 0,
    this.hasActiveJobs = false,
    this.showBadge = false,
  }) : super(key: key);

  @override
  State<JejuEmployerNavBar> createState() => _JejuEmployerNavBarState();
}

class _JejuEmployerNavBarState extends State<JejuEmployerNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                tab: EmployerNavTab.createJob,
                icon: Icons.add_circle_outline,
                activeIcon: Icons.add_circle,
                label: '공고 작성',
                badge: null,
              ),
              _buildNavItem(
                tab: EmployerNavTab.manageStaff,
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: '근무자 관리',
                badge: widget.applicationCount > 0 ? true : null,
              ),
              _buildNavItem(
                tab: EmployerNavTab.home,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '홈',
                badge: null,
                isHome: true,
              ),
              _buildNavItem(
                tab: EmployerNavTab.salary,
                icon: Icons.payments_outlined,
                activeIcon: Icons.payments,
                label: '급여',
                badge: widget.hasActiveJobs ? true : null,
              ),
              _buildNavItem(
                tab: EmployerNavTab.mypage,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: '마이페이지',
                badge: widget.showBadge ? true : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required EmployerNavTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool? badge,
    bool isHome = false,
  }) {
    final isSelected = widget.selectedTab == tab;
    final selectedColor = const Color(0xFF2D3748); // 사업자용 현무암색
    final unselectedColor = Colors.grey[600]!;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTabChanged(tab);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 아이콘 (모든 탭 동일)
                  Icon(
                    isSelected ? activeIcon : icon,
                    size: 24,
                    color: isSelected ? selectedColor : unselectedColor,
                  ),

                  const SizedBox(height: 4),

                  // 라벨
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              // 빨간 점 배지
              if (badge == true)
                Positioned(
                  right: 14,
                  top: 0,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}