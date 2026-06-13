import 'package:flutter/material.dart';

import '../../models/shop_tier.dart';
import '../../theme/app_theme.dart';
import '../common/shared_app_bar.dart';
import '../../utils/icon_mapper.dart';

/// Shop 스케줄 고정 상단바 (SafeArea 하위 44px).
class ShopScheduleAppBar extends StatelessWidget {
  const ShopScheduleAppBar({super.key, this.tierInfo});

  final ShopTierInfo? tierInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: IconMapper.icon(
                  'chevronleft',
                  size: 24,
                  color: AppTheme.textSecondary,
                ) ??
                const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            '스케줄',
            style: SharedAppBar.titleTextStyle(context),
          ),
          const SizedBox(width: AppTheme.spacing2),
          if (tierInfo != null) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2,
                vertical: AppTheme.spacing1,
              ),
              decoration: BoxDecoration(
                color: Color(tierInfo!.currentTier.colorValue)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: Color(tierInfo!.currentTier.colorValue),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tierInfo!.currentTier.emoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: AppTheme.spacing1),
                  Text(
                    tierInfo!.currentTier.name,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Color(tierInfo!.currentTier.colorValue),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
