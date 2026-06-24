import 'package:flutter/material.dart';

import '../../widgets/customer_service_section.dart';
import 'spare_profile_header.dart';
import 'spare_profile_identity_section.dart';
import 'spare_profile_logout_section.dart';
import 'spare_profile_menu_section.dart';
import 'spare_profile_quick_stats.dart';

/// 스페어 프로필 탭 본문 (헤더·프로필·통계·메뉴·로그아웃·고객센터).
class SpareProfileScrollView extends StatelessWidget {
  const SpareProfileScrollView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + 70;

    return Column(
      children: [
        const SpareProfileHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: const Column(
              children: [
                SpareProfileIdentitySection(),
                SpareProfileQuickStats(),
                SpareProfileMenuSection(),
                SpareProfileLogoutSection(),
                CustomerServiceSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
