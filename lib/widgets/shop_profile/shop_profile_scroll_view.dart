import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/customer_service_section.dart';
import '../../widgets/spare_profile/spare_profile_logout_section.dart';
import 'shop_profile_header.dart';
import 'shop_profile_identity_section.dart';
import 'shop_profile_menu_section.dart';
import 'shop_profile_quick_stats.dart';

/// 샵 마이 탭 본문 (헤더·프로필·통계·메뉴·로그아웃·고객센터).
class ShopProfileScrollView extends StatelessWidget {
  const ShopProfileScrollView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + 70;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: const Column(
        children: [
          ShopProfileHeader(),
          ShopProfileIdentitySection(),
          ShopProfileQuickStats(),
          ShopProfileMenuSection(),
          SpareProfileLogoutSection(),
          CustomerServiceSection(),
        ],
      ),
    );
  }
}
