import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum WorkerNavTab { jobs, applications, home, work, mypage }

class JejuWorkerNavBar extends StatefulWidget {
  final WorkerNavTab selectedTab;
  final Function(WorkerNavTab) onTabChanged;
  final int applicationCount;
  final bool hasActiveWork;
  final bool showBadge;

  const JejuWorkerNavBar({
    Key? key,
    required this.selectedTab,
    required this.onTabChanged,
    this.applicationCount = 0,
    this.hasActiveWork = false,
    this.showBadge = false,
  }) : super(key: key);

  @override
  State<JejuWorkerNavBar> createState() => _JejuWorkerNavBarState();
}

class _JejuWorkerNavBarState extends State<JejuWorkerNavBar> {
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
                tab: WorkerNavTab.jobs,
                icon: Icons.work_outline,
                activeIcon: Icons.work,
                label: '공고',
                badge: null,
              ),
              _buildNavItem(
                tab: WorkerNavTab.applications,
                icon: Icons.description_outlined,
                activeIcon: Icons.description,
                label: '지원 내역',
                badge: widget.applicationCount > 0 ? true : null,
              ),
              _buildNavItem(
                tab: WorkerNavTab.home,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '홈',
                badge: null,
                isHome: true,
              ),
              _buildNavItem(
                tab: WorkerNavTab.work,
                icon: Icons.schedule_outlined,
                activeIcon: Icons.schedule,
                label: '근무',
                badge: widget.hasActiveWork ? true : null,
              ),
              _buildNavItem(
                tab: WorkerNavTab.mypage,
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
    required WorkerNavTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool? badge,
    bool isHome = false,
  }) {
    final isSelected = widget.selectedTab == tab;
    final selectedColor = const Color(0xFF00A3A3); // 제주 바다색
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