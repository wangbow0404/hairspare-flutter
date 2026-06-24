import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 샵 홈 — 매칭 꿀팁 promo 배너.
class ShopHomeTipsBanner extends StatelessWidget {
  const ShopHomeTipsBanner({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing2,
        AppTheme.spacing4,
        AppTheme.spacing4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              color: const Color(0xFFEEF2FF),
              border: Border.all(
                color: AppTheme.primaryPurpleLight.withValues(alpha: 0.8),
              ),
            ),
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppTheme.stitchPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing3),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '성공적인 매칭을 위한 꿀팁',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.stitchTextPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '더 많은 지원자를 모집하는 방법',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.stitchTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.stitchTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
