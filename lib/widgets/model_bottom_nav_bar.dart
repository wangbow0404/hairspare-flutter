import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 모델 계정 하단 탭 — 홈 · 매칭 · 스케줄 · 마이.
class ModelBottomNavBar extends StatelessWidget {
  const ModelBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: const Border(
          top: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                activeIcon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
                label: '홈',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                activeIcon: Icons.favorite_rounded,
                inactiveIcon: Icons.favorite_outline,
                label: '매칭',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                activeIcon: Icons.calendar_month,
                inactiveIcon: Icons.calendar_month_outlined,
                label: '스케줄',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                activeIcon: Icons.person_rounded,
                inactiveIcon: Icons.person_outline_rounded,
                label: '마이',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? AppTheme.stitchPrimaryContainer : AppTheme.stitchTextSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : inactiveIcon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
