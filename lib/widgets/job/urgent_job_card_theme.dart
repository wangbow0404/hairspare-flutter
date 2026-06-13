import 'package:flutter/material.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/theme/home_text_styles.dart';

/// Paid 급구 job cards — red tint, red border, rocket badge.
class UrgentJobCardTheme {
  UrgentJobCardTheme._();

  static BoxDecoration cardDecoration({required bool isUrgent}) {
    return BoxDecoration(
      color: isUrgent ? AppTheme.urgentRedLight : AppTheme.backgroundWhite,
      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
      border: Border.all(
        color: isUrgent ? AppTheme.urgentRed : AppTheme.borderGray,
        width: isUrgent ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

class UrgentJobBadge extends StatelessWidget {
  const UrgentJobBadge({
    super.key,
    this.fontSize = 12,
    this.rocketSize = 12,
  });

  final double fontSize;
  final double rocketSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: AppTheme.urgentRed,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🚀', style: TextStyle(fontSize: rocketSize)),
          const SizedBox(width: AppTheme.spacing1),
          Text(
            '급구',
            style: HomeTextStyles.homeCardTag.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
