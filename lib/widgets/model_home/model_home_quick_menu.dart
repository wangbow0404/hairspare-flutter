import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../screens/spare/education_screen.dart';
import '../../screens/spare/profile_edit_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_bar_navigation.dart';

/// 모델 홈 — 빠른 메뉴 4개.
class ModelHomeQuickMenu extends StatelessWidget {
  const ModelHomeQuickMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: Row(
        children: [
          Expanded(
            child: _QuickMenuItem(
              icon: Icons.calendar_month_outlined,
              label: '스케줄표',
              onTap: () => context.go(AppRoutes.spareFavorites),
            ),
          ),
          Expanded(
            child: _QuickMenuItem(
              icon: Icons.chat_bubble_outline,
              label: '메시지',
              onTap: () => AppBarNavigation.pushMessages(context),
            ),
          ),
          Expanded(
            child: _QuickMenuItem(
              icon: Icons.edit_document,
              label: '프로필 수정',
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const ProfileEditScreen(),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _QuickMenuItem(
              icon: Icons.school_outlined,
              label: '교육',
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const EducationScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickMenuItem extends StatelessWidget {
  const _QuickMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing2),
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderGray),
                boxShadow: AppTheme.stitchSoftShadow,
              ),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(icon, color: AppTheme.stitchTextSecondary),
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
