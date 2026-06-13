import 'package:flutter/material.dart';

import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/view_models/shop_verification_view_model.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_status_badge.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_ui_kit.dart';

class ShopVerificationIdentitySection extends StatelessWidget {
  const ShopVerificationIdentitySection({super.key, required this.vm});

  final ShopVerificationViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ShopVerificationSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShopVerificationStepHeader(
            icon: Icons.phone_android_outlined,
            iconColor: AppTheme.primaryBlue,
            title: '본인인증',
            subtitle: '휴대폰 SMS로 본인 확인을 진행합니다.',
            trailing: vm.identityVerified
                ? const ShopVerificationStatusBadge(
                    phase: ShopBusinessVerificationUiPhase.approved,
                  )
                : null,
          ),
          const SizedBox(height: AppTheme.spacing4),
          if (vm.identityVerified)
            ShopVerificationFieldRow(
              label: '인증 휴대폰',
              value: vm.identityPhone ?? '',
            )
          else ...[
            TextFormField(
              controller: vm.phoneController,
              decoration: const InputDecoration(
                labelText: '휴대폰 번호',
                hintText: '010-1234-5678',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              enabled: !vm.phoneVerificationSent,
            ),
            if (vm.phoneVerificationSent) ...[
              const SizedBox(height: AppTheme.spacing3),
              TextFormField(
                controller: vm.verificationCodeController,
                decoration: InputDecoration(
                  labelText: '인증번호',
                  border: const OutlineInputBorder(),
                  suffixText: vm.verificationTimer > 0
                      ? '${(vm.verificationTimer / 60).floor()}:${(vm.verificationTimer % 60).toString().padLeft(2, '0')}'
                      : null,
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: AppTheme.spacing2),
              Row(
                children: [
                  if (vm.verificationTimer == 0)
                    TextButton(
                      onPressed:
                          vm.isVerifyingPhone ? null : vm.sendVerificationCode,
                      child: const Text('인증번호 재발송'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: vm.isVerifyingPhone ? null : vm.verifyCode,
                    child: vm.isVerifyingPhone
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('인증하기'),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: AppTheme.spacing3),
              ShopVerificationPrimaryButton(
                label: '인증번호 발송',
                isLoading: vm.isVerifyingPhone,
                onPressed: vm.isVerifyingPhone ? null : vm.sendVerificationCode,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
