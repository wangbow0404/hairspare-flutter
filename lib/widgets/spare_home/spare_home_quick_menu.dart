import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../category_grid.dart';

/// 스페어 홈 8칸 퀵 메뉴 — CategoryGrid 항목 정의.
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
        onTap: () => context.push(AppRoutes.spareHomeWorkCheck),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.star_outline_rounded,
        label: '챌린지참여',
        onTap: () => context.push(AppRoutes.spareHomeChallenge),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.favorite_outline_rounded,
        label: '모델검색',
        onTap: () => context.push(AppRoutes.spareHomeModelMatch),
      ),
    ];
  }

}
