import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../category_grid.dart';

/// a안 스페어 홈 6칸 퀵 메뉴.
abstract final class SpareHomeQuickMenu {
  static List<CategoryItem> buildCategories(BuildContext context) {
    return [
      CategoryItem(
        emoji: '',
        icon: Icons.work_outline,
        label: '공고정보',
        color: HairSpareColors.statusMatching,
        onTap: () => context.push(AppRoutes.spareHomeJobs),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.calendar_month_outlined,
        label: '내 스케줄',
        color: HairSpareColors.statusSuccess,
        onTap: () => context.go(AppRoutes.spareWork),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.emoji_events_outlined,
        label: '챌린지',
        color: HairSpareColors.star,
        onTap: () => context.push(AppRoutes.spareHomeChallenge),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.favorite_outline_rounded,
        label: '모델매칭',
        color: HairSpareColors.brandPrimary,
        onTap: () => context.push(AppRoutes.spareHomeModelMatch),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.school_outlined,
        label: '교육',
        color: HairSpareColors.statusEducation,
        onTap: () => context.push(AppRoutes.spareHomeEducation),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.storefront_outlined,
        label: '공간대여',
        color: HairSpareColors.categoryVenue,
        onTap: () => context.push(AppRoutes.spareHomeRegionSelect),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.toll_outlined,
        label: '포인트',
        color: HairSpareColors.hipass,
        onTap: () => context.push(AppRoutes.spareHomePoints),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.storefront,
        label: '스토어',
        color: AppTheme.orange500,
        onTap: () => context.push(AppRoutes.spareHomeStore),
      ),
    ];
  }
}
