import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../design_system/hs_primary_button.dart';

/// 하단 고정 CTA — 지원하기 / 근무 제안 수락·거절 / 잠금 안내.
class JobDetailBottomBar extends StatelessWidget {
  const JobDetailBottomBar({
    super.key,
    required this.isLocked,
    this.primaryLabel,
    this.onPrimary,
    this.showProposalActions = false,
    this.onReject,
    this.onAccept,
    this.isSubmitting = false,
  }) : assert(
         showProposalActions || primaryLabel != null || isLocked,
       );

  final bool isLocked;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final bool showProposalActions;
  final VoidCallback? onReject;
  final VoidCallback? onAccept;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: HairSpareColors.surface,
          border: const Border(top: BorderSide(color: HairSpareColors.border)),
          boxShadow: AppTheme.shadowLg,
        ),
        padding: AppTheme.spacing(AppTheme.spacing4),
        child: SafeArea(
          top: false,
          child: isLocked
              ? _LockedNotice()
              : showProposalActions
              ? _ProposalActions(
                  onReject: onReject,
                  onAccept: onAccept,
                  isSubmitting: isSubmitting,
                )
              : HsPrimaryButton(
                  label: primaryLabel!,
                  onPressed: onPrimary,
                ),
        ),
      ),
    );
  }
}

class _LockedNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: HairSpareColors.brandPrimarySoft,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(
          color: HairSpareColors.brandPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '지원 완료',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: HairSpareColors.brandPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            '미용실의 승인을 기다려주세요.\n연락하기로 미용실과 소통할 수 있습니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: HairSpareColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProposalActions extends StatelessWidget {
  const _ProposalActions({
    required this.onReject,
    required this.onAccept,
    required this.isSubmitting,
  });

  final VoidCallback? onReject;
  final VoidCallback? onAccept;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: HairSpareColors.textSecondary,
              side: const BorderSide(color: HairSpareColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('거절'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: HsPrimaryButton(
            label: '수락',
            expand: true,
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : onAccept,
          ),
        ),
      ],
    );
  }
}
