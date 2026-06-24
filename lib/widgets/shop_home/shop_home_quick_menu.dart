import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../theme/app_theme.dart';
import '../category_grid.dart';

/// 샵 홈 8칸 퀵 메뉴 — CategoryGrid 항목 정의 (기존 그리드 유지, 8번만 모델매칭).
abstract final class ShopHomeQuickMenu {
  static List<CategoryItem> buildCategories(BuildContext context) {
    return [
      CategoryItem(
        emoji: '',
        icon: Icons.groups_2_outlined,
        label: '인력별',
        color: AppTheme.primaryPurple,
        onTap: () => context.push(AppRoutes.shopHomeSpares),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.event_note_outlined,
        label: '스케줄표',
        color: AppTheme.primaryBlue,
        onTap: () => context.push(AppRoutes.shopHomeSchedule),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.storefront_outlined,
        label: '스토어',
        color: AppTheme.primaryGreen,
        onTap: () => _showComingSoon(context, '스토어 기능은 준비 중입니다.'),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.add_card_outlined,
        label: '+포인트',
        color: AppTheme.orange500,
        onTap: () => context.push(AppRoutes.shopHomePoints),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.meeting_room_outlined,
        label: '공간대여',
        color: AppTheme.primaryPink,
        onTap: () => context.push(AppRoutes.shopHomeSpaces),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.school_outlined,
        label: '교육',
        color: AppTheme.primaryPurple,
        onTap: () => context.push(AppRoutes.shopHomeEducation),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.workspace_premium_outlined,
        label: '챌린지참여',
        color: AppTheme.primaryBlueDark,
        onTap: () => context.push(AppRoutes.shopHomeChallenge),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.favorite_outline,
        label: '모델매칭',
        color: AppTheme.primaryPink,
        onTap: () => context.push(AppRoutes.shopHomeModelMatch),
      ),
    ];
  }

  static void _showComingSoon(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius2xl),
        ),
        title: const Text('준비 중'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

}
