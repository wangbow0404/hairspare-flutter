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
        label: '공고별',
        onTap: () => context.push(AppRoutes.spareHomeJobs),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.calendar_month_outlined,
        label: '스케줄표',
        onTap: () => context.push(AppRoutes.spareHomeWorkCheck),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.storefront_outlined,
        label: '스토어',
        onTap: () => _showComingSoon(context, '스토어 기능은 준비 중입니다.'),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.monetization_on_outlined,
        label: '+포인트',
        onTap: () => context.push(AppRoutes.spareHomePoints),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.chair_outlined,
        label: '공간대여',
        onTap: () => context.push(AppRoutes.spareHomeRegionSelect),
      ),
      CategoryItem(
        emoji: '',
        icon: Icons.school_outlined,
        label: '교육',
        onTap: () => context.push(AppRoutes.spareHomeEducation),
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
        label: '모델매칭',
        onTap: () => context.push(AppRoutes.spareHomeModelMatch),
      ),
    ];
  }

  static void _showComingSoon(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
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
