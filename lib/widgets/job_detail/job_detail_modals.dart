import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/icon_mapper.dart';
import '../design_system/hs_primary_button.dart';

/// 본인인증 유도 모달.
class JobDetailVerificationModal extends StatelessWidget {
  const JobDetailVerificationModal({
    super.key,
    required this.onDismiss,
    required this.onGoVerify,
  });

  final VoidCallback onDismiss;
  final VoidCallback onGoVerify;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: GestureDetector(
        onTap: onDismiss,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: AppTheme.spacing(AppTheme.spacing4),
              constraints: const BoxConstraints(maxWidth: 384),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                boxShadow: AppTheme.shadowXl,
              ),
              padding: AppTheme.spacing(AppTheme.spacing6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon:
                          IconMapper.icon(
                            'x',
                            size: 20,
                            color: AppTheme.textSecondary,
                          ) ??
                          const Icon(
                            Icons.close,
                            color: AppTheme.textSecondary,
                          ),
                      onPressed: onDismiss,
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child:
                        IconMapper.icon(
                          'shield',
                          size: 32,
                          color: AppTheme.primaryGreen,
                        ) ??
                        const Icon(
                          Icons.shield,
                          size: 32,
                          color: AppTheme.primaryGreen,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    '본인인증',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    '휴대폰 본인인증을 진행해주세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  Container(
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundGray,
                      borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                    ),
                    child: Text(
                      '본인인증 진행 후에 지원이 가능합니다',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: AppTheme.textGray700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onGoVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderRadius(
                            AppTheme.radiusXl,
                          ),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        '본인인증하러가기',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 지원 확인 bottom sheet (예약금 안내).
class JobDetailConfirmApplyModal {
  JobDetailConfirmApplyModal._();

  static Future<void> show(
    BuildContext context, {
    required Job job,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ConfirmApplySheet(
        job: job,
        onConfirm: () {
          Navigator.pop(ctx);
          onConfirm();
        },
        onCancel: () {
          Navigator.pop(ctx);
          onCancel();
        },
      ),
    );
  }
}

class _ConfirmApplySheet extends StatelessWidget {
  const _ConfirmApplySheet({
    required this.job,
    required this.onConfirm,
    required this.onCancel,
  });

  final Job job;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: HairSpareColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: HairSpareColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: HairSpareColors.brandPrimarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 28,
              color: HairSpareColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '지원하기',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: HairSpareColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '지원 시 예약금 5,000원이 잠금됩니다.\n근무 완료 후 자동 환급됩니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: HairSpareColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            job.shopName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: HairSpareColors.textStrong,
            ),
          ),
          const SizedBox(height: 24),
          HsPrimaryButton(label: '지원하기', onPressed: onConfirm),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onCancel,
            child: const Text(
              '취소',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: HairSpareColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Legacy overlay widget — use [JobDetailConfirmApplyModal.show] instead.
@Deprecated('Use JobDetailConfirmApplyModal.show')
class JobDetailConfirmApplyModalLegacy extends StatelessWidget {
  const JobDetailConfirmApplyModalLegacy({
    super.key,
    required this.job,
    required this.onConfirm,
    required this.onCancel,
  });

  final Job job;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
