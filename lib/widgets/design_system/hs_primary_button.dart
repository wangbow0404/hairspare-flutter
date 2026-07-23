import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// a안 CTA — brandPrimary fill.
class HsPrimaryButton extends StatelessWidget {
  const HsPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: HairSpareColors.brandPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            HairSpareColors.brandPrimary.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing6,
          vertical: AppTheme.spacing4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );

    if (!expand) return child;
    return SizedBox(width: double.infinity, child: child);
  }
}
