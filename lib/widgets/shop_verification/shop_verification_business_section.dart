import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/business_registration_validator.dart';
import 'package:hairspare/view_models/shop_verification_view_model.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_image_picker.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_status_badge.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_stepper.dart';
import 'package:hairspare/widgets/shop_verification/shop_verification_ui_kit.dart';

bool showShopBusinessForm(ShopVerificationViewModel vm) {
  return vm.businessPhase == ShopBusinessVerificationUiPhase.notStarted ||
      vm.businessPhase == ShopBusinessVerificationUiPhase.rejected;
}

class ShopVerificationOverviewSection extends StatelessWidget {
  const ShopVerificationOverviewSection({super.key, required this.vm});

  final ShopVerificationViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ShopVerificationSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShopVerificationStepHeader(
            icon: Icons.verified_user_outlined,
            iconColor: AppTheme.primaryGreen,
            title: '인증 관리',
            subtitle: '사업자등록증 업로드 후 정보를 확인하고 신청해 주세요.',
          ),
          const SizedBox(height: AppTheme.spacing4),
          ShopVerificationStepper(vm: vm),
          const SizedBox(height: AppTheme.spacing4),
          ShopVerificationStatusBadge(phase: vm.businessPhase),
          if (vm.businessPhase == ShopBusinessVerificationUiPhase.rejected &&
              vm.rejectionReason != null) ...[
            const SizedBox(height: AppTheme.spacing4),
            ShopVerificationStatusBanner(
              title: '거절 사유',
              message: vm.rejectionReason!,
              tint: AppTheme.urgentRed,
              icon: Icons.info_outline,
            ),
          ],
          if (vm.businessPhase == ShopBusinessVerificationUiPhase.approved &&
              vm.verifiedAt != null) ...[
            const SizedBox(height: AppTheme.spacing4),
            ShopVerificationStatusBanner(
              title: '인증 완료일',
              message: vm.verifiedAt!,
              tint: AppTheme.primaryGreen,
              icon: Icons.event_available_outlined,
            ),
          ],
        ],
      ),
    );
  }
}

class ShopVerificationBusinessSection extends StatelessWidget {
  const ShopVerificationBusinessSection({super.key, required this.vm});

