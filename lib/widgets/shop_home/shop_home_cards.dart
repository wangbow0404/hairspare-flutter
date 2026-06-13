import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/home_text_styles.dart';

Widget buildShopHomeDashboardCard({
  required String value,
  required String label,
  required Gradient gradient,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(AppTheme.spacing3),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: HomeTextStyles.dashboardValueOnGradient,
          ),
          const SizedBox(height: AppTheme.spacing1),
          Text(
            label,
            style: HomeTextStyles.dashboardLabelOnGradient,
          ),
        ],
      ),
    ),
  );
}

Widget buildShopHomeQuickActionCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: HomeTextStyles.quickActionTitle,
                ),
                const SizedBox(height: AppTheme.spacing1),
                Text(
                  subtitle,
                  style: HomeTextStyles.quickActionSubtitle,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
