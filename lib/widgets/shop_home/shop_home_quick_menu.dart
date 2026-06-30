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

}
