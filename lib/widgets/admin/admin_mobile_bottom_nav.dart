import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../theme/admin_stitch_theme.dart';

/// 모바일 관리자 하단 탭 (목업: 대시보드 · 회원 · 신고)
class AdminMobileBottomNav extends StatelessWidget {
  const AdminMobileBottomNav({
    super.key,
    required this.currentRoute,
  });

  final String currentRoute;

  bool _isActive(String route) {
    if (route == AppRoutes.admin) {
      return currentRoute == route;
    }
    return currentRoute.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminStitchTheme.surfaceCard.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: AdminStitchTheme.borderDefault),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminStitchTheme.pageMargin,
            vertical: 8,
          ),
          child: Row(
            children: [
              _NavItem(
                label: '대시보드',
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                active: _isActive(AppRoutes.admin),
                onTap: () => context.go(AppRoutes.admin),
              ),
              _NavItem(
                label: '회원',
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                active: _isActive(AppRoutes.adminUsers),
                onTap: () => context.go(AppRoutes.adminUsers),
              ),
              _NavItem(
                label: '신고',
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                active: _isActive(AppRoutes.adminReports),
                onTap: () => context.go(AppRoutes.adminReports),
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
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: active ? 20 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active ? AdminStitchTheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
                  boxShadow: active
                      ? const [
                          BoxShadow(
                            color: Color(0x33580099),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  active ? activeIcon : icon,
                  size: 22,
                  color: active
                      ? AdminStitchTheme.onPrimary
                      : AdminStitchTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AdminStitchTheme.labelSm.copyWith(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? AdminStitchTheme.primary
                      : AdminStitchTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
