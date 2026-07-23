import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../category_grid.dart';

/// a안 스페어 홈 6칸 퀵 메뉴.
abstract final class SpareHomeQuickMenu {
  static List<CategoryItem> buildCategories(BuildContext context) {
    return [
      CategoryItem(
        emoji: '',
        icon: Icons.work_outline,
        label: '공고정보',
        onTap: () => context.push(AppRoutes.spareHomeJobs),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.calendar_month_outlined,
        label: '내 스케줄',
        onTap: () => context.go(AppRoutes.spareWork),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.emoji_events_outlined,
        label: '챌린지',
        onTap: () => context.push(AppRoutes.spareHomeChallenge),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.favorite_outline_rounded,
        label: '모델매칭',
        onTap: () => context.push(AppRoutes.spareHomeModelMatch),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.school_outlined,
        label: '교육',
        onTap: () => context.push(AppRoutes.spareHomeEducation),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.storefront_outlined,
        label: '공간대여',
        onTap: () => context.push(AppRoutes.spareHomeRegionSelect),
      ),
    ];
  }
}
