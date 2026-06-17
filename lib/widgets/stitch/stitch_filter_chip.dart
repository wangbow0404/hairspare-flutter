import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Stitch filter chip — 선택 시 보라 토큰, 급구 등 강조는 [urgent] 사용.
class StitchFilterChip extends StatelessWidget {
  const StitchFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.emoji,
    this.urgent = false,
  });

  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Border? border;

    if (isSelected) {
      if (urgent) {
        bg = AppTheme.urgentRed.withValues(alpha: 0.1);
        fg = AppTheme.urgentRed;
        border = Border.all(color: AppTheme.urgentRed.withValues(alpha: 0.3));
      } else {
        bg = AppTheme.primaryPurpleLight;
        fg = AppTheme.stitchPrimary;
        border = Border.all(color: AppTheme.stitchPrimaryContainer);
      }
    } else {
      bg = AppTheme.backgroundGray;
      fg = AppTheme.stitchTextSecondary;
      border = null;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: border,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: emoji != null ? AppTheme.spacing3 : AppTheme.spacing4,
              vertical: AppTheme.spacing2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (emoji != null) ...[
                  Text(emoji!, style: const TextStyle(fontSize: 14, height: 1)),
                  const SizedBox(width: AppTheme.spacing1),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
