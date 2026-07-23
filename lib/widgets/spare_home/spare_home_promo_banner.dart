import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// a안 홈 프로모 배너 — 노쇼 예약금 안내 (닫기 가능).
class SpareHomePromoBanner extends StatefulWidget {
  const SpareHomePromoBanner({super.key});

  @override
  State<SpareHomePromoBanner> createState() => _SpareHomePromoBannerState();
}

class _SpareHomePromoBannerState extends State<SpareHomePromoBanner> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing2,
        AppTheme.spacing4,
        0,
      ),
      child: Material(
        color: HairSpareColors.brandPrimarySoft,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing3,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '노쇼 걱정 없는 예약금 근무 매칭 시작',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: HairSpareColors.brandPrimary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _visible = false),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: HairSpareColors.textSecondary,
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
