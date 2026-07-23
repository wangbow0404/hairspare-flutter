import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// a안 필터 칩 — 선택 시 activeStructural(#161616).
class HsFilterChip extends StatelessWidget {
  const HsFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.urgent = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    Border? border;

    if (isSelected) {
      if (urgent) {
        bg = HairSpareColors.statusUrgent.withValues(alpha: 0.12);
        fg = HairSpareColors.statusUrgent;
        border = Border.all(
          color: HairSpareColors.statusUrgent.withValues(alpha: 0.35),
        );
      } else {
        bg = HairSpareColors.activeStructural;
        fg = Colors.white;
        border = null;
      }
    } else {
      bg = HairSpareColors.surfaceMuted;
      fg = HairSpareColors.textStrongAlt;
      border = Border.all(color: HairSpareColors.border);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing2,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: border,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
