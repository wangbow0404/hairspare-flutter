import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 승인 대기 예약이 있을 때만 표시하는 안내 배너.
class ShopSpaceBookingsPendingHint extends StatelessWidget {
  const ShopSpaceBookingsPendingHint({
    super.key,
    required this.pendingCount,
  });

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    if (pendingCount <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing5,
        AppTheme.spacing3,
        AppTheme.spacing5,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4,
          vertical: AppTheme.spacing3,
        ),
        decoration: BoxDecoration(
          color: AppTheme.stitchPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.stitchPrimary.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline,
              size: 18,
              color: AppTheme.stitchPrimary,
            ),
            const SizedBox(width: AppTheme.spacing2),
            Expanded(
              child: Text(
                '승인 대기 $pendingCount건 — 승인하면 예약이 확정됩니다.',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.stitchTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
