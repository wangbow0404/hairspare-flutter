import 'package:flutter/material.dart';

import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/view_models/shop_verification_view_model.dart';

class ShopVerificationStatusBadge extends StatelessWidget {
  const ShopVerificationStatusBadge({super.key, required this.phase});

  final ShopBusinessVerificationUiPhase phase;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case ShopBusinessVerificationUiPhase.approved:
        return _badge(
          '인증 완료',
          AppTheme.primaryGreen,
          Icons.check_circle_outline,
        );
      case ShopBusinessVerificationUiPhase.pending:
        return _badge(
          '검토 중',
          AppTheme.orange600,
          Icons.hourglass_top_outlined,
        );
      case ShopBusinessVerificationUiPhase.rejected:
        return _badge(
          '인증 거절',
          AppTheme.urgentRed,
          Icons.cancel_outlined,
        );
      case ShopBusinessVerificationUiPhase.notStarted:
        return _badge(
          '미인증',
          AppTheme.textGray700,
          Icons.info_outline,
        );
    }
  }

  Widget _badge(String label, Color color, IconData icon) {
    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
