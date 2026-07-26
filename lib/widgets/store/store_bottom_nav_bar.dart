import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/store_wishlist_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// HairSpare 스토어 전용 하단 네비 — 메인 탭(홈·근무·찜·마이)과 분리.
class StoreBottomNavBar extends StatelessWidget {
  const StoreBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _activeColor = HairSpareColors.brandPrimary;
  static const _inactiveColor = HairSpareColors.textSecondary;

  @override
  Widget build(BuildContext context) {
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
              _StoreNavItem(
                activeIcon: Icons.storefront_rounded,
                inactiveIcon: Icons.storefront_outlined,
                label: '스토어',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _StoreNavItem(
                activeIcon: Icons.grid_view_rounded,
                inactiveIcon: Icons.grid_view_outlined,
                label: '카테고리',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              Consumer<StoreWishlistProvider>(
                builder: (context, wishlist, _) {
                  return _StoreNavItem(
                    activeIcon: Icons.favorite_rounded,
                    inactiveIcon: Icons.favorite_border_rounded,
                    label: '찜',
                    isActive: currentIndex == 2,
                    badgeCount: wishlist.count,
                    onTap: () => onTap(2),
                  );
                },
              ),
              _StoreNavItem(
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

class _StoreNavItem extends StatelessWidget {
  const _StoreNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? StoreBottomNavBar._activeColor : StoreBottomNavBar._inactiveColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isActive ? activeIcon : inactiveIcon,
                    size: 24,
                    color: color,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: const BoxDecoration(
                          color: StoreBottomNavBar._activeColor,
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
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
