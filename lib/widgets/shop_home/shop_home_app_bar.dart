import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/app_bar_navigation.dart';
import '../../widgets/design_system/hs_search_bar.dart';
import '../../widgets/notification_bell.dart';

/// a안 샵 홈 헤더 — 지점명 + SHOP pill + 검색바.
class ShopHomeAppBarRow extends StatelessWidget {
  const ShopHomeAppBarRow({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final shopName = context.select<AuthProvider, String>(
      (p) => p.currentUser?.name?.trim().isNotEmpty == true
          ? p.currentUser!.name!.trim()
          : '내 샵',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              shopName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: HairSpareColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppTheme.spacing2),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: HairSpareColors.brandPrimarySoft,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(
                  color: HairSpareColors.brandPrimary.withValues(alpha: 0.25),
                ),
              ),
              child: const Text(
                'SHOP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: HairSpareColors.brandPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              color: HairSpareColors.textStrong,
              onPressed: () => AppBarNavigation.pushMessages(context),
            ),
            const NotificationBell(role: 'shop'),
          ],
        ),
        const SizedBox(height: AppTheme.spacing2),
        HsSearchBar(
          hintText: '스페어·모델 이름 검색',
          onTap: () => AppBarNavigation.pushSearch(context),
        ),
      ],
    );
  }
}
