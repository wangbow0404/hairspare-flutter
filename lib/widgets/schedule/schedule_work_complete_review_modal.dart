import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../common/glass_modal.dart';

/// 근무 완료 — 글래스모피즘 리뷰 모달.
class ScheduleWorkCompleteReviewModal extends StatelessWidget {
  const ScheduleWorkCompleteReviewModal({
    super.key,
    required this.shopName,
    required this.jobTitle,
    required this.onClose,
    required this.onThumbsUp,
    required this.onCheckInOnly,
    this.isSubmitting = false,
    this.modalTitle = '근무 완료',
    this.prompt = '오늘 근무는 어떠셨나요?\n매장에 응원을 보내보세요',
  });

  final String shopName;
  final String jobTitle;
  final VoidCallback onClose;
  final VoidCallback onThumbsUp;
  final VoidCallback onCheckInOnly;
  final bool isSubmitting;
  final String modalTitle;
  final String prompt;

  @override
  Widget build(BuildContext context) {
    return GlassModal(
      onDismiss: onClose,
      isLocked: isSubmitting,
      child: GlassModalPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassModalHeader(
              title: modalTitle,
              onClose: onClose,
              isCloseEnabled: !isSubmitting,
            ),
            const SizedBox(height: 10),
            _ReviewJobSummary(
              jobTitle: jobTitle,
              shopName: shopName,
            ),
            const SizedBox(height: 20),
            const GlassModalHeroIcon(emoji: '✨'),
            const SizedBox(height: 18),
            Text(
              prompt,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textGray700,
                fontWeight: FontWeight.w500,
                height: 1.55,
                fontSize: 15,
                letterSpacing: -0.15,
              ),
            ),
            const SizedBox(height: 22),
            _ReviewPrimaryButton(
              onPressed: onThumbsUp,
              isSubmitting: isSubmitting,
            ),
            const SizedBox(height: 8),
            _ReviewSkipButton(
              onPressed: onCheckInOnly,
              isSubmitting: isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewJobSummary extends StatelessWidget {
  const _ReviewJobSummary({
    required this.jobTitle,
    required this.shopName,
  });

  final String jobTitle;
  final String shopName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          jobTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            height: 1.35,
            letterSpacing: -0.2,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          shopName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _ReviewPrimaryButton extends StatelessWidget {
  const _ReviewPrimaryButton({
    required this.onPressed,
    required this.isSubmitting,
  });

  final VoidCallback onPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSubmitting ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🙌',
                          style: TextStyle(fontSize: 17, height: 1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '응원 보내기',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: -0.2,
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

class _ReviewSkipButton extends StatelessWidget {
  const _ReviewSkipButton({
    required this.onPressed,
    required this.isSubmitting,
  });

  final VoidCallback onPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isSubmitting ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        '응원 없이 완료만 할게요',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}
