import 'package:flutter/material.dart';

import '../../core/router/spare_profile_navigation.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_screen_insets.dart';
import '../../widgets/common/hairspare_brand_assets.dart';
import '../../utils/icon_mapper.dart';

/// 로고(홈) · 설정 진입 — status bar 아래 44px 영역.
class SpareProfileHeader extends StatelessWidget {
  const SpareProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreenInsets.topBarShell(
      context: context,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => SpareProfileNavigation.openHomeFromLogo(context),
            child: const HairSpareBrandLogo(height: 36),
          ),
          IconButton(
            icon: IconMapper.icon('settings', size: 24, color: AppTheme.textSecondary) ??
                const Icon(Icons.settings, color: AppTheme.textSecondary),
            onPressed: () => SpareProfileNavigation.pushSettings(context),
          ),
        ],
      ),
    );
  }
}
