import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/shop_tier.dart';
import '../../theme/app_theme.dart';
import '../../view_models/shop_profile_view_model.dart';

/// 샵 프로필 — VIP 등급 · 완료 근무 · 진행중 통계 요약.
class ShopProfileQuickStats extends StatelessWidget {
  const ShopProfileQuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      padding: AppTheme.spacing(AppTheme.spacing4),
      child: Consumer<ShopProfileViewModel>(
        builder: (context, vm, _) {
          final tier = ShopTierExtension.parse(vm.vipLevel);
          final tierColor = Color(tier.colorValue);

          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_rounded, size: 20, color: tierColor),
                        const SizedBox(width: AppTheme.spacing1),
                        Text(
                          tier.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: tierColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      '등급',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.borderGray),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      vm.isLoading ? '-' : '${vm.vipTotalCompleted}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      '완료 근무',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.borderGray),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      vm.isLoading ? '-' : '${vm.ongoingSchedules}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.green600,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      '진행중',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
