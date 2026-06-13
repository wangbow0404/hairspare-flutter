import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/view_models/shop_verification_view_model.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_business_section.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_identity_section.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_proxy_section.dart';

/// 샵 인증 화면 본문 (스크롤).
class ShopVerificationBody extends StatelessWidget {
  const ShopVerificationBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopVerificationViewModel>();

    return SingleChildScrollView(
      padding: AppTheme.spacing(AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShopVerificationOverviewSection(vm: vm),
          const SizedBox(height: AppTheme.spacing3),
          ShopVerificationBusinessSection(vm: vm),
          const SizedBox(height: AppTheme.spacing3),
          ShopVerificationIdentitySection(vm: vm),
          const SizedBox(height: AppTheme.spacing3),
          ShopVerificationProxySection(vm: vm),
          const SizedBox(height: AppTheme.spacing6),
        ],
      ),
    );
  }
}
