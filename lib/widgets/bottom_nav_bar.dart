import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// 하단 탭 페르소나 — 활성색·라벨 분기.
enum BottomNavPersona {
  /// 스페어: 활성 #161616, Tab1=근무
  spare,

  /// 스페어 셸 + 모델 계정: Tab1=메시지 Tab2=스케줄
  spareModel,

  /// 샵: 활성 #B3355C, Tab1=결제
  shop,
}

/// a안 하단 네비게이션.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.persona = BottomNavPersona.spare,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final BottomNavPersona persona;

  Color get _activeColor => switch (persona) {
        BottomNavPersona.shop => HairSpareColors.brandPrimary,
        BottomNavPersona.spare || BottomNavPersona.spareModel =>
          HairSpareColors.activeStructural,
      };

  List<({IconData active, IconData inactive, String label})> get _items =>
      switch (persona) {
        BottomNavPersona.spare => [
            (active: Icons.home_rounded, inactive: Icons.home_outlined, label: '홈'),
            (active: Icons.calendar_month, inactive: Icons.calendar_month_outlined, label: '근무'),
            (active: Icons.favorite_rounded, inactive: Icons.favorite_border_rounded, label: '찜'),
            (active: Icons.person_rounded, inactive: Icons.person_outline_rounded, label: '마이'),
          ],
        BottomNavPersona.spareModel => [
            (active: Icons.home_rounded, inactive: Icons.home_outlined, label: '홈'),
            (active: Icons.chat_bubble_rounded, inactive: Icons.chat_bubble_outline, label: '메시지'),
            (active: Icons.calendar_month, inactive: Icons.calendar_month_outlined, label: '스케줄'),
            (active: Icons.person_rounded, inactive: Icons.person_outline_rounded, label: '마이'),
          ],
        BottomNavPersona.shop => [
            (active: Icons.home_rounded, inactive: Icons.home_outlined, label: '홈'),
            (active: Icons.payments, inactive: Icons.payments_outlined, label: '결제'),
            (active: Icons.favorite_rounded, inactive: Icons.favorite_border_rounded, label: '찜'),
            (active: Icons.person_rounded, inactive: Icons.person_outline_rounded, label: '마이'),
          ],
      };

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final activeColor = _activeColor;
    const inactiveColor = HairSpareColors.textSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: const Border(
          top: BorderSide(color: HairSpareColors.border, width: 1),
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
              for (var i = 0; i < items.length; i++)
                _NavItem(
                  activeIcon: items[i].active,
                  inactiveIcon: items[i].inactive,
                  label: items[i].label,
                  isActive: currentIndex == i,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onTap: () => onTap(i),
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
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : inactiveIcon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
