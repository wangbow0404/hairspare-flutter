import 'package:flutter/material.dart';

import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/view_models/shop_verification_view_model.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_status_badge.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_ui_kit.dart';

class ShopVerificationProxySection extends StatelessWidget {
  const ShopVerificationProxySection({super.key, required this.vm});

  final ShopVerificationViewModel vm;

  @override
  Widget build(BuildContext context) {
    ShopBusinessVerificationUiPhase? badgePhase;
    if (vm.proxyStatus == 'approved') {
      badgePhase = ShopBusinessVerificationUiPhase.approved;
    } else if (vm.proxyStatus == 'pending') {
      badgePhase = ShopBusinessVerificationUiPhase.pending;
    } else if (vm.proxyStatus == 'rejected') {
      badgePhase = ShopBusinessVerificationUiPhase.rejected;
    }

    return ShopVerificationSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShopVerificationStepHeader(
            icon: Icons.badge_outlined,
            iconColor: AppTheme.orange600,
            title: '대리인 인증',
            subtitle: '점장·매니저 등 대리인 운영 시 플랫폼 승인이 필요합니다.',
            trailing: badgePhase != null
                ? ShopVerificationStatusBadge(phase: badgePhase)
                : null,
          ),
          const SizedBox(height: AppTheme.spacing4),
          if (vm.proxyStatus == 'approved')
            const Text('대리인 인증이 완료되었습니다.')
          else if (vm.proxyStatus == 'pending')
            const ShopVerificationStatusBanner(
              title: '대리인 인증 검토 중',
              message: '승인 후 알려드리겠습니다.',
              tint: AppTheme.orange600,
              icon: Icons.hourglass_top_outlined,
            )
          else ...[
            TextFormField(
              controller: vm.proxyNameController,
              decoration: const InputDecoration(
                labelText: '대리인 이름 *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            TextFormField(
              controller: vm.proxyRelationController,
              decoration: const InputDecoration(
                labelText: '관계 *',
                hintText: '예: 점장, 매니저',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            TextFormField(
              controller: vm.proxyPhoneController,
              decoration: const InputDecoration(
                labelText: '연락처 *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              '사업자 인증 완료 후 검토됩니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            ShopVerificationPrimaryButton(
              label: '대리인 인증 신청',
              backgroundColor: AppTheme.orange600,
              isLoading: vm.isSubmittingProxy,
              onPressed: vm.isSubmittingProxy ? null : vm.submitProxyVerification,
            ),
          ],
        ],
      ),
    );
  }
}
