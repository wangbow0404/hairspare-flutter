import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 모델 홈 — 본인인증·오늘 관심 상태 스트립.
class ModelHomeStatusStrip extends StatelessWidget {
  const ModelHomeStatusStrip({
    super.key,
    required this.isIdentityVerified,
    required this.todayInterestCount,
  });

  final bool isIdentityVerified;
  final int todayInterestCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: Row(
        children: [
          Expanded(
            child: _StatusChip(
              icon: Icons.verified_user_outlined,
              iconColor: AppTheme.stitchPrimaryContainer,
              label: isIdentityVerified ? '본인인증 완료' : '본인인증 필요',
            ),
          ),
          const SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: _StatusChip(
              icon: Icons.favorite,
              iconColor: AppTheme.urgentRed,
              label: '오늘 받은 관심 ',
              highlight: '$todayInterestCount',
              suffix: '건',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.highlight,
    this.suffix,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? highlight;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: AppTheme.spacing1),
            Flexible(
              child: RichText(
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.stitchTextPrimary,
                  ),
                  children: [
                    TextSpan(text: label),
                    if (highlight != null)
                      TextSpan(
                        text: highlight,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.stitchPrimaryContainer,
                        ),
                      ),
                    if (suffix != null) TextSpan(text: suffix),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
