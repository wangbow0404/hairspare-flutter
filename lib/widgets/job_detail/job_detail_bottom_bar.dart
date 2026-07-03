import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

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
          color: AppTheme.backgroundWhite,
          border: const Border(top: BorderSide(color: AppTheme.borderGray, width: 1)),
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
              : _PrimaryButton(
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
        color: const Color(0xFFF3E8FF),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '지원 완료',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.stitchPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            '미용실의 승인을 기다려주세요.\n연락하기로 미용실과 소통할 수 있습니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: AppTheme.stitchTextSecondary,
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
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.borderGray),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('거절'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.stitchPrimaryContainer,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('수락'),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.stitchPrimaryContainer,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
