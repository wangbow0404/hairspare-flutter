import 'package:flutter/material.dart';

import '../../core/router/app_navigation.dart';
import '../../core/router/shop_profile_navigation.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_screen_insets.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/common/hairspare_brand_assets.dart';

/// 샵 마이 탭 상단바 — 로고 + 설정 버튼.
class ShopProfileHeader extends StatelessWidget {
  const ShopProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreenInsets.topBarShell(
      context: context,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => AppNavigation.goShopHome(context),
            child: const HairSpareBrandLogo(height: 36),
          ),
          IconButton(
            icon: IconMapper.icon('settings', size: 24, color: AppTheme.textSecondary) ??
                const Icon(Icons.settings, color: AppTheme.textSecondary),
            onPressed: () => ShopProfileNavigation.pushSettings(context),
          ),
        ],
      ),
    );
  }
}
