import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';

enum UserType { worker, employer }

class JejuUserTypeSelector extends StatefulWidget {
  final UserType selectedType;
  final Function(UserType) onTypeChanged;

  const JejuUserTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  State<JejuUserTypeSelector> createState() => _JejuUserTypeSelectorState();
}

class _JejuUserTypeSelectorState extends State<JejuUserTypeSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            JejuTheme.stoneBeige,
            JejuTheme.stoneBeige.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: JejuTheme.basaltLight.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: JejuTheme.basaltDark.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          // 선택된 타입 배경 슬라이더
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: widget.selectedType == UserType.worker ? 0 : null,
            right: widget.selectedType == UserType.employer ? 0 : null,
            top: 0,
            bottom: 0,
            width: (MediaQuery.of(context).size.width - 84) / 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.selectedType == UserType.worker
                    ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    JejuTheme.emeraldBright,
                    JejuTheme.emeraldDeep,
                  ],
                )
                    : JejuTheme.sunsetGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (widget.selectedType == UserType.worker
                        ? JejuTheme.emeraldBright
                        : JejuTheme.sunsetOrange)
                        .withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // 버튼들
          Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  type: UserType.worker,
                  icon: CupertinoIcons.briefcase_fill,
                  label: '구직자',
                  description: '일자리 찾기',
                  isSelected: widget.selectedType == UserType.worker,
                ),
              ),
              Expanded(
                child: _buildTypeButton(
                  type: UserType.employer,
                  icon: CupertinoIcons.building_2_fill,
                  label: '자영업자',
                  description: '인재 찾기',
                  isSelected: widget.selectedType == UserType.employer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required UserType type,
    required IconData icon,
    required String label,
    required String description,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onTypeChanged(type);
        if (isSelected) {
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
        }
      },
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.95,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘과 레이블
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : JejuTheme.basaltMedium,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isSelected
                            ? Colors.white
                            : JejuTheme.basaltMedium,
                        fontFamily: '.SF Pro Text',
                      ),
                    ),
                  ),
                ],
              ),

              // 설명
              if (isSelected) ...[
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: '.SF Pro Text',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}