  final ShopVerificationViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.businessPhase == ShopBusinessVerificationUiPhase.pending) {
      return const ShopVerificationStatusBanner(
        title: '사업자 인증 심사 중',
        message: '제출하신 서류를 검토하고 있습니다. 완료되면 알려드립니다.',
        tint: AppTheme.orange600,
        icon: Icons.hourglass_top_outlined,
      );
    }

    if (vm.businessPhase == ShopBusinessVerificationUiPhase.approved) {
      return ShopVerificationSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인증된 사업자 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            ShopVerificationFieldRow(
              label: '사업자등록번호',
              value: vm.snapshotBusinessNumber ?? '',
            ),
            ShopVerificationFieldRow(
              label: '상호명',
              value: vm.snapshotBusinessName ?? '',
            ),
            ShopVerificationFieldRow(
              label: '대표자명',
              value: vm.snapshotRepresentativeName ?? '',
            ),
            ShopVerificationFieldRow(
              label: '업태/종목',
              value:
                  '${vm.snapshotBusinessType ?? ''} / ${vm.snapshotBusinessCategory ?? ''}',
            ),
            ShopVerificationFieldRow(
              label: '사업장 주소',
              value: vm.snapshotAddress ?? '',
              isMultiline: true,
            ),
          ],
        ),
      );
    }

    if (!showShopBusinessForm(vm)) {
      return const SizedBox.shrink();
    }

    return ShopVerificationSectionCard(
      padding: EdgeInsets.zero,
      child: Form(
        key: vm.businessFormKey,
        child: Padding(
          padding: AppTheme.spacing(AppTheme.spacing5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShopVerificationStepHeader(
                icon: Icons.business_outlined,
                iconColor: AppTheme.primaryPurple,
                title: '사업자 정보',
                subtitle: '등록증 사진을 먼저 올리면 자동으로 입력됩니다.',
              ),
              const SizedBox(height: AppTheme.spacing5),
              Text(
                '사업자등록증 *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              ShopVerificationImageTile(
                label: '사업자등록증',
                guide: '네 모서리가 보이도록 촬영해 주세요',
                file: vm.businessRegistrationFile,
                isLoading: vm.isScanningRegistration,
                onPick: () => showShopVerificationPickSource(
                  context,
                  onChosen: vm.pickBusinessRegistration,
                ),
                onClear: vm.clearBusinessRegistration,
              ),
              if (vm.ocrResult != null) ...[
                const SizedBox(height: AppTheme.spacing4),
                _OcrResultCard(vm: vm),
              ],
              const SizedBox(height: AppTheme.spacing5),
              TextFormField(
                controller: vm.businessNumberController,
                decoration: const InputDecoration(
                  labelText: '사업자등록번호 *',
                  hintText: '000-00-00000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                ],
                validator: BusinessRegistrationValidator.formValidator,
              ),
              if (vm.numberFormatValidation != null &&
                  vm.businessNumberController.text.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing2),
                ShopVerificationValidationChip(
                  label: vm.numberFormatValidation!.isNumberFormatValid
                      ? '번호 형식 OK'
                      : (vm.numberFormatValidation!.numberFormatMessage ??
                          '형식 오류'),
                  isOk: vm.numberFormatValidation!.isNumberFormatValid,
                ),
              ],
              const SizedBox(height: AppTheme.spacing3),
              TextFormField(
                controller: vm.businessNameController,
                decoration: const InputDecoration(
                  labelText: '상호명 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '상호명을 입력해주세요' : null,
              ),
              const SizedBox(height: AppTheme.spacing3),
              TextFormField(
                controller: vm.representativeNameController,
                decoration: const InputDecoration(
                  labelText: '대표자명 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '대표자명을 입력해주세요' : null,
              ),
              const SizedBox(height: AppTheme.spacing3),
              TextFormField(
                controller: vm.businessTypeController,
                decoration: const InputDecoration(
                  labelText: '업태 *',
                  hintText: '예: 서비스업',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '업태를 입력해주세요' : null,
              ),
              const SizedBox(height: AppTheme.spacing3),
              TextFormField(
                controller: vm.businessCategoryController,
                decoration: const InputDecoration(
                  labelText: '종목 *',
                  hintText: '예: 미용업',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '종목을 입력해주세요' : null,
              ),
              const SizedBox(height: AppTheme.spacing3),
              TextFormField(
                controller: vm.addressController,
                decoration: const InputDecoration(
                  labelText: '사업장 주소 *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '사업장 주소를 입력해주세요' : null,
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                '대표자 신분증 (선택)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              ShopVerificationImageTile(
                label: '신분증',
                guide: '대표자 본인 확인용 (선택)',
                file: vm.idCardFile,
                onPick: () => showShopVerificationPickSource(
                  context,
                  onChosen: vm.pickIdCard,
                ),
                onClear: vm.clearIdCard,
              ),
              const SizedBox(height: AppTheme.spacing5),
              const ShopVerificationValidationChip(
                label: '국세청 확인은 제출 후 서버에서 진행',
                isOk: true,
                isPending: true,
              ),
              const SizedBox(height: AppTheme.spacing4),
              ShopVerificationPrimaryButton(
                label: '인증 신청하기',
                backgroundColor: AppTheme.primaryGreen,
                isLoading: vm.isSubmittingBusiness,
                onPressed: vm.isSubmittingBusiness || vm.isScanningRegistration
                    ? null
                    : vm.submitBusinessVerification,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OcrResultCard extends StatelessWidget {
  const _OcrResultCard({required this.vm});

  final ShopVerificationViewModel vm;

  @override
  Widget build(BuildContext context) {
    final validation = vm.registrationValidation;
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurpleLight,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.purple100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '자동 인식 결과',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurple,
                ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            '인식된 내용을 확인하고 필요하면 수정해 주세요.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          if (validation?.hasOcrMismatch == true) ...[
            const SizedBox(height: AppTheme.spacing3),
            const ShopVerificationValidationChip(
              label: '인식값과 입력값이 다릅니다',
              isOk: false,
            ),
          ],
        ],
      ),
    );
  }
}
