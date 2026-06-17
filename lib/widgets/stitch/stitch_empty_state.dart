import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';

/// Stitch empty state — 중앙 아이콘 + 안내 + Primary CTA.
class StitchEmptyState extends StatelessWidget {
  const StitchEmptyState({
    super.key,
    required this.message,
    this.iconName = 'briefcase',
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String iconName;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurpleLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Center(
                child: IconMapper.icon(
                      iconName,
                      size: 32,
                      color: AppTheme.stitchPrimary,
                    ) ??
                    Icon(
                      icon ?? Icons.inbox_outlined,
                      size: 32,
                      color: AppTheme.stitchPrimary,
                    ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.stitchTextSecondary,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spacing4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
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
                    actionLabel!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
