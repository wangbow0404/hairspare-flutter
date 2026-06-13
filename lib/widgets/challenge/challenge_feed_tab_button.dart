import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum ChallengeFeedTabVariant {
  /// 검은 띠 위 흰색 필 칩.
  pill,

  /// 비디오 오버레이: 흰 텍스트 + 선택 시 언더라인.
  immersive,
}

class ChallengeFeedTabButton extends StatelessWidget {
  const ChallengeFeedTabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.variant = ChallengeFeedTabVariant.pill,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ChallengeFeedTabVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == ChallengeFeedTabVariant.immersive) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: isSelected ? 1 : 0.65),
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2,
                width: isSelected ? 28 : 0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4,
          vertical: AppTheme.spacing1,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: isSelected ? 0.5 : 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
