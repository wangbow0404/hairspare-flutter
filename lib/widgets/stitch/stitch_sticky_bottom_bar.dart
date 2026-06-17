import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 하단 고정 CTA 바 — 공고 상세·결제 등 공용.
class StitchStickyBottomBar extends StatelessWidget {
  const StitchStickyBottomBar({
    super.key,
    this.child,
    this.primaryLabel,
    this.onPrimary,
    this.isLoading = false,
    this.enabled = true,
  }) : assert(child != null || primaryLabel != null);

  final Widget? child;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: const Border(
          top: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      padding: AppTheme.spacing(AppTheme.spacing4),
      child: SafeArea(
        top: false,
        child: child ??
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enabled && !isLoading ? onPrimary : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.stitchPrimaryContainer,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppTheme.stitchPrimaryContainer.withValues(alpha: 0.4),
                  minimumSize: const Size.fromHeight(48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        primaryLabel!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
      ),
    );
  }
}
