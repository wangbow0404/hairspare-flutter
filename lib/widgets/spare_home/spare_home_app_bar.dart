import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/job_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/app_bar_navigation.dart';
import '../../widgets/spare_home/spare_region_select_sheet.dart';
import '../../widgets/notification_bell.dart';

/// a안 스페어 홈 상단 고정 row — 지역 + 검색·메시지·알림 (44px). 프로필은 하단 「마이」 탭에서 접근.
class SpareHomeAppBarRow extends StatelessWidget {
  const SpareHomeAppBarRow({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final regionLabel = context.watch<JobProvider>().regionDisplayLabel;

    return Row(
      children: [
        InkWell(
          onTap: () => SpareRegionSelectSheet.show(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacing1,
              horizontal: AppTheme.spacing1,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  regionLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HairSpareColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: HairSpareColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(Icons.search, size: 22),
          color: HairSpareColors.textStrong,
          onPressed: () => AppBarNavigation.pushSearch(context),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(Icons.chat_bubble_outline, size: 22),
          color: HairSpareColors.textStrong,
          onPressed: () => AppBarNavigation.pushMessages(context),
        ),
        const NotificationBell(role: 'spare'),
      ],
    );
  }
}
